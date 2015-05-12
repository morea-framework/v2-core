---
layout: default
title: Learning Outcomes
---

<div class="container">
  <h1>Learning Outcomes</h1>
</div>

{% if site.morea_outcome_pages.size == 0 %}
<p>No outcomes for this course.</p>
{% endif %}


{% for outcome in site.morea_outcome_pages %}

{% if outcome.referencing_modules.size > 0 %}

<div class="{% cycle 'section-background-1', 'section-background-2' %}">
  <div class="container">
    <a style="padding-top: 50px; margin-top: -50px; display: table-caption;" name="{{ outcome.morea_id }}"></a><h3><small>{{ forloop.index }}.</small> {{ outcome.title }}</h3>
    <p>
      {% for label in outcome.morea_labels %}
         <span class="badge">{{ label }}</span>
      {% endfor %}
    </p>
    {{ outcome.content | markdownify }}
    <p>
    <em>Referencing modules:</em>
    {% for module in outcome.referencing_modules %}
      <a href="../modules/{{ module.morea_id }}">{{ module.title }}</a>{% unless forloop.last %}, {% endunless %}
    {% endfor %}
    </p>
    {% unless outcome.morea_referencing_assessments.size == 0 %}
       <p>
        <em>Assessed by:</em>
        {% for assessment in outcome.morea_referencing_assessments %}
          <a href="../assessments/#{{ assessment.morea_id }}">{{ assessment.title }}</a>{% unless forloop.last %}, {% endunless %}
        {% endfor %}
        </p>
    {% endunless %}

  </div>
</div>

{% endif %}

{% endfor %}


