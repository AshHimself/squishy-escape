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
| ⭐ Star | invincible for 8.5 seconds |
| P or Esc | pause |
| M | mute |

You get **3 hearts**. Snacks and fidget rings cost a heart; so does falling in a
pit. The **squish wall** ends the run instantly — that's the one that matters.

**Chain your stomps.** Bounce from one 6-7 to the next without touching the
ground and each one pays more: 5, then 10, then 15, then 20. This is the single
best way to get rich — and because squashing a 6-7 gives your double bounce
back, a good chain can keep you in the air a very long time.

## ⭐ The star

A **glowing star** turns up every ten course pieces or so. Grab it and you're
**invincible for eight and a half seconds**, exactly like the star in Super
Mario Bros: run straight through snacks, fidget rings and falling dumplings,
and any 6-7 you touch just pops for coins — you don't even have to land on it.
The dumpling glows with a cycling rainbow rim and the music switches to a fast
168bpm section. The rim blinks when you have about two seconds left.

The one thing the star does *not* save you from is the squish wall. That still
ends the run, so keep moving.

## 🥕 The magical carrot

Every so often you'll find a **glowing carrot** floating above the course. Grab
it and the dumpling gets launched into the sky onto a **mystical rainbow**.

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
  `cheese`, `paw`, `cloud`, `ring`, `star`), `r` is the rarity (0–3), and
  `rainbow` / `stars` / `shine` are optional sparkle.
- `EGGS` — each egg's hatch odds and what the next one costs.
- The constants at the top — `JUMP_V`, `MAX_RUN`, `GRAVITY`, `WALL_BASE`,
  `WALL_MAX` — control how it feels. Turn `WALL_BASE` down to make it kinder.
  `DOUBLE_V` is how strong the mid-air bounce is compared to a normal jump.
- `SECTIONS` — the music. Each entry is 16 sixteenth-notes: `lead` is a list of
  MIDI note numbers (`null` is a rest), `roots` is the bassline's four chords,
  and `kick` / `snare` / `hat` are patterns where `x` is a hit and `.` is a rest.

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

- **v1.3.0** — the star (invincibility), falling dumplings, rolling cheese
  wheels, bouncing strawberries, randomised snacks, a heart back for a good
  rainbow ride, fewer 6-7s, rarer carrots.
- **v1.2.0** — the magical carrot and the rainbow ride.
- **v1.1.0** — double bounce, 8-bit soundtrack, on-screen controls.
- **v1.0.0** — the game.
