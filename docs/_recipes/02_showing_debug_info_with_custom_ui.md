---
layout: page
title: Using a custom UI to show debug info
permalink: /usage/recipes/custom-debug-ui
description: "How to write a custom UI to show debug info about the current state of G.U.I.D.E."
---

## Introduction

G.U.I.D.E ships with a [built-in debugger](https://github.com/godotneers/G.U.I.D.E/blob/main/addons/guide/debugger/guide_debugger.gd), but you may not like its layout, or it may not fit into your own debugging interface that you use for the rest of the game. So this recipe gives you a starting point on how to write your own debugging UI.

### Accessing G.U.I.D.E data for your custom UI

When driving a custom debug panel, you mainly need three kinds of information from G.U.I.D.E at runtime:

- Which action mappings are currently active and what their state/value is.
- Which inputs are currently active and what their raw values are.
- Where multiple actions share the same input and how the priority shakes out.

The built-in debugger shows all of this by reading the live state from the `GUIDE` autoload. The snippets below focus on how to access the data so you can render it in any UI you like.

> **Note**: Members starting with an underscore are internal API. They are not considered stable and may change without warning in future versions. Prefer public properties and signals where available. If you decide to use internal members for debugging UIs, keep this warning in mind and Check if your UI still works after you update G.U.I.D.E.

#### Refreshing when mappings change

- Listen to `GUIDE.input_mappings_changed` to refresh anything that depends on the currently active mapping contexts (e.g. priority/overlap lists). This signal fires whenever active contexts are re-evaluated.

```gdscript
func _ready() -> void:
    GUIDE.input_mappings_changed.connect(_rebuild_from_contexts)
```

If your debug UI should tick even while hidden or while the scene is paused, consider setting process_mode to `Node.PROCESS_MODE_ALWAYS` on your panel script and guard your per-frame work with `is_visible_in_tree()`.

#### Enumerating active action mappings

- `GUIDE._active_action_mappings` contains the active `GUIDEActionMapping` entries in their current priority order.
- Each mapping has an `action: GUIDEAction` you can inspect.
- You can get a human readable name of the action with: `action._editor_name()`.
- To present the current state: use either the convenience methods (`action.is_triggered()`, `action.is_ongoing()`) or read the last state from the internal enum `action._last_state` (values: `TRIGGERED`, `ONGOING`, `COMPLETED`).
- To present the current value: choose the value property that matches the action’s configured value type: `value_bool`, `value_axis_1d`, `value_axis_2d` or `value_axis_3d`.

Example access pattern for listing active actions, their state and value:

```gdscript
for mapping:GUIDEActionMapping in GUIDE._active_action_mappings:
    var action:GUIDEAction = mapping.action

    var name := action._editor_name()

    var state_text := ""
    if action.is_triggered():
        state_text = "Triggered"
    elif action.is_ongoing():
        state_text = "Ongoing"
    elif action.was_completed():
        state_text = "Completed"

    var value_text := ""
    match action.action_value_type:
        GUIDEAction.GUIDEActionValueType.BOOL:
            value_text = str(action.value_bool)
        GUIDEAction.GUIDEActionValueType.AXIS_1D:
            value_text = str(action.value_axis_1d)
        GUIDEAction.GUIDEActionValueType.AXIS_2D:
            value_text = str(action.value_axis_2d)
        GUIDEAction.GUIDEActionValueType.AXIS_3D:
            value_text = str(action.value_axis_3d)

    # Use name, state_text, value_text to drive your UI.
```
#### Enumerating currently active inputs

G.U.I.D.E tracks inputs that are currently contributing to action values:

- `GUIDE._active_inputs` is a dictionary of live input instances; iterate its `.values()` to access them.
- Each input has an internal numeric vector value at `input._value` (`Vector3`). This is the raw, aggregated value after modifiers and triggers have been applied in the active contexts.
- To get a human-readable label for an input instance that respects the active contexts and their configuration, use a formatter:
  - Create one with `GUIDEInputFormatter.for_active_contexts()`.
  - Call `formatter.input_as_text(input, false)` to get a concise label.

Example access pattern for listing active inputs and their current values:

```gdscript
var formatter:GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()
for input in GUIDE._active_inputs.values():
    var label := formatter.input_as_text(input, false)
    var value := input._value  # Vector3 (internal)
    # Use label and value to drive your UI.
```
#### Inspecting input overlaps and priorities

When multiple actions share the same input, G.U.I.D.E will resolve which action wins based on priority and blocking rules. To present overlap information:

- `GUIDE._actions_sharing_input` maps a `GUIDEAction` to a list of other `GUIDEAction` instances that currently share the same effective input.
- Rebuild any overlap/priority lists when `GUIDE.input_mappings_changed` fires.

Example access pattern for building a simple overlap list:

```gdscript
func _rebuild_from_contexts() -> void:
    for mapping:GUIDEActionMapping in GUIDE._active_action_mappings:
        var action := mapping.action
        if GUIDE._actions_sharing_input.has(action):
            var others:Array = GUIDE._actions_sharing_input[action]
            var names := ", ".join(others.map(func(a): return a._editor_name()))
            var summary := "[" + action._editor_name() + "] > [" + names + "]"
            # Use summary in your UI.
```

This mirrors what the shipped debugger displays in its “Priorities” section.

## Example

[Laurent Senta](https://gist.github.com/laurentsenta) has created a custom debug panel that uses IMGUI to display the current input state. 

![G.U.I.D.E debug information in IMGUI]({{ site.baseurl }}/assets/img/recipes/imgui_example.png)

You can find the code for this on [GitHub](https://gist.github.com/laurentsenta/5e7c5539c22d4687d7ee9330069710f8).

