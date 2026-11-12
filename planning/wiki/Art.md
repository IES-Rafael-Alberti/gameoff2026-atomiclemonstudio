# Art

Art direction ([ART-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/86)) and asset list.

## Style
- **Pixel art.**
- **No filter:** everything is greyscale.
- **With a filter:** the scenery is tinted with its color and objects of that color become transparent.
- **Camera through the viewer:** off-center so the disc's plastic rim shows at the top, bottom and sides. Color changes are animated as a disc rotation.
- **Base resolution:** tiles of 32×32; the character is 64×64.
- **References:** *Hollow Knight* (atmosphere, 2D knight) and *Hue* (color as a mechanic). Moodboard: [ART-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/86).

## Palette
Each color has a ramp of shades, from lightest to darkest.

| Use | Color | Shades (light → dark) |
|---|---|---|
| Neutral world | Grey | `#d0d0d0` `#bababa` `#aaaaaa` `#838383` `#4f4f4f` |
| Primaries | Red | `#d07676` `#b94949` `#a92c2c` `#801d1d` `#561010` `#340808` |
| Primaries | Yellow | `#F7EAA9` `#ebd980` `#DBC558` `#b49d29` `#80721D` `#332d08` |
| Primaries | Blue | `#76a9d0` `#4989ba` `#2c72a8` `#1d5580` `#103857` `#082033` |
| Mixes | Orange | `#f7d1a9` `#ebc17f` `#dba958` `#b5802a` `#805a1d` `#332308` |
| Mixes | Green | `#76d089` `#49b85f` `#2da846` `#1d8031` `#10541e` `#083310` |
| Mixes | Violet | `#af76d0` `#8f49b8` `#7b2da8` `#5c1d80` `#3b1054` `#230833` |

- **Contrast in grey:** each color has a distinct grey by luminance (yellow the lightest, blue the darkest).
- **Color blindness:** the palette is tested with colorblind simulators from sprint 1. If time allows, an icon or pattern per color ([ART-7](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/98)) is added for colorblind mode.
- **Objects of another color under a filter:** walls and platforms keep their look and the tileset vibrates once; brushes show a dotted outline in the color to pick (see [[Mechanics]]). Art needs the dotted-outline version of the brush and a vibration animation (or shader) for the tilesets.

## Asset list
| Asset | Details | Owner | Issue |
|---|---|---|---|
| Bunny knight | Idle, walk, jump, fall, death | @Gloriaa177 | [ART-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/88) |
| Chromoscope | Viewer frame and both discs | @Gloriaa177 | [ART-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/87) |
| Disc rotation animation | One per disc | @Gloriaa177 | [ART-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/87) |
| Environment tileset | Floor, walls, neutral decoration | @Gloriaa177, @lorenagl-1402 | [ART-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/89) |
| Puzzle objects | Door, wall, platform, switch, brush (with dotted outline version), lock, exit, in all 6 colors | @Gloriaa177, @lorenagl-1402 | [ART-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/89) |
| Ability objects | Cracked floor, block, jump wall | @Gloriaa177, @lorenagl-1402 | [ART-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/89) |
| Enemies | Ant and caterpillar in their colors (patrol, death) | @lorenagl-1402, @Gloriaa177 | [ART-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/96) |
| Spikes | In the 6 colors, in the tilesets (the color used depends on the level) | @lorenagl-1402, @Gloriaa177 | [ART-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/96) |
| Level background | | @Gloriaa177, @lorenagl-1402 | [ART-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/89) |
| Color icons | Colorblind mode _(if time allows)_ | @Gloriaa177 | [ART-7](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/98) |
| UI | Menus, touch buttons, levers | @lorenagl-1402, @Gloriaa177 | [ART-6](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/97) |
| Logo and cover | | @lorenagl-1402, @Gloriaa177 | [MKT-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/114) |

The placeholders in the repo (knight, slimes, tileset) are temporary. Their licenses go in the credits ([PRO-11](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/85)).
