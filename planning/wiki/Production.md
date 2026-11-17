# Production

Team, schedule, deliverables and cut plan.

## Team
| Person | Role |
|---|---|
| Sergio (@sdurutr436) | Producer, programmer |
| Antonio (@trueantonio) | Level designer, sound |
| Alejandro (@GunterMagno) | Programmer, VFX |
| Joel (@JoelDevHub) | Lead designer, programmer |
| Lorena (@lorenagl-1402) | Art, marketing |
| Gloria (@Gloriaa177) | Lead artist |

## Methodology
- **Scrum** with 4 one-week sprints. The board is GitHub Projects, with the fields Role, Priority Level (per role and sprint), Sprint, Phase and Estimated time.
- **Weekly** follow-up meeting: _(pending: day and time)_.
- **Branches:** `develop` → PR → `main`.
- **Commits:** `feat:`, `fix:`, `chore:`, `merge:`.

## Schedule
| Sprint | Dates | Goal | Deliverables |
|---|---|---|---|
| S1 | Nov 2–8 | Pre-production and foundations | One-page and full GDD, art direction, blockout, player controller, color system, tint shader |
| S2 | Nov 9–15 | Mechanics complete | Second disc and mixes, puzzle elements, level manager, viewer and HUD, first sound pass |
| S3 | Nov 16–22 | Content | Levels 1–8, environment and object art, music, VFX, hints |
| S4 | Nov 23–30 | Polish and delivery | External playtests, bug fixing, web build, itch.io page, submission |

## Milestones
| Milestone | Date |
|---|---|
| Milestone 1: mechanics complete | 15/11/26 |
| Milestone 2: levels 1–8 complete (content freeze) | 22/11/26 |
| Milestone 3: polish and external playtests complete | 29/11/26 |
| Submission to Game Off (24 h margin) | 30/11/26 |
| **Deadline** | **01/12/26, 22:00** |

## Cut plan
If something slips, cut from the bottom up:
1. Levels 9 and 10.
2. Colorblind mode with icons (the palette is still tested with simulators).
3. Hint system.
4. Secondary abilities (green, violet, orange).
5. Touch controls (the game stays desktop-only).
6. Never cut: the 8 levels with one and two discs, the 3 primary abilities and the web build.

## Risks
| Risk | Mitigation |
|---|---|
| Scope too large | 8 good levels are worth more than 15 mediocre ones; apply the cut plan |
| Color readability | Test with colorblind simulators from S1 |
| The tint shader gets complicated | Plan B: tint the sprites directly ([PRG-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/123)) |
| Uneven workload (Antonio: levels and sound in S3) | Move the music ([SND-4](https://github.com/IES-Rafael-Alberti/gameoff2026-atomiclemonstudio/issues/102)) to someone else or to the external composer |
| Mobile performance | Test the web build on a mid-range phone from S2 |
