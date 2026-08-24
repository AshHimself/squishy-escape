/* Squishy Escape multiplayer client. Talks to Supabase (Postgres RPCs +
   Realtime). Kept as a second, separate <script> tag on purpose -- the
   game loop in index.html is untouched, and everything here funnels
   through window.MP so index.html only ever calls MP.* and never talks to
   Supabase directly.

   Every MP.* async function either resolves with data or throws an
   MPError with a kid-friendly .friendly message on .message and the raw
   server code on .code -- callers can just show err.message. */

(() => {
  "use strict";

  // Public anon key + URL are meant to be public (same as any Firebase/
  // Supabase web app) -- real protection is Row Level Security and the
  // fact that sensitive tables have no direct grants at all, only RPCs.
  // Override via ?sb=<url>&key=<anon-key> for pointing at a different
  // project (e.g. local dev) without a build step.
  const params = new URLSearchParams(location.search);
  const SB_URL = params.get("sb") || "https://YOUR-PROJECT.supabase.co";
  const SB_ANON_KEY = params.get("key") || "YOUR-ANON-KEY";

  const ERROR_MESSAGES = {
    not_logged_in: "Something went wrong signing you in — try again.",
    invalid_pin: "Your PIN needs to be exactly 4 numbers.",
    invalid_nickname: "Nicknames need to be 2–16 letters.",
    nickname_taken: "Someone already picked that nickname — try another!",
    device_already_linked: "This device is already signed in.",
    bad_pin: "That nickname and PIN don't match. Try again!",
    account_locked: "Too many tries — wait a few minutes and try again.",
    not_registered: "You need to sign in first.",
    room_full: "That room already has 3 players!",
    session_not_found: "Couldn't find a room with that code.",
    session_expired: "That room code has expired — make a new one.",
    cannot_trade_self: "You can't trade with yourself!",
    not_in_session: "You both need to be in the same room to trade.",
    trade_already_active: "You're already trading with them.",
    trade_not_found: "That trade isn't there any more.",
    trade_not_negotiating: "That trade already finished.",
    not_a_party: "That's not your trade.",
    insufficient_qty: "Looks like an offer changed — check what you have.",
    code_gen_failed: "Couldn't make a room code — try again.",
    offline: "No internet connection — trading needs to be online.",
  };

  class MPError extends Error {
    constructor(code) {
      super(ERROR_MESSAGES[code] || "Something went wrong. Try again!");
      this.code = code;
    }
  }

  let sb = null;
  try {
    if (window.supabase && SB_URL.startsWith("http") && !SB_URL.includes("YOUR-PROJECT")) {
      sb = window.supabase.createClient(SB_URL, SB_ANON_KEY, {
        auth: { persistSession: true, autoRefreshToken: true },
      });
    }
  } catch (e) { sb = null; }

  function available() { return !!sb && navigator.onLine; }

  async function rpc(name, args) {
    if (!available()) throw new MPError("offline");
    const { data, error } = await sb.rpc(name, args || {});
    if (error) throw new MPError((error.message || "").trim());
    return data;
  }

  let authReady = null;
  async function ensureAuth() {
    if (!available()) throw new MPError("offline");
    if (!authReady) {
      authReady = (async () => {
        const { data } = await sb.auth.getSession();
        if (data && data.session) return data.session;
        const { data: anon, error } = await sb.auth.signInAnonymously();
        if (error) throw new MPError("not_logged_in");
        return anon.session;
      })();
    }
    return authReady;
  }

  // ------------------------------- identity --------------------------------

  async function whoami() {
    await ensureAuth();
    const rows = await rpc("whoami");
    const row = Array.isArray(rows) ? rows[0] : rows;
    return row ? { playerId: row.player_id, nickname: row.nickname } : null;
  }

  async function registerPlayer(nickname, pin) {
    await ensureAuth();
    const rows = await rpc("register_player", { p_nickname: nickname, p_pin: pin });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return { playerId: row.player_id, nickname: row.nickname };
  }

  async function loginPlayer(nickname, pin) {
    await ensureAuth();
    const rows = await rpc("login_player", { p_nickname: nickname, p_pin: pin });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return { playerId: row.player_id, nickname: row.nickname };
  }

  // ------------------------------- sessions ---------------------------------

  async function createRoom() {
    const rows = await rpc("create_session");
    const row = Array.isArray(rows) ? rows[0] : rows;
    return { sessionId: row.session_id, code: row.code };
  }

  async function joinRoom(code) {
    const rows = await rpc("join_session", { p_code: code });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return { sessionId: row.session_id, code: row.code };
  }

  async function leaveRoom(sessionId) {
    await rpc("leave_session", { p_session_id: sessionId });
  }

  async function fetchRoster(sessionId) {
    if (!available()) throw new MPError("offline");
    const { data, error } = await sb
      .from("session_players")
      .select("player_id, nickname, is_host")
      .eq("session_id", sessionId)
      .is("left_at", null);
    if (error) throw new MPError((error.message || "").trim());
    return data || [];
  }

  // ------------------------- presence + broadcast ---------------------------

  const channels = new Map(); // sessionId -> realtime channel

  function roomChannel(sessionId) {
    if (channels.has(sessionId)) return channels.get(sessionId);
    const ch = sb.channel(`session:${sessionId}`, { config: { presence: { key: sessionId } } });
    channels.set(sessionId, ch);
    return ch;
  }

  // onPresence({playerId, nickname}[]) fires whenever the live roster changes.
  // onBroadcast({type, ...payload}) fires on bystander trade-summary events.
  function watchRoom(sessionId, me, { onPresence, onBroadcast } = {}) {
    const ch = roomChannel(sessionId);

    if (onPresence) {
      ch.on("presence", { event: "sync" }, () => {
        const state = ch.presenceState();
        const players = Object.values(state)
          .flat()
          .map((p) => ({ playerId: p.playerId, nickname: p.nickname }));
        onPresence(players);
      });
    }
    if (onBroadcast) {
      ch.on("broadcast", { event: "trade" }, ({ payload }) => onBroadcast(payload));
    }

    ch.subscribe(async (status) => {
      if (status === "SUBSCRIBED") {
        await ch.track({ playerId: me.playerId, nickname: me.nickname });
      }
    });

    return () => {
      ch.untrack();
      sb.removeChannel(ch);
      channels.delete(sessionId);
    };
  }

  function broadcastTradeEvent(sessionId, type, payload) {
    const ch = channels.get(sessionId);
    if (!ch) return;
    ch.send({ type: "broadcast", event: "trade", payload: { type, ...payload } });
  }

  // -------------------------------- trades ----------------------------------

  async function proposeTrade(sessionId, otherPlayerId, offerItems) {
    const rows = await rpc("propose_trade", {
      p_session_id: sessionId,
      p_other_player: otherPlayerId,
      p_offer: offerItems || [],
    });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return row.trade_id;
  }

  async function updateTradeOffer(tradeId, offerItems) {
    await rpc("update_trade_offer", { p_trade_id: tradeId, p_offer: offerItems || [] });
  }

  async function confirmTrade(tradeId) {
    const rows = await rpc("confirm_trade", { p_trade_id: tradeId });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return row.status;
  }

  async function cancelTrade(tradeId) {
    await rpc("cancel_trade", { p_trade_id: tradeId });
  }

  // onChange(tradeRow) fires on every insert/update to this trade.
  function watchTrade(tradeId, onChange) {
    if (!available()) return () => {};
    const ch = sb
      .channel(`trade:${tradeId}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "trades", filter: `id=eq.${tradeId}` },
        (payload) => onChange(payload.new)
      )
      .subscribe();
    return () => sb.removeChannel(ch);
  }

  // --------------------------- inventory sync -------------------------------

  // Pushes non-zero local counts + save fields up before a trading session.
  async function pushInventory(counts, saveFields) {
    if (!available()) throw new MPError("offline");
    const me = await whoami();
    if (!me) throw new MPError("not_registered");

    const rows = Object.entries(counts || {})
      .filter(([, qty]) => qty > 0)
      .map(([squishy_id, qty]) => ({ player_id: me.playerId, squishy_id, qty }));
    if (rows.length) {
      const { error } = await sb.from("player_inventory").upsert(rows);
      if (error) throw new MPError((error.message || "").trim());
    }

    if (saveFields) {
      const { error } = await sb
        .from("player_saves")
        .update({ ...saveFields, updated_at: new Date().toISOString() })
        .eq("player_id", me.playerId);
      if (error) throw new MPError((error.message || "").trim());
    }
  }

  // Pulls player_inventory back down into a plain {squishyId: qty} map.
  async function pullInventory() {
    if (!available()) throw new MPError("offline");
    const me = await whoami();
    if (!me) throw new MPError("not_registered");

    const { data, error } = await sb
      .from("player_inventory")
      .select("squishy_id, qty")
      .eq("player_id", me.playerId);
    if (error) throw new MPError((error.message || "").trim());

    const counts = {};
    for (const row of data || []) counts[row.squishy_id] = row.qty;
    return counts;
  }

  window.MP = {
    available,
    ensureAuth,
    whoami,
    registerPlayer,
    loginPlayer,
    createRoom,
    joinRoom,
    leaveRoom,
    fetchRoster,
    watchRoom,
    broadcastTradeEvent,
    proposeTrade,
    updateTradeOffer,
    confirmTrade,
    cancelTrade,
    watchTrade,
    pushInventory,
    pullInventory,
    MPError,
  };
})();
