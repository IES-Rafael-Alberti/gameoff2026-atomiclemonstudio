---
layout: page
title: Dev log
permalink: /dev-log/
description: The development diary of ColorShift by Atomic Lemon Studio, week by week. Art, tilesets, animations and progress.
---

One entry per week, written while we make ColorShift for GitHub Game Off 2026.

<ul>
{%- for post in site.categories.dev-log %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <time datetime="{{ post.date | date_to_xmlschema }}">({{ post.date | date: "%-d %b %Y" }})</time>
  </li>
{%- endfor %}
</ul>
