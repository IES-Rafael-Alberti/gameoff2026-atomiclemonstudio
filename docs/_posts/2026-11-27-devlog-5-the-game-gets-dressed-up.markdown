---
layout: post
title: "Devlog 5: the game gets dressed up"
date: 2026-11-27 12:00:00 +0100
categories: dev-log
description: Dev log 5 of ColorShift (24 to 27 November). New menus with pixel fonts and level cards, carrots to collect, coyote time, levels 1 to 3 remade, level 6 and new illustrations of Larry and the enemies.
breadcrumb:
  - title: Dev log
    url: /dev-log/
---

## What these days were about

In the [fourth devlog]({{ '/dev-log/2026/11/25/week-4-enemies-come-alive.html' | relative_url }}) the enemies came alive. Since then the work has been about **how the game looks and feels**: new menus, a new look for the first levels, something to collect and one more level. Lorena also drew a set of illustrations for the devlogs, so this one has more art than usual.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/Devlog1.PNG' | relative_url }}" width="1600" height="1200"
       alt="Larry with round glasses and a worried face, raising one finger as if he is about to explain something.">
  <figcaption><strong>Larry.</strong> He has a few things to explain.</figcaption>
</figure>

## New menus

Every menu now shares one style, built in code so all of them change at once:

- **Pixel fonts:** Press Start 2P for titles, buttons and level names, and VT323 for the rest of the text. They are the same two fonts as this website.
- **Pixel buttons:** buttons, toggles and volume sliders have their own pixel art. The buttons are drawn at whole multiples of their 80×16 art, so the pixels stay square.
- **Main menu:** a castle background, the ColorShift title and a picture of Larry.
- **Level select:** each level is a **card** with a window for its picture and a strip for its name. Locked levels show a door instead of the picture. The card and the panels of the menus are drawn by Lorena.
- **Focus:** with the keyboard or the gamepad, the selected button gets a yellow ring. With the mouse, the ring hides and hovering highlights the buttons instead, so there is never more than one button highlighted.
- **Options:** the text has a black outline, so it reads well over the light background.

A shader that moves a diagonal shine over Larry in the main menu is also started.

## Carrots

The collectables of the levels are now **carrots**. There are 10 in the whole game. When Larry picks one up, a counter like **3/10** fades in at the corner of the screen, stays for two seconds and fades out.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/Devlog2.png' | relative_url }}" width="1600" height="1200"
       alt="Larry, nervous, holds a carrot with crosses for eyes. Next to him there is a gravestone that says Larry 2026, with his paintbrush leaning on it.">
  <figcaption><strong>Larry and a carrot.</strong> Not every carrot makes it.</figcaption>
</figure>

## Coyote time

If Larry walks off a ledge, he can still jump for a moment after leaving it (0.12 seconds). It only works when he walks off, not in the middle of a jump. Jumps that felt "too late" by a hair now work.

## Levels 1 to 3, remade

All the levels now paint with **the same tileset**, the one of level 7, including the barriers. Levels 1, 2 and 3 used an older one, so Antonio moved them to the new tileset and **remade them**: they have a new look and new puzzles that make sense with the mechanics the game has now. Levels 4 and 5 also look better.

Level 4 has a new barrier and a button, so new players can try them once in a safe place before level 5.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/Devlog3.png' | relative_url }}" width="1600" height="1200"
       alt="The snake and the frog, both angry and wearing red boxing gloves, punch each other in front of the word fight written in big red letters.">
  <figcaption><strong>The snake and the frog.</strong> They do not get along.</figcaption>
</figure>

## Level 6

Level 6 is done and appears in the level select. Like level 5, it starts with **both color wheels** unlocked. It has two details we like:

- A **chameleon made of blocks** with its mirror image, and their tongues are a chain of moving platforms, each one of a different color.
- A **chameleon carved in stone** in the scenery.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/Devlog4.png' | relative_url }}" width="1600" height="1200"
       alt="The chameleon with its crown and its white and orange cape raises both arms with an angry face. The frog and the snake peek in from the sides.">
  <figcaption><strong>The chameleon.</strong> It is not happy about its statue.</figcaption>
</figure>

## Two more drawings

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/Devlog5.png' | relative_url }}" width="1600" height="1200"
       alt="Larry, very happy, wears black pixel sunglasses next to a painter's palette with red, orange, yellow, green, blue and violet.">
  <figcaption><strong>Larry and the palette.</strong> Six colors and a lot of style.</figcaption>
</figure>

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/fifthpost/larry-keychain.jpg' | relative_url }}" width="1020" height="1320"
       alt="A smiling character with a lemon for a head and short yellow hair holds up a small keychain of Larry.">
  <figcaption><strong>Bonus.</strong> A lemon and its Larry keychain.</figcaption>
</figure>

## What is still missing

- Levels 7 and 8.
- Putting the frog and the snake in more levels and teaching each one in a safe place first.
- Deciding how the two colors of the frog behave under a filter.
- The tileset in orange, green and violet.
- The fight with the chameleon.
- Finishing Larry's shine in the main menu.
