# Levels

Structure, difficulty curve and disc progression ([DIS-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/51)).

## Structure
- **8 levels** (levels 9 and 10 are optional, only if the main content is finished and tested).
- **Each level is a short screen** of 2–4 minutes. Dying restarts the screen.
- **Level select:** yes, a Super Mario style level select screen ([[Controls and UI]]).
- **Solutions:** a single solution per level for now ([DIS-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/50)). Levels 9 and 10 may have several solutions, since they are out of scope if time runs short.

## Design rules ([DIS-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/50))
1. Each level **introduces** an idea, **tests** it in a safe space and **combines** it with what came before.
2. Nothing new without teaching it first: the first time an object or enemy appears, the risk is low.
3. No dead ends: you can always restart with L / Y.
4. Each level has a template with start, exit and objects ready to place.

**Review checklist** ([DIS-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/50)): it can be solved as designed · no dead ends · it reads without text · colors are distinguishable under colorblind simulators · it lasts 2–4 minutes.

## Difficulty curve
| Level | New idea | Discs | Filters | Abilities | Hazards |
|---|---|---|---|---|---|
| 1 | Grey vs. color; first door with the right filter | Right | R, Y, B | — | Falls |
| 2 | Two colors: choose the right filter | Right | R, Y, B | Yellow (super jump) | Falls, spikes |
| 3 | Objects that only appear under one filter | Right | R, Y, B | Red (weight), blue (float) | First enemy |
| 4 | Get the left disc and try it out | Right + left | + mixes | — | Enemies |
| 5 | Simple mixes (orange, green, violet) | Both | 6 | — | Enemies |
| 6 | Combine mixes with obstacles | Both | 6 | Review of all 3 | Enemies invisible under their filter |
| 7 | Puzzle combining every rule | Both | 6 | All | All |
| 8 | Final level | Both | 6 | All | All |
| 9–10 | Extras _(out of scope)_ | Both | 6 | — | — |

**Mixes needed in each level:** _(pending, filled in by level design in [DIS-6](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/52) to [DIS-8](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/64))_.

## The left disc (level 4)
- **Where you get it:** at the start of the level.
- **How you get it:** a pickup in the level. Once collected, the disc appears overlapping the first one and the viewer's view changes: this is the perspective *Shift*.

## Hints
- **When they are offered:** always. Hints are permanent, so there is no timer or button.
- **How they are shown:** _(pending)_
- **How many:** one per level.

## Ending
After level 8 the **victory screen** is shown, and then the end screen. A final cutscene is possible _(if time allows)_.
