# Programming

Architecture, engine, systems and platforms.

## Engine
- **Godot 4.7**, project `ColorShift/`, with GDScript.
- **Renderer:** *Compatibility*. It is the only one that exports to the web; the project currently uses *Forward+* and has to be switched.
- **Export:** single-threaded HTML5, for itch.io.

## Systems
| System | What it does | Issue | Owner |
|---|---|---|---|
| `GameManager` (autoload) | Game state (playing, paused, game over, victory) and active filter | [PRG-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/121) | @sdurutr436 |
| `SceneManager` (autoload) | Level changes with fade to black, and screen restart | [PRG-8](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/138) | @sdurutr436 |
| `ColorState` | Position of each disc, resulting filter, and the `filter_changed(color)` signal | [PRG-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/121), [PRG-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/124) | @sdurutr436, @JoelDevHub |
| `ColoredObject` | Own color; passable under its filter; hidden mode | [PRG-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/122) | @GunterMagno |
| Tint shader | Greyscale with no filter; scenery tint with a filter | [PRG-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/123) | @GunterMagno |
| Player | Movement, jump, interact, color abilities, death | [PRG-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/120) | @JoelDevHub |
| Disc inventory | Left disc pickup, kept between levels | [PRG-6](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/129) | @JoelDevHub |
| Puzzle elements | Doors, moving platforms, switches, brush (collectible), lock, exit | [PRG-7](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/130) | @GunterMagno |
| Color abilities | Weight, float, super jump and their objects | [PRG-9](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/145) | @JoelDevHub, @GunterMagno |
| Hazards | Spikes, falls, side-to-side enemies with color, kill on touch | [PRG-10](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/152) | @JoelDevHub, @GunterMagno |
| Adaptive music | Layers per filter | [SND-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/101) | @trueantonio, @JoelDevHub |
| Menus and level flow | Main menu, level select, menu/pause (Tab), restart, victory and end screens | [PRG-8](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/138) | @sdurutr436 |
| Settings | Remapping, gamepad, volumes, fullscreen | [PRG-11](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/153) | @JoelDevHub, @GunterMagno |
| Localization | Spanish and English, language selector | [PRG-18](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/155) | @GunterMagno, @JoelDevHub |
| Speech bubbles | Prepared in case the story uses them | [PRG-17](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/156) | @JoelDevHub, @GunterMagno |
| Touch controls | Virtual gamepad on mobile | [PRG-14](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/158) | @JoelDevHub, @GunterMagno |
| Colorblind mode | Color icons _(if time allows)_ | [PRG-12](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/157) | @GunterMagno |
| VFX | Filter transition, particles, fade-out | [PRG-13](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/154) | @GunterMagno |

## Color representation _(proposal)_
Each primary is one bit: red = 1, yellow = 2, blue = 4. The active filter is `left_disc | right_disc`:

| Value | Filter |
|---|---|
| 0 | No filter |
| 1 / 2 / 4 | Red / yellow / blue |
| 3 | Orange (R+Y) |
| 5 | Violet (R+B) |
| 6 | Green (Y+B) |

This way the mix table comes for free, and "an object reacts to its filter" is just `object.color == filter`. Since each disc holds a single color, 7 can never happen.

## Rules in the engine _(proposal)_
- **Passable:** on `filter_changed`, each `ColoredObject` toggles its collision and updates its look.
- **Hidden:** without its filter, the object hides and disables its collision.
- **Wrong color:** when the filter changes to a color that doesn't match a wall or platform, its tileset vibrates once. The object stays solid.
- **Brush:** without its filter it shows only a dotted outline in the color needed; it can only be collected with its filter.
- **Colored enemy:** under its filter it hides, but keeps its damage area.
- **Ability:** the player listens to `filter_changed` and changes its parameters (gravity, jump…). Each ability is a Godot `Resource`, applied only while its filter is active.
- **Rotation:** the rule change is applied at the midpoint of the rotation animation.
- **Trapped:** if the player overlaps an object that becomes solid, the level restarts.

## Current state of the code
- `game_manager.gd` has `colors {GREY, RED, GREEN, BLUE}`: green has to be replaced by yellow, and the mixes added.
- `GameManager` and `SceneManager` are not registered as autoloads in `project.godot`.
- `SceneManager` looks for scenes in `res://scenes/`, but the folder is `Scenes/`. The web and Linux are case-sensitive, so it would fail once exported.
- `game_manager.gd` calls `change_scene("END")`, but `"END"` is not in `paths`.

## Target platforms
Web browser on desktop and mobile, through itch.io. The full analysis (features, advantages, limitations and justification) is in the one-page GDD.

**Technical adaptations:**
- Switch the renderer to *Compatibility*; shaders must be WebGL 2 compatible.
- "Press to start" screen to unlock audio.
- Gamepad through the browser's Gamepad API; virtual touch gamepad on mobile.
- Landscape orientation, fullscreen button, and elements readable on small screens.
- Progress and controls saved to `user://` (on the web it is stored in the browser's storage).
