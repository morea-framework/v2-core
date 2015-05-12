---
layout: default
title: Home
topdiv: container
---

{% if site.morea_home_page %}
  {{ site.morea_home_page.content | markdownify }}
{% else %}
  No home page content supplied.
{% endif %}

