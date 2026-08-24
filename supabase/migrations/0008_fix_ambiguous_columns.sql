-- RETURNS TABLE(...) output columns become PL/pgSQL variables in scope for
-- the whole function body, silently shadowing same-named table columns in
-- any bare (unqualified) reference. Found by an end-to-end test against a
-- live project: join_session and confirm_trade errored outright
-- ("column reference is ambiguous"), and login_player's device re-link
-- silently targeted the wrong rows. Every bare reference to an OUT column
-- name is now qualified.

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
    raise exception 'bad_pin';
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

  -- player_id was ambiguous against this function's own `player_id` OUT column
  delete from player_auth_links where player_auth_links.player_id = v_row.id or player_auth_links.auth_uid = v_uid;
  insert into player_auth_links (player_id, auth_uid) values (v_row.id, v_uid);

  return query select v_row.id, v_row.nickname;
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

  -- code was ambiguous against this function's own `code` OUT column
  select s.* into v_session from sessions s where s.code = upper(trim(p_code)) for update;
  if not found or v_session.status <> 'open' then
    raise exception 'session_not_found';
  end if;
  if v_session.expires_at < now() then
    raise exception 'session_expired';
  end if;

  select p.nickname into v_nickname from players p where p.id = v_pid;

  -- session_id was ambiguous against this function's own `session_id` OUT column
  if exists (
    select 1 from session_players sp
    where sp.session_id = v_session.id and sp.player_id = v_pid and sp.left_at is null
  ) then
    return query select v_session.id, v_session.code;
    return;
  end if;

  select count(*) into v_active_count
    from session_players sp where sp.session_id = v_session.id and sp.left_at is null;
  if v_active_count >= v_session.max_players then
    raise exception 'room_full';
  end if;

  insert into session_players (session_id, player_id, nickname)
    values (v_session.id, v_pid, v_nickname)
    on conflict (session_id, player_id) do update set left_at = null, nickname = excluded.nickname;

  return query select v_session.id, v_session.code;
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

  -- status was ambiguous against this function's own `status` OUT column
  return query select trades.status from trades where id = p_trade_id;
end;
$$;
