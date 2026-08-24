-- Trading sessions: up to 3 players joined via a short room code.
-- Live "who's connected right now" is handled client-side by Supabase
-- Realtime Presence on channel `session:<session_id>`, not by this table --
-- session_players is the durable "who is a member of this room" record.

create table sessions (
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,
  host_player_id uuid not null references players(id),
  status         text not null default 'open' check (status in ('open', 'closed')),
  max_players    int not null default 3,
  created_at     timestamptz not null default now(),
  expires_at     timestamptz not null default now() + interval '2 hours'
);

create table session_players (
  session_id uuid not null references sessions(id) on delete cascade,
  player_id  uuid not null references players(id),
  nickname   text not null,
  joined_at  timestamptz not null default now(),
  left_at    timestamptz,
  is_host    boolean not null default false,
  primary key (session_id, player_id)
);
-- Only one active (not-left) row per player per session, so "currently in
-- room" is a simple count query.
create unique index session_players_active_uq
  on session_players (session_id, player_id)
  where left_at is null;
