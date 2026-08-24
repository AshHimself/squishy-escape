# Squishy Escape

A 2D side-scroller by **Annie Smith & Ash Smith**.

<p align="center">
  <a href="https://ashhimself.github.io/squishy-escape/">
    <img src="https://img.shields.io/badge/%E2%96%B6%20PLAY%20NOW-FF8FC0?style=for-the-badge&logoColor=white&labelColor=A98BE8" alt="Play Squishy Escape now">
  </a>
</p>

<p align="center">
  <b><a href="https://ashhimself.github.io/squishy-escape/">ashhimself.github.io/squishy-escape</a></b>
</p>

Run right, jump the snacks, squash the 6-7s, outrun the squish wall, and bring
home the **Dumpleningness**. Spend it on better eggs, hatch rarer squishies,
and trade your spares up with the Squishy Trader.

## Playing it

Click **Play Now** above, or download `index.html` and double-click it. That's
the whole install — one file, no build step, no downloads, and after the first
load it doesn't need the internet at all. Works in Safari and Chrome on a Mac,
and on an iPad (on-screen buttons appear the moment you touch the screen).

| Input | Does |
| --- | --- |
| ← → or A / D | run — you can backtrack for coins |
| Space / ↑ / W | jump (hold it down to jump higher) |
| Space again in mid-air | **double bounce** — a second jump, slightly smaller |
| Land on a 6 or a 7 | squash it for coins, and your double bounce comes back |
| Hold jump on the rainbow | fly up — let go to drop |
| Stand on a slope | **slide** down it automatically, arms in the air —<br>hold the uphill direction instead if you want to climb |
| Jump into a brick from below | crack it — 3 hits and it bursts |
| Land on a trampoline | bounce into a calm cloud break |
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
of it.

## 🧸 The trampoline

A cute bouncy trampoline sits on the ground here and there, springs and all.
Land on it — actually land, falling onto it — and it flings you way up into a
**calm cloud bonus round**, no glowing pickup needed, just a good jump.

The clouds are the carrot's gentler sibling: same shape (fly around, grab
coins, land back on the course when it ends), but slower, drifts more, worth
less per coin, and the music turns properly peaceful — soft, sparse, almost no
drums. It's the chill option next to the rainbow's big flashy one. The squish
wall waits for you here too.

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
    onto it, not just walking past) launches the calm cloud bonus round.
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
  `RUN_ACCEL` sets how quickly it gets up to speed, `SPRINT_RUN` how fast the
  wind-up sprint goes, and `SLIDE_ACCEL` / `SLIDE_MAX` how fierce a slope
  slide is. `WOOD_SHAKE` and `WOOD_BACK` are the plank's warning wobble and
  how long it takes to rebuild. `BRICK_HITS` is how many headbutts a brick takes to burst.
  `WALL_BASE` / `WALL_GAIN` / `WALL_MAX` control how fast the squish wall is.
  `POWER_SPEED_MULT` / `POWER_JUMP_MULT` / `POWER_BIG_SCALE` / `FLY_TIME` /
  `FLY_LIFT` are the four superpowers' strength.
- `SECTIONS` — the music. Each entry is 16 sixteenth-notes: `lead` is a list of
  MIDI note numbers (`null` is a rest), `roots` is the bassline's four chords,
  and `kick` / `snare` / `hat` are patterns where `x` is a hit and `.` is a rest.

### The economy

Hatching stays cheap (25 🪙) so the early loop feels good fast. Egg upgrades
get steep near the top on purpose — the jump from Legendary to the final
**Mythic Egg** costs 4200, because Mythic squishies (and their superpowers)
are meant to be a real chase, not a given.

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

## Versions

The version is shown on the main menu, under the title.

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
