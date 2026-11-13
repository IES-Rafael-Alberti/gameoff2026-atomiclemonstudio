---
layout: post
title: "Week 2: the first playable levels"
date: 2026-11-13 12:00:00 +0100
categories: dev-log
description: Dev log of 9 to 13 November of ColorShift. Larry's death animation, the chameleon, the tileset in four colors, the first three levels, the level select and the menus.
breadcrumb:
  - title: Dev log
    url: /dev-log/
---

## What the week was about

In the [first devlog]({{ '/dev-log/2026/11/06/week-1-first-assets.html' | relative_url }}) we finished with three things to do: Larry's death animation, a bigger tileset and putting everything together in the first levels. **All three are done**, and the game is now something you can actually play from the main menu to the end of a level.

## Larry dies

The death animation has **12 frames of 128×128 pixels**, in a grid of 6×2: Larry is hit, falls and ends lying on the floor. It went through a couple of rounds of corrections by Gloria before it went into the game, where it plays when Larry touches spikes.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/secondpost/larry-death.png' | relative_url }}" width="768" height="256"
       alt="Spritesheet of Larry's death in two rows of six frames: he is hit, falls backwards and ends lying on the ground.">
  <figcaption><strong>Death.</strong> 12 frames, 768×256 px.</figcaption>
</figure>

## The chameleon

The story mentions a chameleon, and it already has its first sprite: an idle animation of **4 frames of 128×128**. It wears a small crown and carries a staff. We have not decided yet what role it will play.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/secondpost/chameleon-idle.png' | relative_url }}" width="512" height="128"
       alt="Spritesheet of a green chameleon with a small crown and a staff, standing still: four frames in a row.">
  <figcaption><strong>Chameleon, idle.</strong> 4 frames, 512×128 px.</figcaption>
</figure>

## The tileset, now in color

The first tileset was only a grey sketch of what we wanted. The new one keeps the same **32×32 pixel** pieces (ground blocks, a window block, a platform, a barrier gate, a key and spikes), but each version now has its **own palette**: grey, red, blue and yellow. They are the colors the three primaries of the game will use.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/secondpost/tileset-4-colors.png' | relative_url }}" width="576" height="672"
       alt="Tileset in four quadrants labeled grey, red, blue and yellow. Each one is painted in its own color: dark grey rock, red rock, blue rock and golden rock.">
  <figcaption><strong>Tileset in 4 colors.</strong> 384×448 px, shown at 1.5×.</figcaption>
</figure>

Orange, green and violet, the three mixes, are still missing.

## A carrot to collect

The first collectable is a **carrot**, a 32×32 sprite. It is a small thing, but it is the first object the player picks up just by touching it. The key has also become a real object: it floats up and down, and once picked up it follows Larry around until it is used. The design has moved on in the meantime: the collectibles of the levels will be **brushes**, so the key is a stand-in until the brush is drawn.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/secondpost/carrot.png' | relative_url }}" width="128" height="128"
       alt="Pixel art of a grey carrot.">
  <figcaption><strong>Carrot.</strong> 32×32 px, shown at 4×.</figcaption>
</figure>

## Levels and menus

This is where most of the work went:

- **Tutorial map and levels 1, 2 and 3** are finished and can be played one after the other.
- **Rooms and checkpoints:** a level is made of rooms, the camera moves from one room to the next, and pressing **L** sends Larry back to the checkpoint of the room he is in.
- **Safe color changes:** when the color changes and a solid tile appears on top of Larry, he is moved out of it instead of getting stuck. If he leaves the level, it restarts.
- **Level select:** after finishing a level you go to a level select screen with six doors. The first three are open and the rest are locked.
- **Menus:** main menu, pause menu, options and credits are all in the game.
- **Accessibility:** the options include a color-blind mode with filters for protanopia, deuteranopia and tritanopia.

## What is still missing

- For now the color changes by pressing **Shift** and cycling through the colors. The two **discs** (Q and E) and the mixes are still to come.
- Levels 4 to 8.
- Music and sound effects.
- Hints in the levels.
- The tileset in orange, green and violet.
- A web build to try on itch.io.
