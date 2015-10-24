---
layout: default
title: Prerequisites
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
  <h1>Prerequisites <small>in module order</small></h1>
</div>

{% for module in site.morea_module_pages %}
{% if module.morea_coming_soon != true and module.morea_prerequisites.size > 0 %}
<div class="{% cycle 'section-background-1', 'section-background-2' %}">
  <div class="container">
    <h2><small>Module:</small> <a href="{{ site.baseurl }}{{ module.module_page.url }}">{{ module.title }}</a></h2>

    <div class="row">
    {% for page_id in module.morea_prerequisites %}
      {% assign prereq = site.morea_page_table[page_id] %}
       <div class="col-sm-3">
         <a href= "{{ prereq.morea_url }}" class="thumbnail">
           <img src="{{ prereq.morea_icon_url }}" width="100" class="img-circle img-responsive">
           <div class="caption">
             <h3 style="text-align: center; margin-top: 0">{{ prereq.title }}</h3>
             {{ prereq.content | markdownify }}
             <p>
               {% for label in prereq.morea_labels %}
                 <div style="text-align: center;"><span class="badge">{{ label }}</span></div>
               {% endfor %}
             </p>
             
           </div>
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
