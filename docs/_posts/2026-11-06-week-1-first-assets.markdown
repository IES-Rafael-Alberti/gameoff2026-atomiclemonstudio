---
layout: post
title: "Week 1: our first assets"
date: 2026-11-06 12:00:00 +0100
categories: dev-log
description: Dev log of week 1 of ColorShift (2 to 8 November). Larry's idle, run and jump spritesheets, the first key and the first tileset of the scenery.
breadcrumb:
  - title: Dev log
    url: /dev-log/
---

## What the week was about

The first sprint (2 to 8 November) is meant for pre-production and foundations: the design documents, the player controller and the color system. In practice, a big part of the week is going into **generating the first real assets**, so the game can stop using placeholders (a knight, some slimes and a borrowed tileset).

Everything shown here is real art that is already in the repository, in `ColorShift/assets/sprites/`.

## Larry

Larry is the bunny knight. The three spritesheets below have **64×64 pixel frames**, drawn in greys, because without a filter the whole world is greyscale. The color comes later, from the Chromoscope.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/firstpost/larry-idle.png' | relative_url }}" width="512" height="128"
       alt="Spritesheet of Larry standing still: four frames in a row, a small breathing animation.">
  <figcaption><strong>Idle.</strong> 4 frames, 256×64 px.</figcaption>
</figure>

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/firstpost/larry-run.png' | relative_url }}" width="512" height="384"
       alt="Spritesheet of Larry running: three rows of four frames each.">
  <figcaption><strong>Run.</strong> 12 frames in a grid of 4×3, 256×192 px.</figcaption>
</figure>

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/firstpost/larry-jump.png' | relative_url }}" width="896" height="128"
       alt="Spritesheet of Larry jumping: seven frames in a row, from the take-off to the landing.">
  <figcaption><strong>Jump.</strong> 7 frames, 448×64 px.</figcaption>
</figure>

The idle and run animations arrived on 5 November and the jump joined them on the 6th.

## The key

The first collectible is a key, a single **32×32 pixel** sprite. It is the base size of every object in the game.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/firstpost/key.png' | relative_url }}" width="128" height="128"
       alt="Pixel art of a grey key.">
  <figcaption><strong>Key.</strong> 32×32 px, shown at 4×.</figcaption>
</figure>

## The scenery

The first tileset is built on **32×32 pixel tiles** and comes in four versions: **grey** for the neutral world and **red**, **blue** and **yellow**, the three primary colors. Each version has the same pieces: ground blocks, a framed block with a window, a thin platform, a barrier gate, a key and spikes.

<figure class="sprite-sheet">
  <img class="sprite" src="{{ '/assets/img/devlog/firstpost/tileset-1.png' | relative_url }}" width="576" height="672"
       alt="Tileset in four quadrants labeled grey, red, blue and yellow. Each one has dark rocky ground blocks, a window block, a platform, a barrier gate, a key and spikes.">
  <figcaption><strong>Tileset 1.</strong> 384×448 px, shown at 1.5×.</figcaption>
</figure>

Orange, green and violet, the three mixes, are not drawn yet.

## What comes next

- The **death animation** of Larry.
- A **new, bigger tileset**, with its own palette for each color.
- Putting all of this together in the first levels.
