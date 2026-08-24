-- Supabase installs pgcrypto into the `extensions` schema, not `public`.
-- register_player/login_player's `set search_path = public` (0005) couldn't
-- see crypt()/gen_salt() as a result. Re-create both with `extensions` added
-- to the search path. (0005 itself is also fixed for fresh installs; this
-- migration is what actually patches an already-applied database.)

create or replace function register_player(p_nickname text, p_pin text)
returns table(player_id uuid, nickname text)
language plpgsql
security definer
set search_path = public, extensions
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

  delete from player_auth_links where player_id = v_row.id or auth_uid = v_uid;
  insert into player_auth_links (player_id, auth_uid) values (v_row.id, v_uid);

  return query select v_row.id, v_row.nickname;
end;
$$;
