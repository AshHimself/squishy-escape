-- Server-side entry points for every inventory change -- as authoritative as
-- a game that still hatches, spends and upgrades entirely client-side can be.
--
-- Before this, 0006 granted `insert, update on player_inventory to
-- authenticated` with a for-all RLS policy, and multiplayer.js's
-- pushInventory() wrote {squishy_id, qty} rows straight in. A cheater could
-- mint any squishy in any quantity in the console and trade the fakes to
-- real players.
--
-- Now: direct insert/update on player_inventory is revoked (SELECT stays, so
-- pullInventory still reads your own rows). Every write goes through a
-- security definer RPC:
--   * confirm_trade / apply_trade_swap  -- the swap, already server-side (0005)
--   * adjust_inventory({id: delta})     -- +1 on a hatch, -n on a trade-up
--   * sync_inventory({id: qty})         -- reconcile a device's local counts up
-- all bounded by inv_limits (per-squishy ceiling, writes-per-hour) and
-- audited in player_inv_audit.
--
-- "Authenticated players never lose inventory": sync_inventory is additive --
-- greatest(cloud, claimed) per squishy, never lowers a count, never drops a
-- species -- so signing in on any device folds that device's collection into
-- the cloud rather than replacing it. adjust_inventory keeps the cloud in
-- step with hatches/trade-ups as they happen so the union stays tight.
--
-- Accepted residual: a trade-up done OFFLINE spends dupes the cloud never
-- hears about, and the additive sync won't walk them back -- so the cloud
-- can over-count until a trade reconciles it. And hatching/money/egg tier
-- are still local (the README documents `__SE.save.money = 9999` as a
-- feature), so a determined cheater can still pad their OWN collection up to
-- the per-squishy cap. What's closed is the unbounded console mint and any
-- direct table write; honest players' trades were already safe from theft.

revoke insert, update on player_inventory from authenticated;

drop policy if exists player_inventory_self on player_inventory;
create policy player_inventory_read_self on player_inventory
  for select using (player_id = current_player_id());

-- ------------------------------------------------------- rate-limit plumbing
create table player_inv_audit (
  player_id       uuid primary key references players(id) on delete cascade,
  writes          int not null default 0,
  last_write_at   timestamptz,
  hr_window_start timestamptz,
  hr_count        int not null default 0,
  updated_at      timestamptz not null default now()
);
revoke all on player_inv_audit from anon, authenticated;

create table inv_limits (
  id                  int primary key default 1 check (id = 1),
  max_qty_per_squishy int not null default 500,   -- no legit collection has 500 of one species
  max_keys_per_call   int not null default 200,   -- there are ~30 squishies
  max_writes_per_hr   int not null default 300
);
insert into inv_limits (id) values (1) on conflict do nothing;
revoke all on inv_limits from anon, authenticated;

-- Rolls the hourly window forward, bumps the counter, raises 'rate_limited'
-- over the cap. Called once per adjust_inventory / sync_inventory call.
create or replace function inv_rate_check(p_pid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  lim     inv_limits%rowtype;
  aud     player_inv_audit%rowtype;
  v_now   timestamptz := now();
  v_start timestamptz;
  v_count int;
begin
  select * into lim from inv_limits where id = 1;

  insert into player_inv_audit (player_id) values (p_pid)
    on conflict (player_id) do nothing;
  select * into aud from player_inv_audit where player_inv_audit.player_id = p_pid for update;

  if aud.hr_window_start is null or v_now - aud.hr_window_start >= interval '1 hour' then
    v_start := v_now; v_count := 0;
  else
    v_start := aud.hr_window_start; v_count := aud.hr_count;
  end if;

  if v_count >= lim.max_writes_per_hr then
    raise exception 'rate_limited';
  end if;

  update player_inv_audit set
    writes          = player_inv_audit.writes + 1,
    last_write_at   = v_now,
    hr_window_start = v_start,
    hr_count        = v_count + 1,
    updated_at      = v_now
  where player_inv_audit.player_id = p_pid;
end;
$$;

-- ---------------------------------------------------------- adjust_inventory
-- p_deltas is {squishy_id: signed_int}. +1 after a local hatch, negative on
-- a trade-up's consumed dupes. Each squishy is clamped to [0, cap]. Returns
-- the caller's full non-zero inventory afterwards.
create or replace function adjust_inventory(p_deltas jsonb)
returns table(squishy_id text, qty int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  lim   inv_limits%rowtype;
  k     text;
  dv    text;
  d     int;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;
  if p_deltas is null or jsonb_typeof(p_deltas) <> 'object' then
    raise exception 'bad_inventory';
  end if;
  if (select count(*) from jsonb_object_keys(p_deltas)) > (select max_keys_per_call from inv_limits where id = 1) then
    raise exception 'bad_inventory';
  end if;

  select * into lim from inv_limits where id = 1;
  perform inv_rate_check(v_pid);

  for k, dv in select key, value from jsonb_each_text(p_deltas) loop
    if coalesce(trim(k), '') = '' or char_length(k) > 64 then
      raise exception 'bad_inventory';
    end if;
    if dv !~ '^-?[0-9]{1,7}$' then
      raise exception 'bad_inventory';
    end if;
    d := dv::int;
    if d = 0 then
      continue;
    end if;
    insert into player_inventory as pi (player_id, squishy_id, qty)
      values (v_pid, k, greatest(0, least(d, lim.max_qty_per_squishy)))
      on conflict on constraint player_inventory_pkey
      do update set qty = greatest(0, least(pi.qty + d, lim.max_qty_per_squishy));
  end loop;

  return query
    select inv.squishy_id, inv.qty
    from player_inventory inv
    where inv.player_id = v_pid and inv.qty > 0;
end;
$$;

-- ------------------------------------------------------------ sync_inventory
-- p_counts is {squishy_id: qty} straight from a device's local save.counts.
-- Additive reconcile: greatest(cloud, claimed) per squishy, clamped to the
-- cap. Never lowers a count, never removes a species -- this is what keeps
-- "sign in and your squishies are still there" true across devices.
create or replace function sync_inventory(p_counts jsonb)
returns table(squishy_id text, qty int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  lim   inv_limits%rowtype;
  k     text;
  qv    text;
  q     int;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;
  if p_counts is null or jsonb_typeof(p_counts) <> 'object' then
    raise exception 'bad_inventory';
  end if;
  if (select count(*) from jsonb_object_keys(p_counts)) > (select max_keys_per_call from inv_limits where id = 1) then
    raise exception 'bad_inventory';
  end if;

  select * into lim from inv_limits where id = 1;
  perform inv_rate_check(v_pid);

  for k, qv in select key, value from jsonb_each_text(p_counts) loop
    if coalesce(trim(k), '') = '' or char_length(k) > 64 then
      raise exception 'bad_inventory';
    end if;
    if qv !~ '^[0-9]{1,7}$' then
      raise exception 'bad_inventory';
    end if;
    q := least(qv::int, lim.max_qty_per_squishy);
    if q <= 0 then
      continue;
    end if;
    insert into player_inventory as pi (player_id, squishy_id, qty)
      values (v_pid, k, q)
      on conflict on constraint player_inventory_pkey
      do update set qty = greatest(pi.qty, q);
  end loop;

  return query
    select inv.squishy_id, inv.qty
    from player_inventory inv
    where inv.player_id = v_pid and inv.qty > 0;
end;
$$;
