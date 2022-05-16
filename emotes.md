---
layout: post
title: Emotes
---
List of emojis in this site:
<div style="display:flex; flex-wrap: wrap;">
{%- for item in site.data.emotes -%}
  <div style="width: 64px; padding: 0 1rem;">
    <img src="{{item.src}}">
    <p style="text-align: center">{{item.id}}</p>
  </div>
{% endfor %}
<div>
