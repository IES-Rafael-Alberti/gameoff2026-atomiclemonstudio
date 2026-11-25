---
layout: post
title: "Week 4: the enemies come alive"
date: 2026-11-25 12:00:00 +0100
categories: dev-log
description: Dev log of week 4 of ColorShift (23 to 27 November). The frog and the snake get their final animations, the chameleon gets its death animation, levels 4 and 5, moving platforms, color buttons, remappable controls and the first sound effects.
breadcrumb:
  - title: Dev log
    url: /dev-log/
---

## What the week was about

In the [third devlog]({{ '/dev-log/2026/11/19/week-3-the-enemies.html' | relative_url }}) the enemies were only sketches. This week they **move**: the frog and the snake have final animations and behavior, and the chameleon has its death animation. Around them the game keeps growing, with two new levels, new things to interact with and a lot of work on controls and sound.

## The frog hops

The frog is no longer a sketch. It has a sprite of **128×128 pixel frames** with a yellow back and a blue belly, just like the concept art, and a hop animation of 8 frames.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/fourthpost/frog-hop.png' | relative_url }}" width="768" height="256"
       alt="Spritesheet of the frog hopping in two rows: it crouches, jumps with its legs stretched and lands.">
  <figcaption><strong>Frog, hop.</strong> 8 frames of 128×128 px, 768×256 px.</figcaption>
</figure>

Its behavior is a small state machine with three states:

- **Walk:** it patrols between two limits, hopping from one to the other.
- **Chase:** if Larry comes close (and is not too far above or below), it stops patrolling and goes after him.
- **Death:** a short animation when it is defeated.

There is also a hit sheet of 5 frames that the frog uses when it is hurt.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/fourthpost/frog-hit.png' | relative_url }}" width="384" height="256"
       alt="Spritesheet of the frog being hit: five nearly identical frames in which its mouth and legs change slightly.">
  <figcaption><strong>Frog, hit.</strong> 5 frames, 384×256 px.</figcaption>
</figure>

A frog is already placed in level 3 to test all of this, over a new **parallax background** made of layers that move at different speeds.

## The snake slithers

The snake keeps the detail we liked from the concept: the **red ball with spikes** at the end of its tail. It has a walk animation of 6 frames of 128×128 and a hit sheet of 5 frames.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/fourthpost/snake-walk.png' | relative_url }}" width="768" height="128"
       alt="Spritesheet of the green snake slithering: six frames in a row, with the spiked red ball at the end of its tail.">
  <figcaption><strong>Snake, walk.</strong> 6 frames, 768×128 px.</figcaption>
</figure>

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/fourthpost/snake-hit.png' | relative_url }}" width="384" height="256"
       alt="Spritesheet of the snake being hit: five frames in which its eyes close.">
  <figcaption><strong>Snake, hit.</strong> 5 frames, 384×256 px.</figcaption>
</figure>

One surprise: the first version of the snake does not patrol from side to side. It moves **up and down** between two limits, like a moving trap, so it will work well in vertical shafts. The "patrol from side to side" rule from the design still applies to the frog.

## The chameleon falls

The chameleon also has its animations: walk, jump, hit and a magic attack. The most dramatic one is the **death animation**, drawn by Gloria. It is **26 frames of 128×128**: the chameleon stands, drops its staff, falls on its knees and ends lying on the ground with the cape over its back.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/fourthpost/chameleon-death.png' | relative_url }}" width="1664" height="256"
       alt="Spritesheet of the chameleon's death in two rows of thirteen frames: it stands with its crown and staff, drops the staff, falls and ends lying on the floor.">
  <figcaption><strong>Chameleon, death.</strong> 26 frames, 1664×256 px.</figcaption>
</figure>

We still do not know what role the chameleon will play, but now we know how it ends up if it loses.

## Levels 4 and 5

Two new levels are playable and appear in the level select. Level 5 starts with the **second color wheel** already unlocked, so the player can use both discs from the first room.

## New things to interact with

- **Moving platforms:** they follow a path that can be drawn in the editor, move back and forth (or in a loop) and can pause at each end. A platform can have a color and then it only exists in that color, like the colored tiles.
- **Color buttons:** a button is only visible and pressable when the current color is its own, and it opens the barriers of that color.
- **Color collectables:** a new collectable for the colors of the game.
- **Screen transition:** the change between scenes now uses a tile-wipe effect made with a shader.

## Controls and sound

- **Remappable controls:** a new menu lets you change the keys and the gamepad buttons of every action, including the two color wheels, and reset them to the defaults.
- **Menus** can be used with the keyboard or the gamepad, with focus on the right button and Cancel to go back.
- **Better movement:** the jump height now depends on how long the button is held, and Larry can drop through thin platforms and move while shifting colors.
- **Sound:** menu clicks, the color change (a light switch click), the key, the collectable and the door now have their own sound effects, and the frog has a set of 14 sounds.

## What is still missing

- Putting the frog and the snake in more levels and teaching each one in a safe place first.
- Deciding how the two colors of the frog behave under a filter.
- Levels 6 to 8.
- The tileset in orange, green and violet.
- The role of the chameleon.
- A web build to try on itch.io.
