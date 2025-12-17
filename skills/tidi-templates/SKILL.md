---
name: tidi-templates
description: Use when writing Twig templates for Tidi widgets or modules - enforces global class patterns (g-block, g-card), dual naming conventions, proper block structure for extensibility, and image handling with placeholder fallback
---

# Tidi Templates Skill

## Overview

Enforce consistent Twig template patterns for Tidi CMS widgets and modules. This skill ensures you use the dual-class naming system, proper block structure, and standard image/link handling.

**Core principle:** Templates should be extensible and follow established patterns.

## When to Use

- Creating new Twig templates for Tidi widgets
- Updating existing widget templates
- Working on module templates that display lists of items (news, products, promotions)
- Adding new template blocks or extending existing templates
- Implementing image handling with placeholders

## Global Class System

Tidi uses a dual-class naming system combining widget-specific classes with global reusable classes.

### Global Block Classes (`g-block__*`)
Used for overall container and structure:
- `g-block` - Main container for overview/list widgets
- `g-block__container` - Inner container
- `g-block__header` - Header section
- `g-block__title` - Widget title
- `g-block__content` - Main content area
- `g-block__item` - Individual item in a list
- `g-block__footer` - Footer section
- `g-block__visit-overview` - Link to overview page

### Global Card Classes (`g-card__*`)
Used for individual items/cards:
- `g-card` - Card container
- `g-card__container` - Inner card wrapper
- `g-card__figure` - Image container
- `g-card__image` - Image element
- `g-card__image-overlay` - Overlay on hover
- `g-card__header` - Card header
- `g-card__title` - Card title
- `g-card__content` - Card content area
- `g-card__link` - Links within card
- `g-card__read-more` - Read more section

### Dual Naming Convention

**ALWAYS combine widget-specific AND global classes:**

```twig
{# CORRECT: Both widget-specific and global classes #}
<article class="{{ widget.containerClassName }}__item g-block__item g-card">

{# WRONG: Only widget-specific class #}
<article class="{{ widget.containerClassName }}__item">
```

## Widget Container Structure

Always use this structure for widget templates:

```twig
{% if items is defined and items is not empty %}
{% block content %}
    <section class="{{ widget.containerClassName }} {{ widget.className }} g-block g-block--overview">
        <div class="{{ widget.containerClassName }}__container g-block__container">

            {% if widget.showTitle %}
                {% block header %}
                    <header class="{{ widget.containerClassName }}__header g-block__header">
                        <h3 class="{{ widget.containerClassName }}__header-title g-block__title">{{ widget.title }}</h3>
                    </header>
                {% endblock header %}
            {% endif %}

            {% block list %}
                {# Content goes here #}
            {% endblock list %}

            {% if widget.showOverviewLink %}
                {% block footer %}
                    <footer class="{{ widget.containerClassName }}__footer g-block__footer">
                        {# Footer content #}
                    </footer>
                {% endblock footer %}
            {% endif %}

        </div>
    </section>
{% endblock content %}
{% endif %}
```

**Key Points:**
- Outer check: `{% if items is defined and items is not empty %}`
- Wrap everything in `{% block content %}` for extensibility
- Use `{{ widget.containerClassName }}` from PHP (e.g., `w-latest-news`)
- Use `{{ widget.className }}` for additional custom classes
- Always add global classes alongside widget-specific classes

## Item/Card Structure

For items within a list (promotions, news, products):

