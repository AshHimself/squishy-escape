# Squishy Escape

A 2D side-scroller by **Annie Smith, Ash Smith & Computer Smith**.

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
| P or Esc | pause |
| M | mute |

You get **3 hearts**. Snacks and fidget rings cost a heart; so does falling in a
pit. The **squish wall** ends the run instantly — that's the one that matters.

**Chain your stomps.** Bounce from one 6-7 to the next without touching the
ground and each one pays more: 5, then 10, then 15, then 20. This is the single
best way to get rich — and because squashing a 6-7 gives your double bounce
back, a good chain can keep you in the air a very long time.

## The music

There are no music files either — every note is built out of oscillators while
you play. The soundtrack has five sections and they're all cheerful major-key
chiptune. It climbs a section each time the obstacle course starts handing out
harder pieces: a little quicker (112 up to 138bpm), an arpeggio joins in, then
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
 R  fidget ring (floats and bobs)           6 / 7  the enemies
```

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
