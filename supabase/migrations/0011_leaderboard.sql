-- Public best-distance leaderboard across all registered players. Callable
-- with just the anon API key -- no sign-in required to *view* it, since the
-- whole point is to tempt a not-yet-registered kid into signing up. Only
-- exposes nickname + scores, nothing from `players` beyond the nickname.

create or replace function get_leaderboard(p_limit int default 10)
returns table(nickname text, best_dist int, best_money int)
language sql
stable
security definer
set search_path = public
as $$
  select p.nickname, s.best_dist, s.best_money
  from player_saves s
  join players p on p.id = s.player_id
  where s.best_dist > 0
  order by s.best_dist desc, s.best_money desc
  limit greatest(1, least(coalesce(p_limit, 10), 100));
$$;
