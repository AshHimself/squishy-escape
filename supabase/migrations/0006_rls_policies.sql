-- Row Level Security. players/player_auth_links stay ungranted entirely
-- (see 0001) -- everything below is what a logged-in device is allowed to
-- touch directly, in addition to the RPCs in 0005.

alter table player_saves enable row level security;
alter table player_inventory enable row level security;
alter table sessions enable row level security;
alter table session_players enable row level security;
alter table trades enable row level security;

grant select, insert, update on player_saves to authenticated;
grant select, insert, update on player_inventory to authenticated;
grant select on sessions to authenticated;
grant select on session_players to authenticated;
grant select on trades to authenticated;

create policy player_saves_self on player_saves
  for all
  using (player_id = current_player_id())
  with check (player_id = current_player_id());

create policy player_inventory_self on player_inventory
  for all
  using (player_id = current_player_id())
  with check (player_id = current_player_id());

-- security definer so it can check session_players without recursing back
-- into that table's own RLS policy below.
create or replace function is_session_member(p_session_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from session_players
    where session_id = p_session_id and player_id = current_player_id() and left_at is null
  );
$$;

create policy sessions_member_read on sessions
  for select using (is_session_member(id));

create policy session_players_member_read on session_players
  for select using (is_session_member(session_id));

-- Trades are only visible to the two parties, not the rest of the session --
-- bystanders get a lightweight broadcast summary instead (see multiplayer.js).
create policy trades_party_read on trades
  for select using (current_player_id() in (player_a, player_b));
