---
layout: page
title: Team
permalink: /team/
description: The people of Atomic Lemon Studio and the posts about the team.
---

Atomic Lemon Studio is a six-person team. Here you can find the posts about the people behind ColorShift.

<ul>
{%- for post in site.categories.team %}
  <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> <time datetime="{{ post.date | date_to_xmlschema }}">({{ post.date | date: "%-d %b %Y" }})</time></li>
{%- endfor %}
</ul>
