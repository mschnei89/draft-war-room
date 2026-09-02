# Draft War Room — CG FF

A single-page assistant that sits live on top of your Sleeper draft and tells you who to
take next. It reads the draft from Sleeper's public API every 4 seconds, so picks made by
anyone in the league show up automatically — you do nothing but look at it.

League: **CG FF** (`1389690549467889664`) · 10 teams · 14 rounds · snake · full PPR

## Where it lives

**https://mschnei89.github.io/draft-war-room/**

That is the one to use — it works on your phone and on any computer, with nothing running
locally. Sleeper's API allows cross-origin reads, so the hosted page talks to it directly.

Offline alternative: double-click **`Open Draft War Room.cmd`** to serve the same file from
this folder on `http://localhost:8777`.

Everything is in `index.html`. No build step, no dependencies, no install.

## Is it live?

The pill in the top bar answers that. It reads **LIVE · synced Ns ago**, where the counter
ticks up every second and snaps back to 0 each time a poll lands (every 4 seconds), with a
brief green flash. If a page is frozen or your connection has dropped, the counter keeps
climbing and the pill turns amber: **RECONNECTING · last sync 34s ago**.

Nothing needs to be started or refreshed. Open the page and leave it open.

## On a phone

Below 760px wide the layout switches to one section at a time, chosen with the
**Pick / Board / My team** buttons under the header:

- **Pick** — the recommendation, why, and the next four options.
- **Board** — best available, trimmed to the columns that matter on a small screen
  (player, position, +Lineup, ADP, Gone%). The rest come back on a wide screen.
- **My team** — your roster, cost of waiting, and the pick feed.

When the draft reaches your turn it jumps back to **Pick** on its own.

## Alerts when it is your turn

Press the **bell button** in the top bar once, and allow notifications. After that you get:

- a **five-tone alarm** the moment the draft reaches your pick,
- a **desktop/phone notification** naming who to take and why,
- a single beep and an "on deck" notification when you are **two picks away**,
- the browser tab title flashing **\*\* YOUR PICK \*\***.

You have to press the bell each time you open the page — browsers only allow sound and
notification permission to be armed by a real click.

**On a phone:** open the URL, then use *Add to Home Screen* and launch it from that icon.
On iOS this is required for web notifications to work at all; on Android Chrome the page
alone is enough. Either way the page must stay open for the alarm to sound.

There is no SMS. Nothing in this project can send a text message.

## What it is doing

The interesting part is that it does **not** rank players off a generic cheat sheet.

**1. It scores players in your league's actual scoring.**
It pulls Sleeper's 2026 stat projections and applies your league's `scoring_settings` to the
raw stat lines. This matters here: your league scores kickers at **0.1 points per field-goal
yard with no flat points per make**, which is unusual — Sleeper's own displayed point totals
are wrong for your league, off by 5–7 points on the kickers.

Team defenses are the exception: their scoring is bracket-based on points allowed, which
can't be reconstructed from a season-long projection, so those fall back to Sleeper's totals.

**2. Replacement level comes from your roster slots, not a rule of thumb.**
With 10 teams starting QB/RB/RB/WR/WR/TE/FLEX/K/DEF, the last startable player at each
position is computed directly — and the FLEX slots are handed to whichever RB/WR/TE actually
deserve them rather than being assumed.

**3. It values a player by what he adds to *your* starting lineup.**
Not by VORP. This is the part that makes it useful. VORP alone breaks late: by round 8 every
remaining running back is below replacement, so a "needed" RB scores worse than a useless 5th
WR. Instead, each candidate is dropped into your roster, the best legal lineup is re-solved,
and the difference is his value. Unfilled slots are valued at a waiver-level fill, so filling
an empty RB2 is worth a lot and a 6th WR is worth almost nothing.

**4. It asks "what do I gain by taking him NOW rather than waiting?"**
Every candidate's ADP is modelled as a normal distribution around his average draft position,
widening later in the draft where the market is less certain. From that it computes the odds
each player survives to your next pick, and therefore the expected best player still available
at each position when you next pick. The recommendation maximises **value now minus value if
you wait** — which is what actually decides a draft pick.

That single idea makes the assistant hold kickers and defenses until the end without being
told to: they are always still there, so acting early gains nothing. It also makes it jump on
a tier cliff early, because after the cliff the wait is expensive.

Two pieces of judgement are encoded explicitly rather than derived, because projections can't
express them:

- `STREAM_DISCOUNT` (0.45) — K and D/ST are churned off waivers weekly, so a pick spent on one
  buys less than its projection suggests.
- Once you have as many empty starting slots as you have picks left, waiting stops being an
  option and anything filling a hole is scored at full value. That is what guarantees you
  finish the draft with a legal lineup.

## Reading the screen

| | |
|---|---|
| **+Lineup** | Points he adds to your starting lineup right now. The ranking is built on this. |
| **VORP** | Points above the last startable player at his position. Shown for context. |
| **Gone%** | Modelled chance he is drafted before your next pick. |
| **vs Pick** | His ADP minus the current pick. Strongly negative = he is falling to you. |
| **Fit** | The final score: gain-from-acting-now, plus a faint tilt toward raw value to break ties. |
| **CLIFF** | He is the last man in his tier — the next player at the position is a real step down. |
| **Cost of waiting a round** | Per position, the lineup points you give up by passing now and taking whoever survives to your next pick. The longest bar is where the board is about to break. |

The team selector in the top right controls whose draft slot it advises for. It defaults to
**Schneids (slot 9)** and remembers your choice.

## Caveats worth knowing

- Before the draft starts, no picks exist, so the board it plans against is hypothetical. The
  numbers sharpen the moment real picks land.
- Projections are Rotowire's, served through Sleeper. They are one opinion, not truth.
- Bye weeks are not modelled — Sleeper's API doesn't expose them cleanly, and inventing them
  would be worse than omitting them.
- Player projections are cached in your browser for 6 hours. The `↻` button forces a refresh
  of the draft state; clearing site data forces a full re-fetch of projections.
- The repo is public, which is what GitHub Pages requires on a free account. It contains your
  league ID — enough for anyone to look up the same public draft on Sleeper, and nothing more.
  No credentials or private data are in it.
