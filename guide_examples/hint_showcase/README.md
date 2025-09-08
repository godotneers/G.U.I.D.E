# GUIDE Hint System Showcase

This example demonstrates all the current features of the GUIDE hint system for creating composite input icons.

## Features Demonstrated

### 1. Basic Cross Layout
- Simple, clean cross arrangement
- Default spacing and colors

### 2. Advanced Styling
- Custom colors for individual inputs
- Rotation effects
- Scaling adjustments
- Position offsets
- Global tinting

### 3. Preset Layouts
- **Compact Cross**: Tight spacing for dense UIs
- **Spaced Horizontal**: Wide horizontal arrangement
- **3-Column Grid**: Organized grid layout
- **Small Circle**: Circular input arrangement
- **Smart Grid**: Intelligent grid sizing

### 4. Custom Layouts
- Manual positioning with Vector2 arrays
- Complete control over input placement
- Combined with styling options

### 5. Dynamic Layouts
- Runtime layout switching
- Context-sensitive arrangements

## Builder Pattern Usage

The system uses a fluent builder pattern for easy configuration:

```gdscript
var hint = GUIDELayoutHint.cross(45.0) \
    .with_center_first(true) \
    .with_global_tint(Color.ORANGE) \
    .with_input_config(0, 1.3, 0, Vector2.ZERO, Color.WHITE) \
    .with_input_config(1, 0.9, 15, Vector2(-3, -8), Color.YELLOW)
```

## Practical Applications

### Context-Sensitive Hints
```gdscript
func create_context_sensitive_hint(action: GUIDEAction, player_level: int, is_combat: bool) -> GUIDEIconHint:
    if is_combat and player_level > 10:
        return GUIDELayoutHint.compact_cross().with_global_tint(Color.RED)
    elif player_level < 5:
        return GUIDELayoutHint.spacious_cross().with_global_tint(Color.LIGHT_BLUE)
    else:
        return GUIDELayoutHint.cross()
```

### Controller-Specific Layouts
```gdscript
func create_controller_specific_hint(action: GUIDEAction) -> GUIDEIconHint:
    match active_device:
        "keyboard":
            return GUIDELayoutHint.compact()
        "xbox_controller":
            return GUIDELayoutHint.diamond(40.0).with_global_tint(Color.GREEN)
        "playstation_controller":
            return GUIDELayoutHint.diamond(40.0).with_global_tint(Color.BLUE)
```

### Accessibility Support
```gdscript
func create_accessibility_hint(action: GUIDEAction, high_contrast: bool, large_icons: bool) -> GUIDEIconHint:
    var spacing = 50.0 if large_icons else 32.0
    var hint = GUIDELayoutHint.cross(spacing)

    if high_contrast:
        hint = hint.with_global_tint(Color.WHITE)
        hint = hint.with_input_config(0, 1.5, 0, Vector2.ZERO, Color.YELLOW)

    return hint
```

## Setup Instructions

1. Create actions for movement, combat, inventory, and spell casting
2. Assign them to the showcase scene's exported properties
3. Run the scene to see all features in action
4. Check the dynamic example that cycles through different layouts

## Key Benefits

- **Automatic Input Detection**: No need to manually specify which keys are used
- **Fluent API**: Easy to read and write configuration code
- **Rich Styling**: Full control over colors, rotations, scaling, and positioning
- **Performance**: Proper caching ensures smooth rendering
- **Flexibility**: Works with any input type (keyboard, mouse, controller)
- **Accessibility**: Built-in support for high contrast and large icon modes
