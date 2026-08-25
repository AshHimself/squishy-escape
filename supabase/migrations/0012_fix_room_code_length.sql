-- gen_room_code() used `(random() * length(alphabet))::int + 1` as the
-- substr position. Postgres's float-to-int cast ROUNDS to nearest, not
-- truncates -- so when random() landed in roughly the top 1/64th of its
-- range, `(random()*32)::int` rounded up to 32 instead of capping at 31,
-- giving position 33 on a 32-char alphabet. substr() past the end of a
-- string returns '' (not an error), so string_agg silently dropped that
-- character -- confirmed in the wild: 2 of the last 10 room codes came out
-- 4 characters instead of 5. floor() truncates correctly, matching the
-- intended [1, length] range.

create or replace function gen_room_code()
returns text
language sql
volatile
as $$
  select string_agg(substr(alphabet, floor(random() * length(alphabet))::int + 1, 1), '')
  from (values ('ABCDEFGHJKMNPQRSTUVWXYZ23456789')) as a(alphabet),
       generate_series(1, 5);
$$;
