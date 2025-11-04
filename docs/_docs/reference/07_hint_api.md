---
layout: page
title: GUIDE Icon Hint System
permalink: /reference/hints
description: 'Create composite input icons that combine multiple inputs into a single visual representation, like "WASD for movement"'
---

# {{ page.title }}

The GUIDE Icon Hint System lets you create composite input icons that combine multiple inputs into a single visual representation. Perfect for showing complex input combinations like "WASD for movement".

## Quick Start

### Basic Usage

```gdscript
# 1. Create a formatter
var formatter = GUIDEInputFormatter.for_active_contexts(icon_size)

# 2. Create and add hint
var hint = GUIDELayoutHint.cross(40.0)
formatter.add_icon_hint(my_action, hint)

# 3. Use it
var icon_text = await formatter.action_as_richtext_async(my_action)
my_label.text = "Move with " + icon_text
```

## Common Layout Patterns

### Pre-made Layouts

```gdscript
# Standard layouts
GUIDELayoutHint.cross(40.0)          # + pattern for WASD
GUIDELayoutHint.horizontal(35.0)     # horizontal line
GUIDELayoutHint.grid(3, 30.0)        # 3-column grid
GUIDELayoutHint.circle(50.0)         # circular arrangement

# Quick presets
GUIDELayoutHint.compact_cross()      # tight WASD layout
GUIDELayoutHint.spaced_horizontal()  # wide horizontal layout
```

### Styling Your Icons

```gdscript
# Basic styling with method chaining
var hint = GUIDELayoutHint.cross(40.0) \
  .with_global_tint(Color.CYAN) \
  .with_global_scale(1.2)

# Individual input styling
var custom_hint = GUIDELayoutHint.cross(40.0) \
  .with_input_config(0, 1.5, 0, Vector2.ZERO, Color.WHITE) \  # first input: bigger, white
  .with_input_config(1, 0.8, 0, Vector2.ZERO, Color.YELLOW)   # second input: smaller, yellow
```

### Input Filtering

```gdscript
# Show only first 4 inputs (useful for WASD when both keyboard and gamepad are mapped)
var hint = GUIDELayoutHint.cross(40.0).with_first_inputs(4)

# Show specific inputs only
var hint = GUIDELayoutHint.horizontal(40.0).with_inputs([0, 2, 3])

# Limit total inputs shown
var hint = GUIDELayoutHint.grid(3, 40.0).with_max_inputs(6)
```

## Common Use Cases

### Movement Controls

```gdscript
# WASD movement
var movement_hint = GUIDELayoutHint.cross(35.0)
formatter.add_icon_hint(movement_action, movement_hint)
```

### Action Combos

```gdscript
# Combat combo with styling
var combo_hint = GUIDELayoutHint.horizontal(45.0) \
  .with_global_tint(Color.RED) \
  .with_global_scale(1.1)
formatter.add_icon_hint(combat_action, combo_hint)
```

### UI Context Scaling

```gdscript
# Different sizes for different UI areas
func create_ui_hint(action: GUIDEAction, ui_area: String) -> GUIDEIconHint:
  var base_hint = GUIDELayoutHint.cross(40.0)

  match ui_area:
    "tooltip": return base_hint.with_global_scale(0.8)
    "hud": return base_hint.with_global_scale(1.2)
    "menu": return base_hint.with_global_scale(1.0)
    _: return base_hint
```

## Key Classes

### GUIDELayoutHint
The main class you'll use. Provides layout patterns and styling options.

### IconPosition
Defines where each input appears in the composite (position, scale, rotation, color).

### IconDisplayConfig
Visual styling configuration (scale, rotation, tint, etc.).

## API Quick Reference

### Essential Methods

```gdscript
# Layout creation
GUIDELayoutHint.cross(spacing)
GUIDELayoutHint.horizontal(spacing)
GUIDELayoutHint.grid(columns, spacing)

# Styling
.with_global_tint(color)
.with_global_scale(multiplier)
.with_global_offset(offset)

# Input selection
.with_first_inputs(count)
.with_max_inputs(count)
.with_inputs([indices])

# Per-input styling
.with_input_config(index, scale, rotation, offset, tint)
```

### Scale Values Guide
- `0.5` = Half size
- `1.0` = Normal size (default)
- `1.5` = 50% larger
- `2.0` = Double size

## Performance Tips

1. **Reuse hints** - Create once, use multiple times
2. **Reasonable spacing** - Keep between 8-500 pixels
3. **Limit inputs** - 4-6 inputs max per composite
4. **Consistent sizing** - Use same icon sizes throughout your app

The system automatically handles caching, error handling, and performance optimization.
