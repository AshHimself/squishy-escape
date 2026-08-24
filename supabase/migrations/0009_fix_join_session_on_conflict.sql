-- 0008 qualified every bare session_id/code reference in join_session's
-- SELECT/WHERE clauses, but missed one: `on conflict (session_id, player_id)`
-- hits the exact same PL/pgSQL-variable-shadowing ambiguity, because ON
-- CONFLICT's explicit column-list form doesn't accept table-qualified names
-- at all -- there's no `sp.session_id` spelling that would even parse there.
-- Referencing the primary key constraint by name sidesteps the bare-column
-- list entirely.

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

  select s.* into v_session from sessions s where s.code = upper(trim(p_code)) for update;
  if not found or v_session.status <> 'open' then
    raise exception 'session_not_found';
  end if;
  if v_session.expires_at < now() then
    raise exception 'session_expired';
  end if;

  select p.nickname into v_nickname from players p where p.id = v_pid;

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
    on conflict on constraint session_players_pkey
    do update set left_at = null, nickname = excluded.nickname;

  return query select v_session.id, v_session.code;
end;
$$;
