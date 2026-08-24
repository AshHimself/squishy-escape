-- watchTrade() in multiplayer.js subscribes to postgres_changes on `trades`.
-- Realtime only broadcasts changes for tables explicitly added to the
-- supabase_realtime publication -- without this, direct queries/RPCs work
-- fine but no change events ever fire over the websocket.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'trades'
  ) then
    alter publication supabase_realtime add table trades;
  end if;
end $$;
