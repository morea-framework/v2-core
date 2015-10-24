---
layout: default
title: Assessments
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
  <h1>Assessments <small>in module order</small></h1>
</div>

{% if site.morea_overview_assessments %}
<div class="container">
  {{ site.morea_overview_assessments.content | markdownify }}
</div>
{% endif %}

{% for module in site.morea_module_pages %}
{% if module.morea_coming_soon != true and module.morea_assessments.size > 0 %}
<div class="{% cycle 'section-background-1', 'section-background-2' %}">
  <div class="container">
    <h2><small>Module:</small> <a href="{{ site.baseurl }}{{ module.module_page.url }}">{{ module.title }}</a></h2>

    {% for page_id in module.morea_assessments %}
      {% assign assessment = site.morea_page_table[page_id] %}
      <a style="padding-top: 50px; margin-top: -50px; display: table-caption;" name="{{ assessment.morea_id }}"></a><h3>{{ assessment.title }}</h3>
      <p>
        {% for label in assessment.morea_labels %}
          <span class="badge">{{ label }}</span>
        {% endfor %}
      </p>
      {% unless assessment.morea_related_outcomes.size == 0 %}
        <p>
        <em>Outcomes assessed:</em>
          {% for outcome in assessment.morea_related_outcomes %}
            <a href="{{ site.baseurl }}/outcomes/#{{ outcome.morea_id }}">{{ outcome.title }}</a>{% unless forloop.last %}, {% endunless %}
          {% endfor %}
        </p>
      {% endunless %}
      {{ assessment.content | markdownify }}
    {% endfor %}
  </div>
</div>
{% endif %}
{% endfor %}