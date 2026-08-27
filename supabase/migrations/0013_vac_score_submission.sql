-- VAC: "scores only come from the backend" for the leaderboard.
--
-- Before this, player_saves.best_dist / best_money were plain UPDATE-able by
-- any signed-in device -- RLS policy player_saves_self (0006) plus the table
-- GRANT (also 0006) let a browser write its own row freely, and
-- get_leaderboard (0011) reads those two columns straight. The console
-- one-liner `MP.updateSave({ best_dist: 9e9 })` therefore parked you at the
-- top of the board forever.
--
-- Now:
--   * UPDATE on those two columns is revoked from `authenticated`, so no
--     direct table write reaches them ever again. Everything else on the
--     row (money, egg_tier, equipped, runs, muted, skin, accessory) stays
--     client-writable -- it's an un-ranked cloud mirror of local save.
--   * submit_score() -- a security definer RPC -- is the only way a number
--     lands in best_dist / best_money. It sanity-checks every run and
--     rate-limits how often one player can submit, and writes an
--     append-only-ish audit row for every accept and every reject.
--
-- Residual limitation, stated honestly: the anon key is public and the
-- simulation still runs in the browser, so a determined cheater can craft a
-- submit_score() call with in-range lies (a "plausible" 40000m run). This
-- stops the drive-by console tampering and the absurd values; catching a
-- hand-tuned fake would need the run itself to be server-simulated, which
-- this one-file game has no backend for. The audit table is what a later
-- pass would mine for that.

-- ------------------------------------------------------------------ 1. lock
-- Kill every direct write to the ranked columns. security definer RPCs
-- (submit_score below) run as the table owner and are unaffected.
revoke update (best_dist, best_money) on player_saves from authenticated;

-- ------------------------------------------------------------ 2. audit trail
-- One row per player, bumped on every submit_score() call. No grants at all
-- -- only the security definer RPCs touch it (same posture as `players`,
-- 0001), so a cheater can't reset their own rate-limit window.
create table player_score_audit (
  player_id          uuid primary key references players(id) on delete cascade,
  submits            int not null default 0,          -- accepted
  rejected           int not null default 0,          -- failed a VAC check
  last_dist          int not null default 0,          -- last accepted distance
  last_submit_at     timestamptz,                     -- any call, accept or reject
  last_accepted_at   timestamptz,                     -- last accepted call
  last_reject_reason text,
  hr_window_start    timestamptz,                     -- rolling 1h rate-limit window
  hr_count           int not null default 0,          -- calls in the current window
  updated_at         timestamptz not null default now()
);
revoke all on player_score_audit from anon, authenticated;

-- --------------------------------------------------------------- 3. tunables
-- The VAC thresholds, one row, RPC-read only. In a table rather than inlined
-- so they can be widened live with a single UPDATE if a genuine run ever
-- trips one -- no redeploy. Defaults are deliberately loose: the dumpling
-- tops out near 9 m/s (SPRINT_RUN 405px/s over TILE 45), a great rainbow
-- ride is a couple of coins per metre, so these leave a wide berth and only
-- bite on tampering.
create table score_limits (
  id                 int primary key default 1 check (id = 1),
  max_dist           int     not null default 100000,  -- hard ceiling on a run, in metres
  max_money_per_m    numeric not null default 25.0,    -- coins/metre a flawless run can average
  money_grace        int     not null default 2000,    -- flat headroom for short high-value runs
  min_ms_per_m       int     not null default 15,      -- a run covering N metres took >= 15N ms
  min_submit_gap_s   int     not null default 5,       -- seconds between two accepted submits
  max_submits_per_hr int     not null default 60       -- calls (accepted or not) per rolling hour
);
insert into score_limits (id) values (1) on conflict do nothing;
revoke all on score_limits from anon, authenticated;

-- --------------------------------------------------------- 4. scrub the board
-- Anything already sitting above the ceilings got there through the old
-- direct-write hole. Clamp it rather than delete the player.
update player_saves s set
  best_dist = least(
    s.best_dist,
    (select l.max_dist from score_limits l where l.id = 1)),
  best_money = least(
    s.best_money,
    (select round(l.max_dist * l.max_money_per_m + l.money_grace)::int
       from score_limits l where l.id = 1))
where s.best_dist  > (select l.max_dist from score_limits l where l.id = 1)
   or s.best_money > (select round(l.max_dist * l.max_money_per_m + l.money_grace)::int
                        from score_limits l where l.id = 1);

