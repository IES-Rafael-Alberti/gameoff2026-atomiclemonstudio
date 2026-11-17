# Objects and hazards

How each element of the level behaves ([PRG-7](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/130), [PRG-9](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/145), [PRG-10](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/152)). The general color rules are in [[Mechanics]].

## Puzzle objects
| Object | Behavior | Color variants | Interaction |
|---|---|---|---|
| Colored door | Solid; under its filter it becomes transparent and passable | All 6 colors | Passive |
| Tinted wall | Same as the door, but larger and part of the level layout | All 6 colors | Passive |
| Colored platform | Solid; under its filter it becomes passable | All 6 colors | Passive |
| Hidden platform | Only appears under its filter | All 6 colors | Passive |
| Brush | Collectible that replaces the key. Picked up by touching it. It can be hidden: under a filter that is not its own you only see its dotted outline, in the color you must pick | Neutral or hidden | On touch |
| Lock | Blocks the way until you interact with it holding the brush | Neutral | F / X |
| Switch / pressure plate | Opens doors and moves platforms | Neutral | F / X (switch); step on it (plate) |
| Exit | Ends the level on touch and shows the victory screen | Neutral | Passive. Does it need a brush? _(pending)_ |
| Left disc | Pickup at the start of level 4; unlocks the mixes | — | On touch |

## Ability objects
| Object | Ability | Behavior |
|---|---|---|
| Cracked floor | Red (weight) | Breaks when you land on it with the red filter |
| Pushable block | Red (weight) | Only moves with the red filter |
| Jump wall | Yellow | Allows wall jumps |
| Vine | Green _(out of scope)_ | Can be climbed |
| Thin wall | Violet _(out of scope)_ | Can be phased through |
| Long gap | Orange _(out of scope)_ | Crossed with the dash |

There are no water areas: blue (float) just lowers gravity.

## Hazards
| Hazard | Behavior | Color |
|---|---|---|
| Spikes | Kill on touch | Colored. The color is chosen per level; the 6 colors are proposed in the tilesets |
| Fall | Leaving through the bottom edge of the screen kills | — |
| Ant | Patrols side to side on a platform | One of the 6 colors |
| Caterpillar | Patrols side to side _(proposal: slower)_ | One of the 6 colors |
| Other insects | _(pending)_ | |

**Enemy rule:** under the filter of their color they become invisible, but they are still there and kill on touch. They are a threat to keep in mind when picking a filter. Due to scope, all of them patrol side to side. Can they be defeated (for example, by landing on them with red weight)? _(pending)_
