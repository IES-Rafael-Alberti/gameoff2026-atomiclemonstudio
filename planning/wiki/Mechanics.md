# Mechanics

This page also holds the color rules and the mix table ([DIS-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/48)), used by programming and level design.

## Core loop
Explore → spot the colored obstacles → turn the discs to reveal, open or trigger an ability → reach the exit → next level.

## The Chromoscope
- **Right disc:** available from level 1. It sits in front.
- **Left disc:** obtained in level 4. It sits behind the right one and is shown overlapping it; the view changes when you get it.
- **Each disc has 4 positions:** clear, red, yellow and blue. Order on the disc: _(pending)_.
- **Rotation:** each press moves one position. The left disc turns clockwise and the right disc counterclockwise. 4 presses bring it back to the start.
- **Transition:** disc rotation animation. Duration: _(proposal: 0.25 s)_. The rule change (what is solid and what isn't) applies: _(pending: at the start or at the end of the animation)_.

## Mix table
The active filter is the combination of both discs:

| Left disc \ Right disc | Clear | Red | Yellow | Blue |
|---|---|---|---|---|
| **Clear** | No filter | Red | Yellow | Blue |
| **Red** | Red | Red | Orange | Violet |
| **Yellow** | Yellow | Orange | Yellow | Green |
| **Blue** | Blue | Violet | Green | Blue |

Before level 4 only the first row exists (filters: none, red, yellow, blue).

## Color rules
| Element | No filter | Filter of its color | Filter of another color |
|---|---|---|---|
| Neutral scenery | Grey, solid | Tinted with the filter, solid | Tinted with the filter, solid |
| Colored object (door, wall, platform) | Grey by luminance, solid | Transparent and passable | Solid; look is a _team debate_ |
| Hidden object (platform, key) | Not visible | Appears | Not visible |
| Colored enemy | Grey by luminance | Invisible, but still deadly | Visible |

- **Grey by luminance:** yellow is the lightest grey and blue the darkest.
- **Mixes are colors in their own right:** a violet object only reacts to the violet filter; under red or blue it behaves like any other color.
- **Objects of another color under a filter:** _team debate_. Options: "corrupted", black, or the mixed color. The team also has to decide what you see, for example, with a blue object under the violet filter.
- **Hidden objects without their filter:** do they physically exist (can they be stood on or picked up)? _(pending)_
- **Player inside an object that becomes solid:** _(pending)_

## Abilities by color
Each color has its own ability. It is active while its filter is on _(proposal)_.

| Color | Feeling | Ability | Status |
|---|---|---|---|
| Red | Deep | Weight: falls faster, breaks cracked floors, pushes blocks | In scope |
| Blue | Aquatic | Float: lower gravity, swims in water areas | In scope |
| Yellow | Wild | Super jump / wall jump | In scope |
| Green | Earthy | Climb vines | _(out of scope)_ |
| Violet | Magical | Phase through thin walls | _(out of scope)_ |
| Orange | Solar | Horizontal dash | _(out of scope)_ |

If the secondary abilities don't make it, those colors only reveal and open. Are abilities passive or triggered with a button? _(pending)_

## Player movement
- **Basics:** walk, jump and interact (switches, keys).
- **Game feel** _(proposal)_: variable jump height (release early = lower jump), *coyote time* (≈0.1 s to jump right after leaving a ledge) and *jump buffer* (≈0.1 s before landing). They keep the challenge in the puzzle, not in precision.
- **Parameters** (speed, jump height, gravity): set during the blockout ([DIS-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/49)).

## Death and restart
- **You die from:** spikes, falls and enemies.
- **On death:** the character darkens and the screen restarts. There are no checkpoints: screens are short.
- **Manual restart:** R / Y at any time.
