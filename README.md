# Squishy Escape

A 2D side-scroller by **Annie Smith & Ash Smith**.

<p align="center">
  <a href="https://squishy-escape.vercel.app/">
    <img src="https://img.shields.io/badge/%E2%96%B6%20PLAY%20NOW-FF8FC0?style=for-the-badge&logoColor=white&labelColor=A98BE8" alt="Play Squishy Escape now">
  </a>
</p>

<p align="center">
  <b><a href="https://squishy-escape.vercel.app/">squishy-escape.vercel.app</a></b>
</p>

Run right, jump the snacks, squash the 6-7s, outrun the squish wall, and bring
home the **Dumpleningness**. Spend it on better eggs, hatch rarer squishies,
and trade your spares up with the Squishy Trader.

## Playing it

Click **Play Now** above, or download `index.html` and double-click it — it's
still a genuine single file, no build step needed to run it locally, and after
the first load it doesn't need the internet at all. The live version deploys
from this repo to [Vercel](https://squishy-escape.vercel.app/); the old
`ashhimself.github.io/squishy-escape` link now just forwards there. Works in
Safari and Chrome on a Mac, and on an iPad (on-screen buttons appear the
moment you touch the screen).

| Input | Does |
| --- | --- |
| ← → or A / D | run — you can backtrack for coins |
| Space / ↑ / W | jump (hold it down to jump higher) |
| Space again in mid-air | **double bounce** — a second jump, slightly smaller |
| Land on a 6 or a 7 | squash it for coins, and your double bounce comes back |
| Hold jump on the rainbow | fly up — let go to drop |
| Stand on a slope | **slide** down it automatically, arms in the air —<br>hold the uphill direction instead if you want to climb |
| Jump into a brick from below | crack it — 3 hits and it bursts |
| Land on a trampoline | a huge bounce, up near the clouds |
| ⭐ Star | invincible for 11 seconds |
| P or Esc | pause |
| M | mute |

The dumpling **builds up speed** rather than hitting top pace instantly, and if
you hold a direction for about a second it gradually winds up into a sprint.

You get **3 hearts**. Snacks and fidget rings cost a heart; so does falling in a
pit. The **squish wall** ends the run instantly — that's the one that matters.

**Chain your stomps.** Bounce from one 6-7 to the next without touching the
ground and each one pays more: 5, then 10, then 15, then 20. This is the single
best way to get rich — and because squashing a 6-7 gives your double bounce
back, a good chain can keep you in the air a very long time.

## Slopes, planks and bricks

**Slopes.** Some pieces have a hill. Run straight up it — then hold **Down**
on the way over the top and the dumpling throws both arms in the air and
slides, picking up a *lot* more speed than it can run at. Let go, or reach flat
ground, and you coast to a stop. It's the fastest way down a hill and it looks
great.

**Wooden planks.** Brown plank platforms wobble the moment *you* stand on them,
then drop away about half a second later. They rebuild themselves a few seconds
after that, so a missed jump isn't the end. The 6-7s can stand on them all day
without breaking them — the planks only care about you.

**Brick blocks.** Jump up into one from below and it cracks; three hits and it
bursts into rubble, worth a couple of coins, leaving a hole you can jump
straight through. They're built to guard something — a carrot sits directly
over some of them.

## 👕 Skins

A new Hub button, separate from everything else. Two independent things live
here, and neither touches your equipped superpower (that's still the
Collection screen) — you could be flying-powered while wearing a totally
different colour.

**Palettes** — six pastel colourways for the dumpling's body, available from
the very first launch. No squishies needed.

**From your squishies** — every squishy you've ever hatched (owning it is
enough, it doesn't need to be equipped) unlocks a recolour built from that
squishy's own two colours. Hatch Bunny, get a pink-and-white dumpling. Hatch
Cosmic Squish, get a deep starry purple one. It's automatic — add a new
squishy to `SQUISHIES` and it gets a skin for free, no art required.

**Accessories** — four small extras unlocked by general progress rather than
any one squishy: a party hat (200m in a run), a bandana (5 runs finished), a
bow tie (5 different squishies collected), and sunglasses (600m in a run).

## Rarities and superpowers

There are now **five rarities**: Common, Uncommon, Rare, Super Rare, and
**Mythic**. Every Mythic squishy carries a **superpower** — but it only works
while that squishy is **equipped**, and only one can be equipped at a time (tap
it in the Collection screen).

| Squishy | Power | What it does |
| --- | --- | --- |
| 🐰 Bunny | Speedy Feet | Run and sprint noticeably faster |
| 🌻 Sunflower | Big Bounce | Jump and double-bounce much higher |
| 🧀 Cheese Block | Big Squish | Bigger dumpling, steps over taller ledges |
| 🎗️ Glitter Dumplen | Cape Flight | Hold jump in the air to fly — about 10 seconds before you need to land and recharge |

Equip one and the HUD shows a little pill with its icon — for Cape Flight, that
pill counts down your remaining flight time. Land to refuel it.

## ⭐ The star

A **glowing star** turns up now and then. Grab it and you're **invincible for
eleven seconds**, exactly like the star in Super
Mario Bros: run straight through snacks, fidget rings and falling dumplings,
and any 6-7 you touch just pops for coins — you don't even have to land on it.
The dumpling glows with a cycling rainbow rim and the music switches to a fast
168bpm section. The rim blinks when you have about two seconds left.

The one thing the star does *not* save you from is the squish wall. That still
ends the run, so keep moving.

## The wall surges

Every so often the squish wall does more than just creep — it telegraphs (a
pulsing red flash and "WALL SURGE!" across the top of the screen), then, a
little over a second later, bursts forward for about two seconds before
settling back down. It's on its own timer, independent of how close you
actually are to it, so a surge can catch you even mid-obstacle.

There are none of these at all for the first **500m** of a run. From 500m, a
burst is guaranteed to close **10%** of whatever gap you'd built up to the
wall; from 1500m, **20%**; climbing another 10% every 1000m after that, up to
a 60% cap so a very long run doesn't become an instant kill. The camera also
pulls back during a surge to guarantee the wall is genuinely visible on
screen — normally it only follows you, which can leave the wall well off the
left edge if you've got a real lead, and "there's danger somewhere behind you"
isn't much of a threat if you can't see it.

## The background changes day to day

The sky, hills, and everything behind the course rotates through four looks —
Sunny Day, Dusk, Night Sky (moon and stars), and Pastel Storm (rain, the
occasional soft lightning flash) — picked once per calendar day, the same for
everyone that day. Purely cosmetic; the course itself doesn't change.

## 🥕 The magical carrot

Carrots no longer turn up at ground level. Every one is placed **up on a
climb** — a little staircase of platforms, sometimes with a brick block
sitting right underneath it that you have to punch open first. Getting one now
takes real platforming, not just a lucky sidestep.

Grab it and the dumpling gets launched into the sky onto a **mystical rainbow**.

For the next nine and a half seconds you fly along the rainbow road: **hold
jump to climb, let go to drop**. The coins sit right on the rainbow itself, so
the trick is to *ride the curve* rather than fly over it — every coin up there
is worth three times a normal one. A really tidy ride is worth around 150
Dumpleningness, which is most of an egg upgrade in one go.

The squish wall **stops dead while you're up there**, and you keep travelling
the whole time, so a carrot is worth about 85m of free distance on top of the
coins. When the rainbow runs out you float gently back down onto the course and
the run carries on.

**Grab more than half the coins on the rainbow and you get a heart back**, up to
a maximum of five. That is the only way to heal, so a good ride is worth real
survival, not just money.

Special pickups appear roughly every five course pieces, never two close
together, and about 60% of them are stars — so carrots work out at roughly one
every seventeen pieces and stay a lucky find. `CARROT_COIN`, `RAINBOW_TIME`,
`RAINBOW_SPEED`, `STAR_TIME` and `MAX_HEARTS` at the top of the file tune all
of it. `TRAMPOLINE_BOUNCE` sets the trampoline's launch height, and
`TRAMPOLINE_COOLDOWN` must always comfortably exceed the flight time that
height implies (`launch_speed / GRAVITY`, doubled) — set it too short and the
player passes back through the trampoline's own hitbox while still falling,
re-triggers it, and never lands. `CAM_Y_LINE` is how high the player has to
be before the camera starts panning to keep the ground out of view; ordinary
jumps never reach it.

## 🧸 The trampoline

A cute bouncy trampoline sits on the ground here and there, springs and all.
Land on it — actually land, falling onto it — and it gives you a **much bigger
bounce** than a normal jump, up near the cloud layer in the background.

This is deliberately *not* a separate mode like the rainbow ride. There's no
timer, no locked camera, no scripted coin field — you're still inside the
ordinary run the whole time, just launched a long way up by gravity, same as
any other jump. It's a *big* launch: high enough that the ground and hills
scroll completely out of view and you're surrounded by sky and clouds. The
camera only pans vertically for this — ordinary jumps and slopes never touch
it, it eases back to normal automatically once you're back down near the
ground. The music dips into a short, peaceful phrase while you're airborne
from the bounce and hands back to normal the moment you land (or after a
couple of seconds, whichever comes first). Land wherever the arc happens to
put you and keep running. The squish wall doesn't pause for this, and it
still renders in its normal fixed spot on screen — you're never out of the
run.

A handful of coins appear along the bounce's arc, but only for the length of
that one bounce — they're created when you land on the trampoline and removed
the moment the bounce ends, whether you collected them or not. Nothing about
the trampoline adds anything to the world that outlives the bounce itself.

## The music

There are no music files either — every note is built out of oscillators while
you play. The soundtrack has five sections and they're all cheerful major-key
chiptune, plus a sparkly high-register one just for the rainbow ride. It climbs
a section each time the obstacle course starts handing out harder pieces: a little quicker (112 up to 138bpm), an arpeggio joins in, then
a snare, and the melody moves up into a brighter register — but it stays happy
the whole way. Press **M** to mute.

## Two things that changed from the original spec

1. **It's 2D, not 3D.** Annie's spec asked for a run-into-the-screen game like
   Crash Bandicoot. This is a side view instead. The depth is faked with four
   parallax layers so it still feels like you're running through somewhere.
2. **The obstacle course is endless, not a set of levels.** It's built out of
   hand-designed 16-tile pieces, shuffled together, getting meaner the further
   you get. You end a run by dying, and *that's* when you cash out and go
   shopping — so the spec's "finish the course, get money, upgrade the egg"
   loop is all still there.

Everything else is Annie's: the pastel rainbow dumpling with arms and legs, the
dumplings / butters / strawberries / paws / bananas / cheeses / fidget rings as
obstacles, the 6-7 enemies you jump on, the four rarity tiers, the Dumpleningness,
the trader, and the common egg that hatches at the very start.

## Changing the game

Everything is in `index.html`. No build step — edit, save, refresh.

### The bomb squishy

A round, dark little enemy that sits still until you get close (about a tile
and a half), then arms — shaking harder and glowing hotter red the closer it
gets to going off, with a ticking fuse that speeds up too. You've got about
two seconds to either **stomp it** (same as any other enemy — safely defuses
it, pays out on the combo like normal) or get clear. Left alone, it detonates:
damages you if you're still in range, and clears out any other nearby enemies
caught in the blast for a small bonus each.

The explosion itself is randomised — a random palette from four options, and
one of four different shapes (a confetti burst, staggered shockwave rings, a
starburst of spikes, or a small pop followed by a bigger secondary one a
moment later) picked fresh every single time, so no two bombs look the same
going off. Marked `M` in a course template.

### Designing new obstacle courses

Find `const TEMPLATES` (about a third of the way down). Each entry is one piece
of course: **12 rows of exactly 16 characters**.

```
 .  nothing            #  ground block      C  cheese block (solid)
 o  coin               D  dumpling          S  strawberry
 P  paw                N  banana            B  butter
 ?  a RANDOM one of the five snacks above -- different every run
 R  fidget ring (floats and bobs)           6 / 7  the enemies

 F  falling dumpling -- hangs in the air, drops when you walk under it, then
    re-arms in place a couple of seconds later. Put it in an empty row near
    the top; it needs clear air beneath it to fall through.
 W  rolling cheese wheel -- rolls left until it hits a wall or a ledge, then
    starts again from where it was placed.
 Z  bouncing strawberry -- bounces about two and a half tiles, forever.

 =  wooden plank -- solid until YOU stand on it, then it wobbles, drops, and
    rebuilds itself a few seconds later. Enemies don't set it off.
 X  brick block -- solid until you jump into it from below 3 times, then it
    bursts and you can fly straight through. A good place to hide a carrot.
 !  carrot marker -- unlike stars, carrots are ONLY placed here, never
    scattered automatically. Put it up on a climb, a few rows above a
    platform, so reaching it takes real jumping. Two per template max, or
    they stop feeling special.
 >  ramp climbing to the right     <  ramp dropping to the right
 T  trampoline -- a physical object on the ground. Landing on it (falling
    onto it, not just walking past) launches a huge bounce -- not a mode
    switch, just a much bigger version of a normal jump. `TRAMPOLINE_BOUNCE`
    at the top of the file sets how high.
 M  bomb squishy -- stands still, arms when you get close, then a few
    seconds later either you've stomped it (safe) or it detonates
    (`BOMB_FUSE`, `BOMB_PROX`, `BOMB_BLAST` up top control the timing and
    range).
    Ramps are 45 degrees and one tile each, so a hill is a diagonal staircase
    of them. Every ramp needs a solid tile directly underneath it, or the
    dumpling falls straight through. `STEP_UP` is how tall a lip the dumpling
    walks over without stopping -- it has to stay comfortably under one tile,
    or you'd be able to stroll up walls.
```

Magical carrots aren't placed by hand — the game drops them into suitable
pieces on its own, so you don't need a character for them.

`tier` is how mean it is: `0` shows up right away, `3` only appears once you're
about 20 pieces in.

Three rules so the course stays possible:

- The **bottom row must start and end with `#`** so pieces join up.
- A gap in the ground can be at most **4 tiles wide**.
- You can jump **3 tiles up** from a standstill, or about **5 tiles** with a
  well-timed double bounce. Design the main path so it works on the single
  jump — put anything that needs the double bounce out of the way, as a bonus
  for players who've got the timing down.
- Enemies and snacks must sit on the row directly above a solid block, or
  they'll fall.

### Other knobs

- `PALETTES` — the base skin colourways, `ACCESSORIES` — the progress-unlocked
  extras (each has a `need` function that reads `save`). `squishyPalette()` is
  what auto-derives a skin from any squishy's `c1`/`c2` — no per-squishy skin
  art needed.
- `SQUISHIES` — the collection. Add one and it appears in the book automatically.
  `shape` picks how it's drawn (`dumpling`, `round`, `block`, `berry`, `banana`,
  `cheese`, `paw`, `cloud`, `ring`, `star`, `peach`, `pickle`, `tomato`,
  `flower`, `sloth`, `bunny`, `cheeseblock`, `mango`), `r` is the rarity
  (0–4, where 4 is Mythic), and `rainbow` / `stars` / `shine` are optional
  sparkle. Give a Mythic squishy `power` (`speed` / `jump` / `big` / `fly`)
  plus `powerName` and `powerDesc` to make it grant a superpower when equipped
  — see the constants block for the multipliers each one uses.
