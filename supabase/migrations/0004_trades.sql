-- One squishy-for-squishy trade negotiation between two players in a
-- session. offer_a / offer_b are jsonb arrays of {squishy_id, qty}.

create table trades (
  id           uuid primary key default gen_random_uuid(),
  session_id   uuid not null references sessions(id) on delete cascade,
  player_a     uuid not null references players(id),
  player_b     uuid not null references players(id),
  offer_a      jsonb not null default '[]'::jsonb,
  offer_b      jsonb not null default '[]'::jsonb,
  confirmed_a  boolean not null default false,
  confirmed_b  boolean not null default false,
  status       text not null default 'negotiating'
                 check (status in ('negotiating', 'completed', 'declined', 'cancelled', 'expired')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  completed_at timestamptz,
  constraint different_players check (player_a <> player_b)
);
create index trades_session_idx on trades (session_id);

-- Only one live negotiation per unordered pair per session at a time, so
-- players can't accidentally open two simultaneous trades with each other.
create unique index trades_one_active_pair
  on trades (session_id, least(player_a, player_b), greatest(player_a, player_b))
  where status = 'negotiating';
