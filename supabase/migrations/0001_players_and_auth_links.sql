-- Durable player identity (nickname + PIN), decoupled from Supabase Auth's
-- anonymous session uid so a player can "pick up" their profile on a new
-- device by re-entering nickname + PIN.

create extension if not exists pgcrypto;

create table players (
  id            uuid primary key default gen_random_uuid(),
  nickname      text not null,
  nickname_key  text generated always as (lower(trim(nickname))) stored,
  pin_hash      text not null,
  pin_attempts  int not null default 0,
  locked_until  timestamptz,
  created_at    timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  constraint nickname_len check (char_length(trim(nickname)) between 2 and 16)
);
create unique index players_nickname_key_uq on players (nickname_key);

-- No grants to anon/authenticated: this table is only reachable through the
-- security definer RPCs in 0005_rpc_functions.sql.
revoke all on players from anon, authenticated;

-- Maps a device's current anonymous auth.uid() to a durable player_id.
-- One row per player: logging in on a new device replaces it, which both
-- enables "pick up on another device" and implicitly logs the old device out.
create table player_auth_links (
  player_id  uuid primary key references players(id) on delete cascade,
  auth_uid   uuid not null unique,
  linked_at  timestamptz not null default now()
);
revoke all on player_auth_links from anon, authenticated;

-- Resolves the calling device's auth.uid() to its durable player_id.
-- security definer so it can read player_auth_links despite the table
-- having no direct grants; used by RLS policies on player-owned tables.
create or replace function current_player_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select player_id from player_auth_links where auth_uid = auth.uid();
$$;
