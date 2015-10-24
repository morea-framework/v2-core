---
layout: default
title: Experiences
---

<div class="breadcrumb-bar">
  <div class="container">
    <ol class="breadcrumb">
        {% if site.morea_head_breadcrumb_link %}
          <li><a href="{{ site.morea_head_breadcrumb_link }}">{{ site.morea_head_breadcrumb_label }}</a></li>
          {% endif %}
      <li><a href="{{ site.baseurl }}/">Home</a></li>
      <li class="active">{{ page.title }}</li>
    </ol>
  </div>
</div>

<div class="container">
  <h1>Experiential Learning <small>in module order</small></h1>
</div>

{% if site.morea_overview_experiences %}
<div class="container">
  {{ site.morea_overview_experiences.content | markdownify }}
</div>
{% endif %}

{% for module in site.morea_module_pages %}
{% if module.morea_coming_soon != true and module.morea_experiences.size > 0 %}
<div class="{% cycle 'section-background-1', 'section-background-2' %}">
  <div class="container">
    <h2><small>Module:</small> <a href="{{ site.baseurl }}{{ module.module_page.url }}">{{ module.title }}</a></h2>

    {% if module.morea_experiences.size == 0 %}
    <p>No experiences for this module.</p>
    {% endif %}

    <div class="row">
    {% for page_id in module.morea_experiences %}
      {% assign experience = site.morea_page_table[page_id] %}
       <div class="col-sm-3">
         <a href="{{ experience.morea_url }}" class="thumbnail">
           <h4>{{ experience.title }}</h4>
             {{ experience.morea_summary | markdownify }}
             <p>
             {% for label in experience.morea_labels %}
               <span class="badge">{{ label }}</span>
             {% endfor %}
             </p>
         </a>
       </div>
       {% if forloop.index == 4 %}
         </div><div class="row">
       {% endif %}
       {% if forloop.index == 8 %}
         </div><div class="row">
       {% endif %}
      {% if forloop.index == 12 %}
         </div><div class="row">
       {% endif %}
       {% if forloop.index == 16 %}
         </div><div class="row">
       {% endif %}
    {% endfor %}
    </div>
  </div>
</div>
{% endif %}
{% endfor %}