- `EGGS` — each egg's hatch odds (one number per rarity, five now) and what the
  next egg costs. `RARITY` / `RARITY_BG` / `RARITY_INK` all need a matching
  entry if you add another tier.
- The constants at the top — `JUMP_V`, `MAX_RUN`, `GRAVITY`, `WALL_BASE`,
  `WALL_MAX` — control how it feels. Turn `WALL_BASE` down to make it kinder.
  `DOUBLE_V` is how strong the mid-air bounce is compared to a normal jump.
  `COYOTE` and `JUMP_BUFFER` are the two forgiveness windows around a jump —
  how long after walking off a ledge it still fires, and how early a press
  still counts. `APEX_BAND` / `APEX_GRAVITY_MULT` control the hang-time at the
  top of a jump (how wide the "near the top" window is, and how much weaker
  gravity feels inside it) — this only ever affects the player, `moveBody`'s
  gravity is a per-call parameter so enemies and movers are untouched.
  `SURGE_MIN` / `SURGE_MAX` / `SURGE_WARN` / `SURGE_BURST` / `SURGE_MULT` tune
  the wall's periodic surges — how often, how long the telegraph and the burst
  each last, and how much faster the burst is. `THEMES` is the list of
  background looks; add another entry (four colours, plus `sun`/`night`/`storm`
  flags) and it joins the daily rotation automatically.
  `RUN_ACCEL` sets how quickly it gets up to speed, `SPRINT_RUN` how fast the
  wind-up sprint goes, and `SLIDE_ACCEL` / `SLIDE_MAX` how fierce a slope
  slide is. `WOOD_SHAKE` and `WOOD_BACK` are the plank's warning wobble and
  how long it takes to rebuild. `BRICK_HITS` is how many headbutts a brick takes to burst.
  `WALL_BASE` / `WALL_GAIN` / `WALL_MAX` control the wall's steady speed
  (separate from the surges above).
  `POWER_SPEED_MULT` / `POWER_JUMP_MULT` / `POWER_BIG_SCALE` / `FLY_TIME` /
  `FLY_LIFT` are the four superpowers' strength.