-- ----------------------------------------------------------- 5. the only door
-- p_dist / p_money are this run's distance and coin take (run.dist /
-- run.money in index.html), p_run_ms the wall-clock length of the run as
-- measured client-side (pause/tab-away only ever inflate it, which loosens
-- the speed check, never tightens it -- so a legit run can't be failed by a
-- slow measurement).
--
-- Returns one row: the player's best AFTER this call, whether it counted,
-- and if not, why. A rejected run is NOT an error the kid caused, so it does
-- not raise -- the client just keeps the score local and doesn't claim the
-- board. `not_registered` is the one real precondition failure and does raise
-- (multiplayer.js already handles that code).
--
-- OUT columns are named result_* on purpose: RETURNS TABLE columns become
-- PL/pgSQL variables that shadow same-named table columns in bare references
-- (see 0008) -- best_dist / best_money as OUT names would collide with
-- player_saves. Table refs below are still qualified as belt-and-braces.
create or replace function submit_score(
  p_dist   int,
  p_money  int,
  p_run_ms int default null
)
returns table(result_dist int, result_money int, accepted boolean, reason text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid        uuid := current_player_id();
  v_now        timestamptz := now();
  lim          score_limits%rowtype;
  aud          player_score_audit%rowtype;
  v_reason     text := null;
  v_best_dist  int;
  v_best_money int;
  v_hr_start   timestamptz;
  v_hr_count   int;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;

  select * into lim from score_limits where id = 1;

  -- Make the row exist, then lock it so a player's own concurrent submits
  -- serialise (rate-limit counting stays correct under a double-tap).
  insert into player_score_audit (player_id) values (v_pid)
    on conflict (player_id) do nothing;
  select * into aud from player_score_audit
    where player_score_audit.player_id = v_pid
    for update;

  -- Roll the hourly window forward if the last one has fully elapsed.
  if aud.hr_window_start is null or v_now - aud.hr_window_start >= interval '1 hour' then
    v_hr_start := v_now;
    v_hr_count := 0;
  else
    v_hr_start := aud.hr_window_start;
    v_hr_count := aud.hr_count;
  end if;

  -- ---------------------------- VAC checks ----------------------------
  -- p_dist / p_money arrive typed as int, so non-numeric and fractional
  -- are already impossible -- range, plausibility and rate are what's left.
  if p_dist is null or p_money is null then
    v_reason := 'missing_fields';
  elsif p_dist <= 0 or p_money < 0 then
    v_reason := 'out_of_range';
  elsif p_dist > lim.max_dist then
    v_reason := 'impossible_distance';
  elsif p_money::numeric > p_dist::numeric * lim.max_money_per_m + lim.money_grace then
    v_reason := 'impossible_money';
  elsif p_run_ms is not null and p_run_ms < p_dist::bigint * lim.min_ms_per_m then
    v_reason := 'impossible_speed';
  elsif aud.last_accepted_at is not null
        and v_now - aud.last_accepted_at < make_interval(secs => lim.min_submit_gap_s) then
    v_reason := 'too_soon';
  elsif v_hr_count >= lim.max_submits_per_hr then
    v_reason := 'rate_limited';
  end if;

  -- ------------------------------ reject -----------------------------
  if v_reason is not null then
    update player_score_audit set
      rejected           = player_score_audit.rejected + 1,
      last_submit_at     = v_now,
      last_reject_reason = v_reason,
      hr_window_start    = v_hr_start,
      hr_count           = v_hr_count + 1,   -- a rejected call still spends rate budget
      updated_at         = v_now
    where player_score_audit.player_id = v_pid;

    select s.best_dist, s.best_money into v_best_dist, v_best_money
      from player_saves s where s.player_id = v_pid;
    return query select coalesce(v_best_dist, 0), coalesce(v_best_money, 0), false, v_reason;
    return;
  end if;

  -- ------------------------------ accept -----------------------------
  update player_saves s set
    best_dist  = greatest(s.best_dist, p_dist),
    best_money = greatest(s.best_money, p_money),
    updated_at = v_now
  where s.player_id = v_pid
  returning s.best_dist, s.best_money into v_best_dist, v_best_money;

  if not found then
    -- registered player with no saves row should not happen (register_player
    -- creates it) -- treat as a precondition failure, don't invent a row.
    raise exception 'not_registered';
  end if;

  update player_score_audit set
    submits          = player_score_audit.submits + 1,
    last_dist        = p_dist,
    last_submit_at   = v_now,
    last_accepted_at = v_now,
    hr_window_start  = v_hr_start,
    hr_count         = v_hr_count + 1,
    updated_at       = v_now
  where player_score_audit.player_id = v_pid;

  return query select v_best_dist, v_best_money, true, null::text;
end;
$$;
