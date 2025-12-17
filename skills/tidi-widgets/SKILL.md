---
name: tidi-widgets
description: Use when creating or modifying Tidi CMS widgets - enforces standard widget class structure, getter methods, render() patterns, config.json parameters, and template variable passing
---

# Tidi Widgets Skill

## Overview

Enforce consistent PHP widget development patterns for Tidi CMS. This skill ensures widgets follow the established class structure, parameter definitions, and template integration patterns.

**Core principle:** Widgets prepare data in PHP and expose it via getters for templates.

## When to Use

- Creating new Tidi widgets
- Modifying existing widget classes
- Adding new parameters to widget configuration
- Implementing data retrieval and processing in widgets
- Debugging widget rendering issues

## Mandatory Information Gathering

**BEFORE creating any widget code, you MUST ask the user for:**

1. **Project namespace** - The root namespace for the project (e.g., `Acess`, `Riskant`, `ClientName`)
   > "What is the project namespace? (e.g., Acess, Riskant, etc.)"

2. **Theme name** - The theme name used in paths (e.g., `AcessTheme`, `RiskantTheme`)
   > "What is the theme name? (e.g., AcessTheme, RiskantTheme, etc.)"

Do NOT assume these values - they vary between projects and incorrect namespaces will cause errors.

## Widget Class Structure

### Basic Widget Class

```php
<?php

declare(strict_types=1);

namespace {Project}\Widget\WidgetName;

use Tidi\Cms\Core\Widget\AbstractWidget;

final class WidgetNameWidget extends AbstractWidget
{
    private readonly SomeRepository $repository;

    public function __construct(SomeRepository $repository)
    {
        parent::__construct();
        $this->repository = $repository;
        $this->template = '@{Project}WidgetWidgetName/widget_name.html.twig';
    }

    // Getter methods for template access
    public function getContainerClassName(): string
    {
        return $this->getParam('container_class') ?: 'w-widget-name';
    }

    public function getClassName(): string
    {
        return $this->getParam('class_name') ?: '';
    }

    public function showTitle(): bool
    {
        return (bool) $this->getParam('show_title', true);
    }

    public function showImage(): bool
    {
        return (bool) $this->getParam('show_image', true);
    }

    public function getTitle(): string
    {
        return $this->getParam('title') ?: 'Default Title';
    }

    public function getItemCount(): int
    {
        return (int) $this->getParam('item_count', 4);
    }

    public function render(): string
    {
        // Build data array for template
        $items = $this->repository->findItems($this->getItemCount());

        $itemData = [];
        foreach ($items as $item) {
            $itemData[] = [
                'entity' => $item,
                'image' => $this->resolveImage($item),
                'link' => $this->resolveLink($item),
            ];
        }

        $this->templateVars['itemData'] = $itemData;

        return parent::render();
    }

    private function resolveImage($item): ?object
    {
        // Image fallback logic
        if ($item->hasImage()) {
            return $item->getImages()->first();
        }
        // Fallback to related entity image if available
        return null;
    }

    private function resolveLink($item): ?array
    {
        // Link resolution logic
        return null;
    }
}
```

### Key Patterns

1. **Use `final` class** - Widgets should not be extended
2. **Use `readonly` properties** - For injected dependencies
3. **Set template in constructor** - Using `@BundleName/template.html.twig` format
4. **Getter methods** - Expose all parameters via getters for templates
5. **`render()` method** - Build data and set `$this->templateVars`

## Standard Widget Parameters

Every widget should support these standard parameters in `config.json`:

```json
{
    "name": "Widget Name",
    "description": "Widget description",
    "params": {
        "container_class": {
            "default": "",
            "type": "text",
            "input": "text",
            "description": "Override container class name (default w-widget-name)"
        },
        "class_name": {
            "default": "",
            "type": "text",
            "input": "text",
            "description": "Additional CSS classes for container"
        },
        "show_title": {
            "default": true,
            "type": "boolean",
            "input": "checkbox",
            "description": "Show widget title"
        },
        "show_image": {
            "default": true,
            "type": "boolean",
            "input": "checkbox",
            "description": "Show images"
        },
        "title": {
            "default": "Widget Title",
            "type": "string",
            "input": "text",
            "description": "Widget title",
            "help": "Title displayed above the widget"
        },
        "item_count": {
            "default": 4,
            "type": "integer",
            "input": "number",
            "description": "Number of items",
            "help": "Number of items to display"
        }
    }
}
```

### Parameter Types

| Type | Input | Description |
|------|-------|-------------|
| `text` | `text` | Simple text input |
| `string` | `text` | String value |
| `integer` | `number` | Numeric value |
| `boolean` | `checkbox` | True/false toggle |
| `entity` | `entity` | Entity selector (requires `entity` key) |
| `structureId` | `structureId` | Structure selector |

### Entity Parameter Example

```json
{
    "product_card": {
        "default": null,
        "type": "entity",
        "input": "entity",
        "entity": "{Project}\\Module\\ProductCards\\Entity\\ProductCard",
        "description": "Product Card",
        "help": "Filter by specific product card (optional)"
    }
}
```

## Getter Methods Pattern

Template accesses widget via `{{ widget.methodName }}`. Every parameter needs a getter:

