---
name: tidi-styling
description: Use when writing CSS/LESS styles for Tidi projects - enforces BEMIT methodology, checks existing mixins/variables/placeholders in budspencer and project theme before creating new ones, ensures code goes in src/ folder only
---

# Tidi Styling Skill

## Overview

Enforce consistent styling practices for Tidi CMS projects using the BudSpencer framework. This skill ensures you check existing tooling before creating new styles, follow BEMIT conventions, and write code in the correct locations.

**Core principle:** Check before create. The codebase is the source of truth.

## When to Use

- Creating new CSS/LESS styles for Tidi projects
- Modifying existing styles in a project theme
- Adding styling for components, widgets, or modules
- Debugging CSS specificity or inheritance issues
- Reviewing styling code

## The Mandatory Pre-Flight Checklist

Before writing ANY new styles, complete this checklist:

### 1. Identify What You're Styling

Determine the correct namespace prefix:
- `g-` Global (used on every page)
- `o-` Object (abstract, reusable layout)
- `c-` Component (specific UI piece)
- `m-` Module (CMS module)
- `w-` Widget (CMS widget)
- `u-` Utility (helper class)
- `is-`/`has-` State (temporary)
- `js-` JavaScript hook (no styling)

### 2. Check BudSpencer First

Read these files to find existing tooling:

```
bundles/themes/tidi/budspencer-theme/Resources/assets/less/
├── 1-settings/__settings.less    → colors, breakpoints, typography
├── 1-settings/_*.less            → specific setting categories
├── 2-tools/_mixins.less          → reusable mixins
└── 2-tools/_placeholders.less    → reusable placeholder patterns
```

### 3. Check Project Theme Second

```
src/[Project]/Theme/[Name]Theme/Resources/assets/less/
├── 1-settings/__settings.less    → project color overrides
├── 2-tools/_mixins.less          → project-specific mixins
└── 2-tools/_placeholders.less    → project-specific placeholders
```

### 4. Ask If Unsure

If you find something that looks potentially useful but the meaning is unclear:
- **ASK** the user: "I see `.ph-card-stretched-link()` - would this work for your use case?"
- **Never assume** - BudSpencer and project themes evolve, new tooling gets added
- The actual files are always more current than any memorized list

### 5. Reuse or Create

- **Found existing?** Use it (extend, include, apply the mixin/variable)
- **Nothing fits?** Create new code in `src/` folder (NEVER in budspencer)

## Where New Code Goes

All new styling code must go in the project theme under `src/`:

```
src/[Project]/Theme/[Name]Theme/Resources/assets/less/
├── 1-settings/      → New variables
├── 2-tools/         → New mixins/placeholders
├── 6-0-global/      → New global styles
├── 6-1-components/  → New components (_c-*.less)
├── 6-2-modules/     → New module styles (_m-*.less)
├── 6-3-widgets/     → New widget styles (_w-*.less)
└── style.less       → Import new files here
```

**Register new files in style.less:**
```less
/* Add under the appropriate "ACE - OVERWRITE" section */

/* -----[ ACE - OVERWRITE ]----- */
@import "6-1-components/_c-your-new-component";
```

## ITCSS Layer Reference

| Layer | Folder | Purpose | Outputs CSS? |
|-------|--------|---------|--------------|
| 1 | 1-settings | Variables (colors, typography, breakpoints) | No |
| 2 | 2-tools | Mixins and placeholders | No |
| 3 | 3-generic | Third-party CSS (Bootstrap, FontAwesome) | Yes |
| 4 | 4-elements | Raw HTML elements (h1, p, a) | Yes |
| 5 | 5-objects | Structural patterns (o-container) | Yes |
| 6 | 6-0/1/2/3 | Global, Components, Modules, Widgets | Yes |
| 7 | 7-utilities | Helper classes (only `!important` here) | Yes |

## BEM Naming Convention

**Correct - flat structure, searchable:**
```less
.w-block {
    &:hover {}
    &::after {}
}

.w-block__element {
    &:hover {}
}

.w-block__element--modifier {
    &:hover {}
}
```

**Wrong - nested &, hard to search:**
```less
/* DO NOT DO THIS */
.w-block {
    &__element {
        &--modifier {}
    }
}
```

## Variable Naming Convention

Pattern: `@property-block__selector--modifier`

```less
/* Examples */
@color-header__text-link--hover
@height-header-content--navicon-visible
@font-family-base--heading
```

## Color Naming Convention

```less
/* 1. Define named color (use color-blindness.com for names) */
@color--jazzberry-jam: #9f0c47;

/* 2. Assign to brand palette */
@brand-primary: @color--jazzberry-jam;

/* 3. Use brand in components */
@color-header__background: @brand-primary;
```

**Never hardcode colors** - always use variables.

## Comment Format

```less
/* =====[ SECTION TITLE ]============================================= */
/* -----[ subsection ]------------------------------------------------ */
/* -----[ sub sub section ]----- */
```

- Total divider length = 80 characters
- Use `/* */` for all comments
- Exception: `//` only for temporarily disabling declarations
- No `TODO` or `FIXME` in production code

## Breakpoints Reference

Always read the actual files, but common breakpoints:
```less
@screen--ss: 320px    @screen--lg: 1248px
@screen--xs: 480px    @screen--xl: 1366px
@screen--sm: 768px    @screen--xx: 1536px
@screen--md: 992px    @screen--xy: 1920px
                      @screen--xz: 2560px

/* Navicon visibility shortcuts */
@media (max-width: @screen__navicon--visible) {}
@media (min-width: @screen__navicon--hidden) {}
```

## Build Workflow

**After writing styles, always compile:**
```bash
grunt          # Full build
grunt watch    # Watch mode during development
```

## Verification Checklist

Before considering styling work complete:

- [ ] Read budspencer tooling files first
- [ ] Read project theme tooling files
- [ ] Used existing mixins/variables where possible
- [ ] Asked about unclear but potentially useful tooling
- [ ] New files created in `src/` folder only
- [ ] New files imported in `style.less`
- [ ] Follows BEM naming with correct namespace
- [ ] No hardcoded colors (use variables)
- [ ] No hardcoded breakpoints (use @screen--* vars)
- [ ] Ran `grunt` successfully
- [ ] Flat BEM structure (no nested `&__`)

## Red Flags to Catch

| Problem | Solution |
|---------|----------|
| Hardcoded color `#9f0c47` | Use `@brand-primary` or define new `@color--name` |
| Hardcoded spacing `padding: 20px` | Use `.vertical-whitespace()` or `@grid-gutter-*` |
| Nested BEM `&__element` | Flatten: `.block__element {}` |
| New file in budspencer | Move to `src/` project theme |
| Missing import | Add to `style.less` under ACE - OVERWRITE |
| Unknown mixin that looks useful | Ask user before proceeding |

## Reference

- CSS Guidelines: https://cssguidelin.es/
- BEM: https://en.bem.info/
- BEM Cheat Sheet: https://9elements.com/bem-cheat-sheet/
- ITCSS: https://www.creativebloq.com/web-design/manage-large-css-projects-itcss-101517528
- BEMIT Namespaces: https://csswizardry.com/2015/03/more-transparent-ui-code-with-namespaces/
