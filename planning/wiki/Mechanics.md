# Mechanics

This page also holds the color rules and the mix table ([DIS-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/48)), used by programming and level design.

## Core loop
Explore → spot the colored obstacles → turn the discs to reveal, open or trigger an ability → reach the exit → next level.

## The Chromoscope
- **Right disc:** available from level 1. It sits in front.
- **Left disc:** obtained at the start of level 4. It sits behind the right one and is shown overlapping it; the view changes when you get it.
- **Each disc has 4 positions:** clear, red, yellow and blue.
- **Order on the discs:**

| Disc | North | East | South | West |
|---|---|---|---|---|
| Left | Red | Clear | Blue | Yellow |
| Right | Blue | Yellow | Red | Clear |

  The right disc has the same colors in the opposite cardinal point.
- **Rotation:** each press moves one position (Q turns the left disc, E the right one). 4 presses bring it back to the start. The numbers jump straight to a color (see [[Controls and UI]]).
- **Transition:** disc rotation animation. Duration: _(proposal: 0.25 s)_. **The rule change (what is solid and what isn't) applies at the midpoint of the animation.** The plastic bar of the disc marks the moment when objects are "drawn" on the screen, so they can be seen halfway through the turn.

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
| Colored object (door, wall, platform) | Grey by luminance, solid | Transparent and passable | Solid. The tileset **vibrates once** when the filter changes to a color that doesn't match |
| Hidden object (platform) | Not visible | Appears | Not visible |
| Brush (collectible) | Dotted outline in the color needed | Visible and collectable | Dotted outline in the color needed |
| Colored enemy | Grey by luminance | Invisible, but still deadly | Visible |

- **Grey by luminance:** yellow is the lightest grey and blue the darkest.
- **Mixes are colors in their own right:** a violet object only reacts to the violet filter; under red or blue it behaves like any other color.
- **Objects of another color under a filter:** they stay solid and keep their grey. To tell the player "this is not your color" the tileset vibrates once. For example, a blue wall under the red filter vibrates once.
- **Brushes:** the collectibles are brushes (they replace the keys). Under a filter that is not theirs, you see the **dotted outline of the brush in the color you must pick**, so the outline is the clue.
- **Hidden objects without their filter:** they do not exist: no collision and not visible, so they can't be stood on or picked up.
- **Player inside an object that becomes solid:** the level restarts.

## Abilities by color
Each color has its own ability. It is active **only while its filter is on**. Abilities are passive (no button): they act on their own, and each one is a Godot Resource that changes the player's parameters.

| Color | Feeling | Ability | Status |
|---|---|---|---|
| Red | Deep | Weight: falls faster, breaks cracked floors, pushes blocks | In scope |
| Blue | Aquatic | Float: lower gravity | In scope |
| Yellow | Wild | Super jump (the normal jump, but higher) / wall jump | In scope |
| Green | Earthy | Climb vines | _(out of scope)_ |
| Violet | Magical | Phase through thin walls | _(out of scope)_ |
| Orange | Solar | Horizontal dash | _(out of scope)_ |

If the secondary abilities don't make it, those colors only reveal and open.

## Player movement
- **Basics:** walk, jump and interact (switches, locks).
- **Game feel** _(proposal)_: variable jump height (release early = lower jump), *coyote time* (≈0.1 s to jump right after leaving a ledge) and *jump buffer* (≈0.1 s before landing). They keep the challenge in the puzzle, not in precision.
- **Parameters** (speed, jump height, gravity): set during the blockout ([DIS-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/49)).

## Death and restart
- **You die from:** spikes, falls, enemies and being trapped inside an object that turns solid.
- **On death:** the character darkens and the screen restarts. There are no checkpoints: screens are short.
- **Manual restart:** L / Y at any time.