- `SECTIONS` — the music. Each entry is 16 sixteenth-notes: `lead` is a list of
  MIDI note numbers (`null` is a rest), `roots` is the bassline's four chords,
  and `kick` / `snare` / `hat` are patterns where `x` is a hit and `.` is a rest.

### The economy

Hatching stays cheap (25 🪙) so the early loop feels good fast. Egg upgrades
get steep near the top on purpose — the jump from Legendary to the final
**Mythic Egg** costs 5460, because Mythic squishies (and their superpowers)
are meant to be a real chase, not a given. (Egg upgrade costs are +30% on
Annie's request — was 100/300/750/1700/4200, now 130/390/975/2210/5460.)

### Every course piece can come out mirrored

Each hand-built 16×12 piece can get stamped flipped left-right, at random,
each time it's used — ramps run the other way, patrols walk the other way,
coin arcs curve the other way. It's the same 36 pieces underneath, but it
roughly doubles how varied the course feels without hand-drawing a single new
one. Every piece was checked in both orientations before this shipped —
mirroring a ramp swaps its direction, everything else just needs its column
reversed.

### idfka

Type **IDFKA** while on the main menu and it unlocks every egg tier straight
to Mythic, with a "GOD MODE ACTIVATED" splash and a little synthesized power-up
sting — an original jingle in the spirit of the classic FPS cheat this is
named after, not a sample of it. Purely a fun Easter egg for testing or
showing off the top-tier squishies; it doesn't touch your Dumpleningness or
your collection.

### Poking at it while it runs

Open the browser console and use `__SE`:

```js
__SE.save.money = 9999        // rich
__SE.save.eggTier = 5         // legendary egg
__SE.persist()                // save it
__SE.reset()                  // wipe the save and start over
```

Progress is saved in the browser on that device, so each computer has its own
collection.

## Multiplayer trading (Trade Online)

Up to 3 people can join a live room together and trade squishies with each
other in real time. It's entirely optional — skip it and the game plays
exactly as before, fully offline.

**How it works for a player:** tap **🌐 Trade Online** on the hub, pick a
nickname and a 4-digit PIN (no email, no password), then either create a
room (you get a short code) or join a friend's with their code. Up to 3
people per room. Tap **Trade** next to someone to open a trade sheet, tap
your squishies to offer them, **Send Offer**, then both people tap
**Confirm Trade** to swap.

**How it's built:** [Supabase](https://supabase.com) — Postgres for
identity/inventory/sessions/trades, Realtime for the live roster and trade
sync, and Anonymous Auth as the transport underneath the nickname+PIN login.
Everything server-side lives in `security definer` Postgres functions
(`supabase/migrations/0005_rpc_functions.sql`) called directly from the
browser — there's no separate backend server or serverless function. See
`multiplayer.js` for the client side and `supabase/migrations/` for the
database schema.

### Leaderboard anti-cheat

The best-distance leaderboard reads `player_saves.best_dist` / `best_money`,
and those two columns are **not writable from the browser** — direct `UPDATE`
on them is revoked from the `authenticated` role
(`supabase/migrations/0013_vac_score_submission.sql`). A score only lands on
the board through `submit_score()`, a `security definer` RPC that:

- range-checks the run against ceilings in the `score_limits` table (max
  distance, max coins-per-metre, min milliseconds-per-metre using a
  client-measured run timer),
- rate-limits submissions per player (a minimum gap between accepted scores
  and a rolling hourly cap), and
- writes an audit row to `player_score_audit` for every accepted **and**
  rejected call.

A rejected run stays saved locally; it just doesn't reach the board. The
thresholds are deliberately loose (the dumpling tops out near 9 m/s, so they
only bite on tampering) and live in a table so they can be widened with a
single `UPDATE` if a genuine run ever trips one — no redeploy.

This stops drive-by console tampering (`MP.updateSave({ best_dist: 9e9 })`
used to work) and absurd values. It does **not** stop a hand-crafted
`submit_score()` call with in-range lies — the sim still runs in the browser
and the anon key is public, so fully trustworthy scores would need the run
itself simulated server-side, which this one-file game has no backend for.
`player_score_audit` is what a later pass would mine to catch that.

### Setting up your own Supabase project

1. Create a free project at [supabase.com](https://supabase.com).
2. In **Authentication → Providers**, enable **Anonymous Sign-Ins**.
3. Push the schema: `npx supabase link --project-ref <your-project-ref>`
   then `npx supabase db push` from this directory (needs `npx supabase
   login` first).
4. Copy your project's URL and `anon` public key from **Project Settings →
   API**, and put them in `multiplayer.js` (`SB_URL` / `SB_ANON_KEY` near
   the top). Both are meant to be public — the database is protected by Row
   Level Security, not by keeping the key secret.
5. Refresh `index.html` — the **Trade Online** button lights up once
   `multiplayer.js` can reach your project.

You can also point at a project without editing the file, e.g. for testing
a second environment: `index.html?sb=https://xxx.supabase.co&key=xxxx`.

## Deploying

The live site is a Vercel project (`vercel.json` and `.vercel/` in this repo
link it) deployed straight from this folder — there's no build step, it just
serves `index.html` as-is. To push a change live:

```bash
vercel --prod
```

That's it — no GitHub integration is wired up, so pushing to `main` does
**not** auto-deploy; running the command above is what actually publishes.
`ashhimself.github.io/squishy-escape` is kept alive only as a redirect (its
own `gh-pages` branch, decoupled from `main`) for anyone with the old link.

## Versions

The version is shown on the main menu, under the title.

- **v1.10.1** — surges now start at 500m instead of 1000m (severity re-anchors
  to the new start too, so it's a real 10% right away rather than "surges
  happen but do nothing" until 1000m).
- **v1.10.0** — the squish wall's surges are now distance-gated (none before
  1000m) and escalate every 1000m after that (10%, 20%, 30%, ... up to a 60%
  cap of the current gap, guaranteed to close), and the camera now guarantees
  the wall is actually visible on screen during one. New enemy: the bomb
  squishy — arms on proximity, a few seconds to stomp it safely or get clear,
  a randomised explosion (one of four shapes, four palettes) if it goes off,
  with a small area-clear bonus for any other enemies caught in the blast.
- **v1.9.0** — a real hang-time at the top of a jump; landing and stomp-chain
  screen shake now scale with how hard the impact actually was, instead of
  being a flat amount every time; coyote time and jump buffer both a little
  more forgiving; the squish wall now periodically telegraphs and bursts to
  over double speed for a couple of seconds; the background rotates through
  four looks (day/dusk/night/storm), one per calendar day.

- **v1.8.2** — leaderboard anti-cheat. `player_saves.best_dist` / `best_money`
  can no longer be written directly from the browser; scores only reach the
  board through the `submit_score()` RPC, which sanity-checks each run
  (distance/coin ceilings, a run-timer speed check), rate-limits per player,
  and audits every call. Any values already sitting above the ceilings from
  the old direct-write path are clamped on migrate. See "Leaderboard
  anti-cheat" above.
- **v1.8.1** — the trampoline launches much higher (high enough that the
  camera now pans vertically to keep the ground out of view entirely), and
  its sky coins are spawned fresh per bounce and cleared afterward rather
  than sitting statically in the course. Also fixes a real bug the height
  increase introduced: the re-trigger cooldown was shorter than the new,
  longer flight time, so the player could catch the trampoline again on the
  way down and bounce forever without landing.
- **v1.8.0** — a new Skins hub section: six always-available palettes, a
  recolour auto-derived from every squishy you've hatched, and four
  accessories unlocked by general progress. Fully independent from your
  equipped superpower.
- **v1.7.1** — the IDFKA cheat now also matches on e.key, not just e.code, so
  it's not thrown off by virtual keyboards or unusual input methods.
- **v1.7.0** — the trampoline no longer switches into a separate cloud mode;
  it's just a much bigger jump now, with a short peaceful music dip while
  you're airborne from it. Trampolines are half as common. Every course piece
  can now come out mirrored for more variety. An `IDFKA` cheat code on the
  main menu unlocks every egg tier. Egg upgrade costs are up 30% on Annie's
  request.
- **v1.6.0** — a fifth rarity (Mythic) with four equippable superpowers
  (speed, higher jump, bigger size, cape flight); nine new squishies; a
  trampoline that bounces you into a calm cloud bonus round with its own
  peaceful music; sliding is now automatic (no down button — hold the uphill
  direction to climb instead); a faster, harder squish wall; and a friendlier
  hatch cost with a steeper climb toward the top egg.
- **v1.5.0** — water and piranhas removed; destructible brick blocks (3 hits
  to burst); carrots now only spawn up on a climb, never at ground level.
- **v1.4.1** — you can actually walk up the hills now, not just slide down them.
- **v1.4.0** — slopes you can slide down with your arms in the air, wooden
  planks that give way under you (but not under enemies), water with piranhas,
  a longer star, and a gentler acceleration curve with a wind-up sprint.

- **v1.3.0** — the star (invincibility), falling dumplings, rolling cheese
  wheels, bouncing strawberries, randomised snacks, a heart back for a good
  rainbow ride, fewer 6-7s, rarer carrots.
- **v1.2.0** — the magical carrot and the rainbow ride.
- **v1.1.0** — double bounce, 8-bit soundtrack, on-screen controls.
- **v1.0.0** — the game.
