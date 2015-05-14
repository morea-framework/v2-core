---
layout: default
title: Modules
---

<div class="container">
  <h1>Modules <small>Topics covered in this class.</small></h1>
  <div class="row">
     {% for module in site.morea_module_pages %}
        <div class="col-sm-3">
        
        {% if module.morea_coming_soon %}
          <div class="thumbnail">
            <img src="{{ site.baseurl }}{{ module.morea_icon_url }}" width="100" class="img-circle img-responsive">
            <div class="caption">
              <h3 style="text-align: center; margin-top: 0">{{ forloop.index }}. {{ module.title }}</h3>
              {{ module.content | markdownify }}
              <p>
              {% for label in module.morea_labels %}
                <span class="badge">{{ label }}</span>
              {% endfor %}
              </p>
              <p class="text-center"><span class="btn btn-default">Coming soon...</span></p>
            </div>
          </div>
        {% else %}
          <a href= "{{ module.morea_id }}" class="thumbnail">
            <img src="{{ site.baseurl }}{{ module.morea_icon_url }}" width="100" class="img-circle img-responsive">
            <div class="caption">
              <h3 style="text-align: center; margin-top: 0">{{ forloop.index }}. {{ module.title }}</h3>
              {{ module.content | markdownify }}
              <p>
              {% for label in module.morea_labels %}
                <span class="badge">{{ label }}</span>
              {% endfor %}
              </p>
              <p class="text-center"><span class="btn btn-primary">Learn more...</span></p>
            </div>
          </a>
        {% endif %}
        </div>
         
       {% cycle '', '', '', '</div><div class="row">' %}
     {% endfor %}
  </div>
</div>


