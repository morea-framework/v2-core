---
layout: default
title: Modules
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
  <h1>Modules <small>Topics covered in this class.</small></h1>
  
  {% if site.morea_overview_modules %}
    {{ site.morea_overview_modules.content | markdownify }}
  {% endif %}
  
  <div class="row">
     {% for module in site.morea_module_pages %}
        <div class="col-sm-3">
        
        {% if module.morea_coming_soon %}
          <div class="thumbnail">
            <img src="{{ site.baseurl }}{{ module.morea_icon_url }}" width="100" class="img-circle img-responsive">
            <div class="caption">
              <h3 style="text-align: center; margin-top: 0">{{ forloop.index }}. {{ module.title }}</h3>
              {{ module.morea_summary | markdownify }}
              <p>
              {% for label in module.morea_labels %}
                <span class="badge">{{ label }}</span>
              {% endfor %}
              </p>
              <p class="text-center"><b>Coming soon...</b></p>
            </div>
          </div>
        {% else %}
          <a href= "{{ module.morea_id }}" class="thumbnail">
            <img src="{{ site.baseurl }}{{ module.morea_icon_url }}" width="100" class="img-circle img-responsive">
            <div class="caption">
              <h3 style="text-align: center; margin-top: 0">{{ forloop.index }}. {{ module.title }}</h3>
              {{ module.morea_summary | markdownify }}
              <p>
              {% for label in module.morea_labels %}
                <span class="badge">{{ label }}</span>
              {% endfor %}
              </p>
              
            </div>
          </a>
        {% endif %}
        </div>
         
       {% cycle '', '', '', '</div><div class="row">' %}
     {% endfor %}
  </div>
</div>