```twig
{% block list %}
    <div class="{{ widget.containerClassName }}__content g-block__content g-card__wrapper g-card__wrapper--overview">
        {% for item in items %}
            {% block item %}
                <article class="{{ widget.containerClassName }}__item g-block__item g-card g-card--{{ widget.containerClassName|replace({'w-': ''}) }}">
                    <div class="{{ widget.containerClassName }}__item-container g-block__item-container g-card__container">

                        {% if widget.showImage %}
                            {% block item_figure %}
                                <figure class="{{ widget.containerClassName }}__item-figure g-block__item-figure g-card__figure">
                                    {% if item.link %}
                                        <a class="{{ widget.containerClassName }}__item-link {{ widget.containerClassName }}__item-figure-link {{ widget.containerClassName }}__item-figure-content g-block__item-link g-block__item-figure-link g-block__item-figure-content g-card__link g-card__figure-link g-card__figure-content"
                                           href="{{ item.link }}">
                                    {% endif %}
                                        <img class="{{ widget.containerClassName }}__item-image g-block__item-image g-card__image img-responsive"
                                             src="{%- if item.image -%}{{ cropped_image_asset(item.image, 'uploadedImage') }}{%- else -%}/assets/dist/img/placeholder.gif{%- endif %}"
                                             alt="{{ item.name }}">
                                        <div class="{{ widget.containerClassName }}__item-image-overlay g-block__item-image-overlay g-card__image-overlay"></div>
                                    {% if item.link %}
                                        </a>
                                    {% endif %}
                                </figure>
                            {% endblock item_figure %}
                        {% endif %}

                        {% block item_header %}
                            <header class="{{ widget.containerClassName }}__item-header g-block__item-header g-card__header">
                                {% block item_title %}
                                    <h1 class="{{ widget.containerClassName }}__item-title g-block__item-title g-card__title">
                                        {% if item.link %}
                                            <a class="{{ widget.containerClassName }}__item-link {{ widget.containerClassName }}__item-title-link {{ widget.containerClassName }}__item-title-content g-block__item-link g-block__item-title-link g-block__item-title-content g-card__link g-card__title-link g-card__title-content"
                                               href="{{ item.link }}">{{ item.name }}</a>
                                        {% else %}
                                            <span class="{{ widget.containerClassName }}__item-title-content g-block__item-title-content g-card__title-content">{{ item.name }}</span>
                                        {% endif %}
                                    </h1>
                                {% endblock item_title %}
                            </header>
                        {% endblock item_header %}

                        {% block item_content %}
                            <div class="{{ widget.containerClassName }}__item-content g-block__item-content g-card__content">
                                {# Item content here #}
                            </div>
                        {% endblock item_content %}

                    </div>
                </article>
            {% endblock item %}
        {% endfor %}
    </div>
{% endblock list %}
```

## Block Naming Convention

Every section should be wrapped in named blocks for extensibility:

- Main sections: `content`, `header`, `list`, `footer`
- Item sections: `item`, `item_figure`, `item_header`, `item_title`, `item_content`, `item_readmore`
- Use descriptive names that indicate the content type

## Image Handling

Always provide placeholder fallback for missing images:

```twig
{# For entities with image property #}
<img src="{%- if item.image -%}{{ cropped_image_asset(item, 'uploadedImage') }}{%- else -%}/assets/dist/img/placeholder.gif{%- endif %}"
     alt="{{ item.name }}">

{# For multiple image fallbacks #}
<img src="{%- if item.image.name is not empty -%}
              {{ cropped_image_asset(item, 'uploadedImage') }}
          {%- elseif item.fallbackImage is defined and item.fallbackImage -%}
              {{ cropped_image_asset(item.fallbackImage, 'uploadedImage') }}
          {%- else -%}
              /assets/dist/img/placeholder.gif
          {%- endif %}"
     alt="{{ item.name }}">
```

**Key Points:**
- Always use `cropped_image_asset(entity, 'uploadedImage')` for Tidi entities
- Fallback to `/assets/dist/img/placeholder.gif`
- Use `{%- -%}` to avoid whitespace in src attribute

## Link Generation

Use appropriate link generation based on context:

```twig
{# For structure-based detail pages (news, promotions) #}
<a href="{{ path('_structure_'~ structureId ~ '_detail', {
    'id': item.id,
    'title': item.name|slugify,
    '_format': 'html'
}) }}">

{# For structure paths (overview links) #}
<a href="{{ structure_path(widget.overviewStructure) }}">

{# For ProductCards system (product_group_detail route) #}
<a href="{{ path(structure_route(link.structure, 'product_group_detail'), {
    'card_id': link.card_id,
    'card_title': link.card_title|slugify,
    'group_id': link.group_id,
    'group_title': link.group_title|slugify,
    '_format': 'html'
}) }}">
```

## Translation Keys

Use consistent translation key patterns:

```twig
{{ 'widget.module_name.action'|trans }}
{{ 'latestnews.read.more'|trans }}
{{ 'widget.promotions_module.overview'|trans }}
```

## Verification Checklist

Before considering template work complete:

- [ ] Template starts with `{% if items is defined and items is not empty %}`
- [ ] Everything wrapped in `{% block content %}` or appropriate parent block
- [ ] ALL elements use dual classes: widget-specific + global (`g-block__*` or `g-card__*`)
- [ ] Container uses `{{ widget.containerClassName }}` and `{{ widget.className }}`
- [ ] All major sections wrapped in named `{% block %}` tags
- [ ] Images have placeholder fallback (`/assets/dist/img/placeholder.gif`)
- [ ] Links use proper Symfony routing (`path()` or `structure_path()`)
- [ ] Conditional rendering based on widget parameters (`widget.showTitle`, `widget.showImage`, etc.)
- [ ] Translation keys follow pattern: `'widget.module.action'|trans`
- [ ] Icons use FontAwesome classes (`fas fa-*`, `fal fa-*`)

## Related Skills

- **tidi-widgets**: For PHP widget class structure and parameters
- **tidi-styling**: For LESS/CSS styling of these templates
