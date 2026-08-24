-- All multiplayer logic lives here as security definer RPCs, callable
-- directly from the browser via supabase-js's .rpc(). Nothing sensitive is
-- reachable any other way (players/player_auth_links have no grants at
-- all -- see 0001). Client-facing error messages are short lowercase_snake
-- codes so multiplayer.js can switch on err.message.

-- ------------------------------- identity --------------------------------

create or replace function register_player(p_nickname text, p_pin text)
returns table(player_id uuid, nickname text)
language plpgsql
security definer
set search_path = public, extensions  -- extensions: where Supabase installs pgcrypto (crypt/gen_salt)
as $$
declare
  v_uid uuid := auth.uid();
  v_id  uuid;
begin
  if v_uid is null then
    raise exception 'not_logged_in';
  end if;
  if p_pin !~ '^[0-9]{4}$' then
    raise exception 'invalid_pin';
  end if;
  if char_length(trim(coalesce(p_nickname, ''))) not between 2 and 16 then
    raise exception 'invalid_nickname';
  end if;
  if exists (select 1 from players where nickname_key = lower(trim(p_nickname))) then
    raise exception 'nickname_taken';
  end if;

  insert into players (nickname, pin_hash)
    values (trim(p_nickname), crypt(p_pin, gen_salt('bf', 8)))
    returning id into v_id;

  insert into player_saves (player_id) values (v_id);

  begin
    insert into player_auth_links (player_id, auth_uid) values (v_id, v_uid);
  exception when unique_violation then
    raise exception 'device_already_linked';
  end;

  return query select v_id, trim(p_nickname);
end;
$$;

create or replace function login_player(p_nickname text, p_pin text)
returns table(player_id uuid, nickname text)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_uid uuid := auth.uid();
  v_row players%rowtype;
begin
  if v_uid is null then
    raise exception 'not_logged_in';
  end if;

  select * into v_row from players where nickname_key = lower(trim(p_nickname)) for update;
  if not found then
    raise exception 'bad_pin'; -- deliberately same error as wrong PIN, don't leak which nicknames exist
  end if;

  if v_row.locked_until is not null and v_row.locked_until > now() then
    raise exception 'account_locked';
  end if;

  if v_row.pin_hash <> crypt(p_pin, v_row.pin_hash) then
    update players
      set pin_attempts = pin_attempts + 1,
          locked_until = case when pin_attempts + 1 >= 5 then now() + interval '5 minutes' else locked_until end
      where id = v_row.id;
    raise exception 'bad_pin';
  end if;

  update players set pin_attempts = 0, locked_until = null, last_seen_at = now() where id = v_row.id;

  -- Re-point this player's device link to the caller's current auth_uid --
  -- this is what makes "pick up on another device" work (and implicitly
  -- logs the previous device out, since auth_uid is unique).
  delete from player_auth_links where player_id = v_row.id or auth_uid = v_uid;
  insert into player_auth_links (player_id, auth_uid) values (v_row.id, v_uid);

  return query select v_row.id, v_row.nickname;
end;
$$;

