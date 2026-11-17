# Sound

Sound direction: music and effects ([SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) to [SND-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/110)).

## Adaptive music
- **Each level has its own theme**, built on mystery and resolution.
- **The active filter adds a layer of chords** carrying its color's feeling. When the disc turns, the new layer fades in.
- **Same tempo and key** for every layer in a level, so they fit together at any moment.

| Color | Feeling | Layer _(timbre proposal)_ |
|---|---|---|
| No filter | Mystery | Level theme only |
| Red | Deep | Double bass, cellos, minor mode |
| Blue | Techno / aquatic | Low-pass filtered synths, arpeggios, reverb |
| Yellow | Wild | Tribal percussion |
| Green | Earthy | Marimba, guitar, wooden flutes |
| Violet | Magical | Harp, chimes, choir |
| Orange | Solar | Bright brass, major mode |

**References:** the soundtracks of *Hue* (Alkis Livathinos), *Fez* (Disasterpeace) and *Hollow Knight* (Christopher Larkin).
**Composer:** looking for an external musician ([SND-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/102)); if none turns up, it is done internally.

## Sound effects
| Effect | When it plays | Issue |
|---|---|---|
| Disc click | Each rotation step | [SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) |
| Filter change | When the rotation ends | [SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) |
| Object turns transparent | Doors, walls and platforms of its color | [SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) |
| Tileset vibration | Wrong color: a wall or platform of another color vibrates once _(proposal)_ |
| Hidden object appears | _(proposal)_ | [SND-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/109) |
| Jump and landing | _(proposal)_ | [SND-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/109) |
| Pick up brush or disc | _(proposal)_ | [SND-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/109) |
| Death | Spikes, fall, enemy | [SND-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/109) |
| Victory | Reaching the exit (victory screen) | [SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) |
| Restart | Pressing L / Y | [SND-1](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/100) |
| Menus | Navigate and confirm _(proposal)_ | [SND-3](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/109) |
| Ambience | Background of each level | [SND-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/102) |

## Technical
- **Synchronized layers** ([SND-2](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/101)) with `AudioStreamSynchronized`: all of them start together and the filter only changes their volume.
- **Fade** on filter change: _(proposal: same as the rotation animation, ≈0.25 s)_.
- **Separate music and SFX volumes** in Settings. Balanced in [SND-5](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/110).
