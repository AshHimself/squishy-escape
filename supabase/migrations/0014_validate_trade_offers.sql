-- propose_trade / update_trade_offer (0005) took the offer jsonb array
-- straight from the browser with no shape check at all -- only
-- apply_trade_swap, at confirm time, ever looked at it, and only for
-- "do you own enough". A negative qty slipped through that guard:
--
--   offer_a = [{ "squishy_id": "cosmic", "qty": -3 }]
--   -> swap does  qty = qty - (-3)   on the proposer   (mint +3)
--   -> and        qty = qty + (-3)   on the counterparty (drain -3)
--
-- i.e. a confirmed trade could run backwards. The `qty >= 0` CHECK on
-- player_inventory (0002) rolls back the drain-below-zero case, but the
-- proposer-mints / partial-drain case completes if the counterparty
-- confirms. Validate the offer shape up front instead, in both RPCs.

create or replace function assert_valid_offer(p_offer jsonb)
returns void
language plpgsql
immutable
as $$
declare
  item jsonb;
begin
  if p_offer is null then
    return;                              -- treated as '[]' by the callers
  end if;
  if jsonb_typeof(p_offer) <> 'array' then
    raise exception 'bad_offer';
  end if;
  if jsonb_array_length(p_offer) > 50 then
    raise exception 'bad_offer';         -- no legitimate offer is this long
  end if;
  for item in select * from jsonb_array_elements(p_offer) loop
    if jsonb_typeof(item) <> 'object'
       or coalesce(item->>'squishy_id', '') = ''
       or char_length(item->>'squishy_id') > 64
       or item->>'qty' is null
       or (item->>'qty') !~ '^[1-9][0-9]{0,3}$'   -- 1..9999, positive integer, no sign/decimal
       or (item->>'qty')::int > 999 then
      raise exception 'bad_offer';
    end if;
  end loop;
end;
$$;

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
  perform assert_valid_offer(p_offer);
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
  perform assert_valid_offer(p_offer);

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