-- Lets a returning device (one that still has a valid anonymous auth
-- session) find out which player it's linked to, without needing the
-- nickname/PIN again. Returns no rows if this device isn't linked yet.
create or replace function whoami()
returns table(player_id uuid, nickname text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.nickname
  from players p
  join player_auth_links l on l.player_id = p.id
  where l.auth_uid = auth.uid();
$$;

-- ------------------------------- sessions ---------------------------------

create or replace function gen_room_code()
returns text
language sql
volatile
as $$
  select string_agg(substr(alphabet, (random() * length(alphabet))::int + 1, 1), '')
  from (values ('ABCDEFGHJKMNPQRSTUVWXYZ23456789')) as a(alphabet),
       generate_series(1, 5);
$$;

create or replace function create_session()
returns table(session_id uuid, code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  v_code text;
  v_id uuid;
  i int;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;

  for i in 1..5 loop
    v_code := gen_room_code();
    begin
      insert into sessions (host_player_id, code) values (v_pid, v_code) returning id into v_id;
      exit;
    exception when unique_violation then
      if i = 5 then
        raise exception 'code_gen_failed';
      end if;
    end;
  end loop;

  insert into session_players (session_id, player_id, nickname, is_host)
    select v_id, v_pid, p.nickname, true from players p where p.id = v_pid;

  return query select v_id, v_code;
end;
$$;

create or replace function join_session(p_code text)
returns table(session_id uuid, code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  v_session sessions%rowtype;
  v_active_count int;
  v_nickname text;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;

  select * into v_session from sessions where code = upper(trim(p_code)) for update;
  if not found or v_session.status <> 'open' then
    raise exception 'session_not_found';
  end if;
  if v_session.expires_at < now() then
    raise exception 'session_expired';
  end if;

  select nickname into v_nickname from players where id = v_pid;

  if exists (
    select 1 from session_players
    where session_id = v_session.id and player_id = v_pid and left_at is null
  ) then
    return query select v_session.id, v_session.code; -- already in, no-op
  end if;

  select count(*) into v_active_count
    from session_players where session_id = v_session.id and left_at is null;
  if v_active_count >= v_session.max_players then
    raise exception 'room_full';
  end if;

  insert into session_players (session_id, player_id, nickname)
    values (v_session.id, v_pid, v_nickname)
    on conflict (session_id, player_id) do update set left_at = null, nickname = excluded.nickname;

  return query select v_session.id, v_session.code;
end;
$$;

create or replace function leave_session(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;

  update session_players
    set left_at = now()
    where session_id = p_session_id and player_id = v_pid and left_at is null;
end;
$$;

-- -------------------------------- trades ----------------------------------

create or replace function propose_trade(p_session_id uuid, p_other_player uuid, p_offer jsonb)
returns table(trade_id uuid)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  v_id uuid;
begin
  if v_pid is null then
    raise exception 'not_registered';
  end if;
  if v_pid = p_other_player then
    raise exception 'cannot_trade_self';
  end if;
  if not exists (
    select 1 from session_players
    where session_id = p_session_id and player_id in (v_pid, p_other_player) and left_at is null
    having count(*) = 2
  ) then
    raise exception 'not_in_session';
  end if;

  begin
    insert into trades (session_id, player_a, player_b, offer_a)
      values (p_session_id, v_pid, p_other_player, coalesce(p_offer, '[]'::jsonb))
      returning id into v_id;
  exception when unique_violation then
    raise exception 'trade_already_active';
  end;

  return query select v_id;
end;
$$;

create or replace function update_trade_offer(p_trade_id uuid, p_offer jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  t trades%rowtype;
begin
  select * into t from trades where id = p_trade_id for update;
  if not found then
    raise exception 'trade_not_found';
  end if;
  if t.status <> 'negotiating' then
    raise exception 'trade_not_negotiating';
  end if;

  -- Any edit un-confirms both sides -- this one function handles both
  -- initial refinement and counter-offers.
  if v_pid = t.player_a then
    update trades set offer_a = coalesce(p_offer, '[]'::jsonb), confirmed_a = false, confirmed_b = false, updated_at = now()
      where id = p_trade_id;
  elsif v_pid = t.player_b then
    update trades set offer_b = coalesce(p_offer, '[]'::jsonb), confirmed_a = false, confirmed_b = false, updated_at = now()
      where id = p_trade_id;
  else
    raise exception 'not_a_party';
  end if;
end;
$$;

-- Applies the inventory swap for a just-both-confirmed trade. Only ever
-- called from inside confirm_trade, in the same transaction, so the row
-- lock confirm_trade already holds covers this too.
create or replace function apply_trade_swap(p_trade_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t trades%rowtype;
  item jsonb;
begin
  select * into t from trades where id = p_trade_id;

  -- Lock every touched inventory row up front, in one global (player_id,
  -- squishy_id) order across both sides, so two simultaneous trades
  -- involving overlapping players can never deadlock against each other.
  perform 1 from player_inventory
    where (player_id, squishy_id) in (
      select t.player_a, (i->>'squishy_id') from jsonb_array_elements(t.offer_a) i
      union
      select t.player_b, (i->>'squishy_id') from jsonb_array_elements(t.offer_b) i
    )
    order by player_id, squishy_id
    for update;

  for item in select * from jsonb_array_elements(t.offer_a) loop
    update player_inventory
      set qty = qty - (item->>'qty')::int
      where player_id = t.player_a and squishy_id = (item->>'squishy_id') and qty >= (item->>'qty')::int;
    if not found then
      raise exception 'insufficient_qty';
    end if;
    insert into player_inventory (player_id, squishy_id, qty)
      values (t.player_b, item->>'squishy_id', (item->>'qty')::int)
      on conflict (player_id, squishy_id) do update set qty = player_inventory.qty + excluded.qty;
  end loop;

  for item in select * from jsonb_array_elements(t.offer_b) loop
    update player_inventory
      set qty = qty - (item->>'qty')::int
      where player_id = t.player_b and squishy_id = (item->>'squishy_id') and qty >= (item->>'qty')::int;
    if not found then
      raise exception 'insufficient_qty';
    end if;
    insert into player_inventory (player_id, squishy_id, qty)
      values (t.player_a, item->>'squishy_id', (item->>'qty')::int)
      on conflict (player_id, squishy_id) do update set qty = player_inventory.qty + excluded.qty;
  end loop;

  update trades set status = 'completed', completed_at = now(), updated_at = now() where id = p_trade_id;
end;
$$;

create or replace function confirm_trade(p_trade_id uuid)
returns table(status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  t trades%rowtype;
begin
  -- Row lock serializes concurrent confirm_trade calls from both parties:
  -- whichever transaction gets here second, after the first commits, sees
  -- status already 'completed' and just returns it -- there is no window
  -- where both believe they triggered the swap.
  select * into t from trades where id = p_trade_id for update;
  if not found then
    raise exception 'trade_not_found';
  end if;
  if t.status <> 'negotiating' then
    return query select t.status;
    return;
  end if;

  if v_pid = t.player_a then
    update trades set confirmed_a = true, updated_at = now() where id = p_trade_id;
  elsif v_pid = t.player_b then
    update trades set confirmed_b = true, updated_at = now() where id = p_trade_id;
  else
    raise exception 'not_a_party';
  end if;

  select * into t from trades where id = p_trade_id;
  if t.confirmed_a and t.confirmed_b then
    perform apply_trade_swap(p_trade_id);
  end if;

  return query select status from trades where id = p_trade_id;
end;
$$;

create or replace function cancel_trade(p_trade_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pid uuid := current_player_id();
  t trades%rowtype;
begin
  select * into t from trades where id = p_trade_id for update;
  if not found then
    raise exception 'trade_not_found';
  end if;
  if v_pid <> t.player_a and v_pid <> t.player_b then
    raise exception 'not_a_party';
  end if;
  if t.status <> 'negotiating' then
    return;
  end if;

  update trades set status = 'cancelled', updated_at = now() where id = p_trade_id;
end;
$$;
