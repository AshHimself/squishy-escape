-- Cloud mirror of the client's freshSave() (index.html) plus per-squishy
-- quantities. Only relevant while a player is registered / in a
-- multiplayer session -- local localStorage stays authoritative offline.

create table player_saves (
  player_id  uuid primary key references players(id) on delete cascade,
  money      int not null default 0,
  egg_tier   int not null default 1,
  equipped   text,
  best_dist  int not null default 0,
  best_money int not null default 0,
  runs       int not null default 0,
  muted      boolean not null default false,
  skin       text not null default 'classic',
  accessory  text,
  updated_at timestamptz not null default now()
);

create table player_inventory (
  player_id  uuid not null references players(id) on delete cascade,
  squishy_id text not null,
  qty        int not null default 0 check (qty >= 0),
  primary key (player_id, squishy_id)
);
create index player_inventory_player_idx on player_inventory (player_id);
