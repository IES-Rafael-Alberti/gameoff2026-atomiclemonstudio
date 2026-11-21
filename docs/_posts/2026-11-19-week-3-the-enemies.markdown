---
layout: post
title: "Week 3: the enemies"
date: 2026-11-19 12:00:00 +0100
categories: dev-log
description: Dev log of week 3 of ColorShift (16 to 20 November). The concept art of the enemies, a frog and a snake, and of the chameleon that rules over them.
breadcrumb:
  - title: Dev log
    url: /dev-log/
---

## What the week was about

In the [second devlog]({{ '/dev-log/2026/11/13/week-2-first-playable-levels.html' | relative_url }}) we had Larry, the tileset and the first levels, but nothing that fights back. This week is about the ones who do: **the enemies**.

Everything below is **concept art**: loose sketches to find the look and the personality of each one before drawing the final sprites. None of them is in the game yet.

## How the enemies work

The design gives them a simple, readable rule:

- They **patrol from side to side** on a platform.
- They **kill on touch**.
- Each one has a color. Without a filter they are seen in grey, with the grey that belongs to their color by luminance (yellow is the lightest and blue the darkest).
- Under the filter of **their own color they become invisible**, but they are still there and still kill. The filter that opens a door can also hide the thing that is about to hit you.

## The frog

The first sketch is a frog with a bad temper: a yellow back with black spots, a blue belly and legs, and a frown that says it is not here to make friends.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/thirdpost/frog-concept.png' | relative_url }}" width="500" height="500"
       alt="Sketch of a frog seen from the front. Its back is yellow with black spots, its belly and legs are blue, and it frowns.">
  <figcaption><strong>Frog.</strong> Concept art.</figcaption>
</figure>

It brings a question. The enemies in the design have **one** color each, and this frog has two. We still have to decide what each half does when a filter is on.

## The snake

The second one is a green snake with a flat, annoyed look and two small fangs. The detail we like is the tail: it ends in a **red ball with spikes**, so even the part that is not the head is dangerous.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/thirdpost/snake-concept.png' | relative_url }}" width="500" height="500"
       alt="Sketch of a green snake with a frowning face and two fangs. The tip of its tail is a red ball with spikes.">
  <figcaption><strong>Snake.</strong> Concept art.</figcaption>
</figure>

## The chameleon

The chameleon from the story, the one with the crown and the staff that appeared in the last devlog as an idle animation, also has its concept art now: a front view and a side view, with a **white and orange cape**, a golden staff and a very serious face.

<figure class="sprite-sheet">
  <img class="sprite sprite--concept" src="{{ '/assets/img/devlog/thirdpost/cameleon-concept.png' | relative_url }}" width="500" height="500"
       alt="Two sketches of a green chameleon with a golden crown and a white and orange cape, one from the front holding a golden staff and one from the side.">
  <figcaption><strong>Chameleon.</strong> Concept art, front and side view.</figcaption>
</figure>

## What is still missing

- Deciding how the frog and the snake use their colors.
- The final sprites, with their patrol and death animations.
- The enemies in the levels. The plan is that the first one appears in level 3 and that every enemy is taught in a safe place first.
- The role of the chameleon.