```php
// For container_class parameter
public function getContainerClassName(): string
{
    return $this->getParam('container_class') ?: 'w-widget-name';
}

// For class_name parameter
public function getClassName(): string
{
    return $this->getParam('class_name') ?: '';
}

// For show_title parameter (boolean)
public function showTitle(): bool
{
    return (bool) $this->getParam('show_title', true);
}

// For show_image parameter (boolean)
public function showImage(): bool
{
    return (bool) $this->getParam('show_image', true);
}

// For title parameter
public function getTitle(): string
{
    return $this->getParam('title') ?: 'Default Title';
}

// For item_count parameter
public function getItemCount(): int
{
    return (int) $this->getParam('item_count', 4);
}

// For entity parameters (can be null)
public function getProductCard(): ?ProductCard
{
    return $this->getParam('product_card');
}

// For structure parameters
public function getOverviewStructure(): ?Structure
{
    $structureId = $this->getParam('overview_structure');
    if (!$structureId) {
        return null;
    }
    return $this->structureRepository->find($structureId);
}
```

## render() Method Pattern

The `render()` method should:
1. Fetch data from repositories
2. Process/transform data for template
3. Build template variables array
4. Call `parent::render()`

```php
public function render(): string
{
    // 1. Fetch entities
    $entities = $this->repository->findBy(
        ['active' => true],
        ['position' => 'ASC'],
        $this->getItemCount()
    );

    // 2. Process data for template
    $itemData = [];
    foreach ($entities as $entity) {
        $item = [
            'entity' => $entity,
            'name' => $entity->getName(),
        ];

        // Image fallback chain
        $item['image'] = $this->resolveImage($entity);

        // Link resolution
        $item['link'] = $this->resolveLink($entity);

        $itemData[] = $item;
    }

    // 3. Set template variables
    $this->templateVars['itemData'] = $itemData;

    // 4. Render
    return parent::render();
}
```

## Image Fallback Pattern

When entities have different image types (EmbeddedImage vs LibraryImage):

```php
private function resolveImage($entity): ?object
{
    // Primary: Entity's own image (EmbeddedImage)
    if ($entity->hasImage()) {
        $images = $entity->getImages();
        if ($images->count() > 0) {
            return $images->first();
        }
    }

    // Fallback: Related entity image (LibraryImage)
    $relatedEntity = $entity->getRelatedEntity();
    if ($relatedEntity) {
        $libraryImage = $relatedEntity->getImage();
        if ($libraryImage && $libraryImage->hasImage()) {
            return $libraryImage;
        }
    }

    // No image found - template will use placeholder
    return null;
}
```

**Important:**
- `EmbeddedImage` entities don't have `hasImage()` method - check via parent entity
- `LibraryImage` entities DO have `hasImage()` method
- Always return `null` for no image, template handles placeholder

## Link Resolution Pattern

For ProductCards system linking to product_group_detail:

```php
private function resolveLink($entity): ?array
{
    $relatedGroup = $entity->getGroupedBy();
    if (!$relatedGroup) {
        return null;
    }

    $productCard = $relatedGroup->getProductCard();
    if (!$productCard) {
        return null;
    }

    // Find first active & visible structure
    foreach ($productCard->getProductCardOverviews() as $overview) {
        $structure = $overview->getStructure();
        if ($structure && $structure->isActive() && $structure->isVisible()) {
            return [
                'structure' => $structure,
                'card_id' => $productCard->getId(),
                'card_title' => $productCard->getName(),
                'group_id' => $relatedGroup->getId(),
                'group_title' => $relatedGroup->getName(),
            ];
        }
    }

    return null;
}
```

## Service Registration

Register widget in `services.yaml`:

```yaml
{Project}\Widget\WidgetName\WidgetNameWidget:
    arguments:
        $repository: '@{Project}\Module\SomeModule\Repository\SomeRepository'
    tags:
        - { name: 'tidi.widget', alias: 'widget_name' }
```

*(Replace `{Project}` with the actual project namespace)*

## Directory Structure

```
src/{Project}/Widget/WidgetName/
├── WidgetNameWidget.php
└── Resources/
    ├── config/
    │   └── config.json
    └── views/
        └── widget_name.html.twig
```

*(Replace `{Project}` with the actual project namespace)*

## Verification Checklist

Before considering widget work complete:

- [ ] **Asked for project namespace** (do NOT assume)
- [ ] **Asked for theme name** (do NOT assume)
- [ ] Widget class is `final`
- [ ] Dependencies use `readonly` properties
- [ ] Template path set in constructor
- [ ] All standard parameters in config.json (container_class, class_name, show_title, show_image, title)
- [ ] Getter method for every parameter
- [ ] `getContainerClassName()` returns default if param empty
- [ ] `render()` builds data array, sets templateVars, calls parent::render()
- [ ] Image fallback logic handles null gracefully
- [ ] Link resolution handles null gracefully
- [ ] Service registered with `tidi.widget` tag

## Red Flags to Catch

| Problem | Solution |
|---------|----------|
| Direct property access in template | Add getter method |
| Logic in template | Move to widget PHP |
| Hardcoded CSS class | Use `getContainerClassName()` |
| Missing null check | Always check entities can be null |
| `hasImage()` on EmbeddedImage | Check via parent entity instead |

## Related Skills

- **tidi-templates**: For Twig template patterns
- **tidi-styling**: For LESS/CSS styling
