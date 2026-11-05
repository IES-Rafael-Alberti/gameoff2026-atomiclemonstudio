# Objects and hazards

How each element of the level behaves ([PRG-7](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/130), [PRG-9](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/145), [PRG-10](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/152)). The general color rules are in [[Mechanics]].

## Puzzle objects
| Object | Behavior | Color variants | Interaction |
|---|---|---|---|
| Colored door | Solid; under its filter it becomes transparent and passable | All 6 colors | Passive |
| Tinted wall | Same as the door, but larger and part of the level layout | All 6 colors | Passive |
| Colored platform | Solid; under its filter it becomes passable | All 6 colors | Passive |
| Hidden platform | Only appears under its filter | All 6 colors | Passive |
| Key | Opens its lock; can be hidden (a yellow key only appears under the yellow filter) | Neutral or hidden | _(pending: on touch or with E/X)_ |
| Lock | Blocks the way until the key is used | Neutral | _(pending)_ |
| Switch / pressure plate | Triggers: _(pending)_ | _(pending)_ | E/X (switch); step on it (plate) |
| Exit | Ends the level on touch | Neutral | Passive. Does it need a key? _(pending)_ |
| Left disc | Pickup in level 4; unlocks the mixes | — | On touch |

## Ability objects
| Object | Ability | Behavior |
|---|---|---|
| Cracked floor | Red (weight) | Breaks when you land on it with the red filter |
| Pushable block | Red (weight) | Only moves with the red filter |
| Water area | Blue (float) | With blue you swim; without blue: _(pending)_ |
| Jump wall | Yellow | Allows wall jumps |
| Vine | Green _(out of scope)_ | Can be climbed |
| Thin wall | Violet _(out of scope)_ | Can be phased through |
| Long gap | Orange _(out of scope)_ | Crossed with the dash |

## Hazards
| Hazard | Behavior | Color |
|---|---|---|
| Spikes | Kill on touch | _(pending: neutral or colored)_ |
| Fall | Leaving through the bottom edge of the screen kills | — |
| Ant | Patrols side to side on a platform | One of the 6 colors |
| Caterpillar | Patrols side to side _(proposal: slower)_ | One of the 6 colors |
| Other insects | _(pending)_ | |

**Enemy rule:** under the filter of their color they become invisible, but they are still there and kill on touch. They are a threat to keep in mind when picking a filter. Due to scope, all of them patrol side to side. Can they be defeated (for example, by landing on them with red weight)? _(pending)_
