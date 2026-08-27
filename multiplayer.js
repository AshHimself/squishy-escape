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
  const SB_URL = params.get("sb") || "https://oaqrzjssxyqddxenzhhs.supabase.co";
  const SB_ANON_KEY = params.get("key") ||
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hcXJ6anNzeHlxZGR4ZW56aGhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NjE2NTEsImV4cCI6MjEwMzEzNzY1MX0.acB7r4YuTHU4Ixyyy0a67cAbc3g3qCiuMzh6ln1tI_Y";

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
    bad_offer: "That offer doesn't look right — try picking your squishies again.",
    bad_inventory: "Couldn't sync your squishies just now — they're safe on this device.",
    rate_limited: "Too many changes too fast — wait a minute and try again.",
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
    // camelCase to match the shape watchRoom's presence sync produces --
    // menuLobby() compares roster entries against mp.playerId either way.
    return (data || []).map((r) => ({ playerId: r.player_id, nickname: r.nickname, isHost: r.is_host }));
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

  // Updates this device's player_saves row -- the un-ranked cloud mirror of
  // local save (money / eggTier / runs / settings). best_dist and best_money
  // are leaderboard-ranked and are NOT writable this way any more: the
  // database revokes UPDATE on those two columns (migration 0013), so
  // including them here would get the whole statement rejected. They move
  // only through submitScore(). Any caller still passing them has them
  // stripped rather than failing.
  async function updateSave(saveFields) {
    if (!available()) throw new MPError("offline");
    const me = await whoami();
    if (!me) throw new MPError("not_registered");
    const fields = { ...(saveFields || {}) };
    delete fields.best_dist;
    delete fields.best_money;
    if (!Object.keys(fields).length) return;
    const { error } = await sb
      .from("player_saves")
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq("player_id", me.playerId);
    if (error) throw new MPError((error.message || "").trim());
  }

  // The ONLY way a distance/coin score reaches the leaderboard. The backend
  // (submit_score, migration 0013) range-checks the run, checks it against a
  // coins-per-metre and a metres-per-second plausibility bound, rate-limits
  // how often one player can submit, and logs every call. dist/money are
  // this run's totals; runMs is the measured wall-clock length of the run
  // (optional -- omit it and the speed check is skipped).
  //
  // Resolves { bestDist, bestMoney, accepted, reason }. `accepted:false` is
  // not an error -- it means the run didn't make the board (reason is a
  // short code, or the raw value if it looked tampered). Only a genuine
  // precondition failure (not_registered / offline) throws.
  async function submitScore(dist, money, runMs) {
    const rows = await rpc("submit_score", {
      p_dist: Math.max(0, Math.floor(dist || 0)),
      p_money: Math.max(0, Math.floor(money || 0)),
      p_run_ms: runMs == null ? null : Math.max(0, Math.floor(runMs)),
    });
    const row = Array.isArray(rows) ? rows[0] : rows;
    return {
      bestDist: row ? row.result_dist : 0,
      bestMoney: row ? row.result_money : 0,
      accepted: !!(row && row.accepted),
      reason: row ? row.reason : "no_response",
    };
  }

  // Reconcile this device's local counts into cloud inventory before a
  // trading session, and push the save mirror. player_inventory has no
  // direct write grant any more (migration 0015) -- this goes through the
  // sync_inventory RPC, which is *additive*: it folds the local collection
  // into the cloud (greatest per squishy) rather than overwriting, so a
  // registered player never loses squishies by signing in on another
  // device. Resolves to the reconciled {squishyId: qty} map so the caller
  // can adopt anything the cloud knew about that this device didn't.
  async function pushInventory(counts, saveFields) {
    if (!available()) throw new MPError("offline");
    const clean = {};
    for (const [id, qty] of Object.entries(counts || {})) {
      if (qty > 0) clean[id] = Math.floor(qty);
    }
    const rows = await rpc("sync_inventory", { p_counts: clean });
    if (saveFields) await updateSave(saveFields);
    const merged = {};
    for (const r of rows || []) merged[r.squishy_id] = r.qty;
    return merged;
  }

  // Apply signed deltas to cloud inventory: { squishyId: +1 } after a local
  // hatch, { squishyId: -2, ... } for a trade-up's consumed dupes. Keeps the
  // cloud in step with local as the collection changes, so sync_inventory's
  // additive merge stays tight. Best-effort -- callers fire and forget.
  async function adjustInventory(deltas) {
    const clean = {};
    for (const [id, d] of Object.entries(deltas || {})) {
      const n = Math.trunc(d);
      if (n !== 0) clean[id] = n;
    }
    if (!Object.keys(clean).length) return {};
    const rows = await rpc("adjust_inventory", { p_deltas: clean });
    const merged = {};
    for (const r of rows || []) merged[r.squishy_id] = r.qty;
    return merged;
  }

  // Top players by best distance. No sign-in required to call this -- the
  // whole point is a not-yet-registered visitor can see what they're missing.
  async function getLeaderboard(limit = 10) {
    const rows = await rpc("get_leaderboard", { p_limit: limit });
    return (rows || []).map((r) => ({ nickname: r.nickname, bestDist: r.best_dist, bestMoney: r.best_money }));
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
    adjustInventory,
    pullInventory,
    updateSave,
    submitScore,
    getLeaderboard,
    MPError,
  };
})();
