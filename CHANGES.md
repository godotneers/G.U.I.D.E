# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- `GUIDEMappingContext` now has signals `enabled` and `disabled` which fire when the context is enabled or disabled. This can be useful to trigger some game logic when a context is activated or deactivated. A big thanks goes to [Jonathan Durbin](https://github.com/jonathan-durbin) for providing a PR for this ([#119](https://github.com/godotneers/G.U.I.D.E/pull/119)).


## [0.8.0] - 2025-09-29
### Added
- Added magnitude modifier. This is useful to determine the strength of an input vector, e.g. to determine how far a joystick is pushed. 

## [0.7.5] - 2025-08-19
### Fixed
- Popup menus should now appear at the correct positions in multi-monitor and wide-screen setups ([#88](https://github.com/godotneers/G.U.I.D.E/issues/88), [#108](https://github.com/godotneers/G.U.I.D.E/issues/108)).


## [0.7.4] - 2025-08-11
### Fixed
- The input formatter should now properly format all keyboard and touch inputs ([#105](https://github.com/godotneers/G.U.I.D.E/issues/105)).

## [0.7.3] - 2025-07-31
### Fixed
- When layering mapping contexts G.U.I.D.E will no longer ignore bound inputs ([#94](https://github.com/godotneers/G.U.I.D.E/issues/94)).

## [0.7.2] - 2025-07-29
### Fixed
- Input detection will now be properly aborted when an abort input is actuated ([#92](https://github.com/godotneers/G.U.I.D.E/issues/92)).

## [0.7.1] - 2025-07-29
### Fixed
- When layering mapping contexts, G.U.I.D.E will no longer duplicate actions ([#89](https://github.com/godotneers/G.U.I.D.E/issues/89), [#93](https://github.com/godotneers/G.U.I.D.E/issues/93)).

## [0.7.0] - 2025-07-01
### Breaking Changes
- G.U.I.D.E will now preserve state of triggers when switching mapping contexts. In addition, triggers that become active as a result of a context being activated, will be initialized with the current input. This will avoid issue with triggers stopping to trigger or triggering too often when switching mapping contexts. This fixes some issues introduced with 0.6.0. Since this changes the behaviour of triggers, I declare this a breaking change. Please check your triggers after updating to ensure they still work as expected ([#81](https://github.com/godotneers/G.U.I.D.E/issues/81)).

## [0.6.4] - 2025-06-14
### Added
- Added support for the PS5 touchpad to the icon renderer and text provider, so this will now properly display in input prompts ([#74](https://github.com/godotneers/G.U.I.D.E/issues/74)).

### Fixed
- When pressing keys or buttons so rapidly that both the press and release happen to occur in the same frame, G.U.I.D.E would ignore the press event. This has now been fixed. So if a key or button changes state multiple times in a frame, the result of the first state change is used for evaluation this frame. At the end of the frame, the last state, which was recorded in the frame, is restored. This will technically still drop events (e.g. if a button state changes five times in a frame, only the first and last state change will influence triggers) however for all practical purposes this should be good enough. ([#77](https://github.com/godotneers/G.U.I.D.E/issues/77)).

## [0.6.3] - 2025-05-20
### Added
- Added a new example showing how to use controller or keyboard & mouse for a top-down shooter ([#64](https://github.com/godotneers/G.U.I.D.E/issues/64)).

### Improved
- The mapping editor now shows the action value type next to the action name. This helps debugging unexpected behaviour when using an unsuitable action value type for an action. A big thanks goes to [Jose Ramon Rodriguez](https://github.com/jramonrod) for submitting a PR for this ([#59](https://github.com/godotneers/G.U.I.D.E/issues/59), [#63](https://github.com/godotneers/G.U.I.D.E/pull/63))!


### Fixed
- When detecting input for re-binding the `GUIDEInputDetector` will ensure that G.U.I.D.E's input state still receives events. This avoids issues where the player re-binds a key and this key will not work correctly afterward, because G.U.I.D.E's input state was not updated and now has diverged from the actual input state.
- G.U.I.D.E will now ignore input mappings with a missing action. A missing action will be shown as a warning in the mapping context editor and at runtime ([#66](https://github.com/godotneers/G.U.I.D.E/issues/66)).
- The icons for the mouse side buttons now properly reflect the physical position of these buttons. If you still get the wrong icons, please delete the `_guide_cache` folder in your user data folder. This will recreate the icons. You can open your user data folder by going to _Project_ > _Open User Data Folder_ in the Godot editor ([#65](https://github.com/godotneers/G.U.I.D.E/issues/65)).

## [0.6.2] - 2025-05-05
### Improved
- The `GUIDEInputDetector` now consumes all input events while it is detecting input. This avoids the problem of input accidentally triggering something else (e.g. the Godot UI) while the input is being detected.

### Fixed
- The input detector no longer shows errors when the detection is started again from outside code while it is already running.


## [0.6.1] - 2025-05-04
### Fixed
- The plugin version inside Godot is now properly updated.
- The plugin now ships with UID files for Godot 4.4. These files have no effect on earlier Godot versions ([#60](https://github.com/godotneers/G.U.I.D.E/issues/60)).

## [0.6.0] - 2025-05-02
### Breaking Changes
- The input collection system has received a major overhaul. G.U.I.D.E now uses a centralized input state from which all built-in `GUIDEInput` get updates. This makes the whole input collection a lot more efficient. Before each input event would be sent to each currently active `GUIDEInput`. Now the input is sent to a single collector which notifies each `GUIDEInput` about events that they have subscribed to. This significantly reduces the amount of work that needs to be done for each processed input. In addition to that, it allows for efficient querying of the current input state, so inputs like `GUIDEInputKey` can now work with a lot less calls into the engine. Another benefit is that input state is kept in a central place even when `GUIDEInput`s are deactivated. This allows a smooth change of mapping contexts without losing the current input state. Finally, this is some groundwork required for virtual joysticks which will be added in a future version.
- `GUIDEInput` no longer have an `_input` method as raw input is now handled in `GUIDEInputState`. Instead `GUIDEInput` now subscribes to signals in `GUIDEInputState`. If you have written your own `GUIDEInput`, this will affect you. Check the [documentation](https://godotneers.github.io/G.U.I.D.E/usage/extending-guide#creating-custom-inputs) for more information on how custom inputs now work. 
- Input is now no longer reset when mapping contexts are swapped out. So if you have two mapping contexts both listening for the key `W` to be pressed down, and you switch from one to the other while the key is pressed down, then the input previously would reset and the player would have to release and press the `W` key again for it to be detected. This is especially annoying in games where you have to hold a key to move or perform an action. Now the input will be kept active and the player can continue to use it without having to press the key again. Since this changes the behaviour of how input is reacting, I declare this a breaking change. If you have mapping contexts which share the same input, carefully check if things still work as intended. You may need to change trigger types (e.g. from _Pressed_ to _Released_) to prevent unwanted input ([#61](https://github.com/godotneers/G.U.I.D.E/issues/61)).

### Improved
- `GUIDEInputDetector` now automatically disables all mapping contexts when detecting input and restores them afterwards. This avoids accidentally triggering actions while detecting input and until now needed to be done manually. 
- The LICENSE file is now part of the packaged add-on. A big thanks goes to [Simply BLG](https://github.com/SimplyBLGDev) for submitting a PR for this!
- The test suite has received a good amount of work. It is still not where it could be, but a nice improvement over the previous version. 

## [0.5.3] - 2025-04-25
### Fixed
- The _Any_ input now properly actuates, if more than one watched input source actuates during the frame in any order ([#57](https://github.com/godotneers/G.U.I.D.E/issues/57)).

## [0.5.2] - 2025-04-14
### Fixed
- The _Remap range_ modifier now properly works when the output range is descending and clamp is enabled. Previously this would always return the left end of the output range ([#53](https://github.com/godotneers/G.U.I.D.E/issues/53)). 

## [0.5.1] - 2025-04-07
### Improved
- `GUIDEInputAny` now has settings to determine minimal mouse and joypad axis motion to be considered as input. This is useful to avoid accidental input when the mouse or joypad only moved slightly ([#26](https://github.com/godotneers/G.U.I.D.E/issues/26), [#52](https://github.com/godotneers/G.U.I.D.E/issues/52)). 

## [0.5.0] - 2025-04-01
### Breaking Change
- The `GUIDEInputDetector` now detects controller trigger buttons when looking for `BOOLEAN` input. Before it would only do this when detecting `AXIS_1D` input. Since triggers are very often used for boolean input, this behaviour was changed to keep it more in line with player expectations. If you want to keep the old behaviour, you can set the `allow_triggers_for_boolean_actions` property of `GUIDEInputDetector` to `false`. 

### Added
- `GUIDEAction` now has a new `elapsed_ratio` property which can be used to drive hold progress bars. When the mapping context is activated G.U.I.D.E will check if the action has any hold trigger bound to it and provide some information for an `elapsed_ratio` property on the action to update.  This `elapsed_ratio` will go from 0 to 1 as the hold time elapses and stay at 1 while the action is triggered. If the action has no hold trigger, then `elapsed_ratio` will stay at 0 while the action is not triggered, and go to 1 when the action is triggered ([#48](https://github.com/godotneers/G.U.I.D.E/issues/48)). 

### Fixed
- Removed a font file that was unnecessarily embedded into the mapping context editor scene, bloating its file size ([#49](https://github.com/godotneers/G.U.I.D.E/issues/49)).


## [0.4.2] - 2025-03-25
### Fixed
- G.U.I.D.E now properly detects the PlayStation DualSense controller range as PlayStation controller. A big thanks goes to [laternRaft](https://github.com/laternRaft) for submitting a PR for this and helping with testing ([#43](https://github.com/godotneers/G.U.I.D.E/pull/43)).

## [0.4.1] - 2025-03-13
### Fixed
- Binding a modifier key as the key input (e.g. shift for running) will now work even if "allow additional modifiers" is set to false ([#34](https://github.com/godotneers/G.U.I.D.E/issues/34)).

## [0.4.0] - 2025-03-06
### Breaking Changes
- Removed `get_display_categories` and `get_remappable_actions` from `GUIDEMappingContext`. These methods were added before `GUIDERemapper` was introduced and are now obsolete. If you used these methods, switch to [using `GUIDERemapper` instead](https://godotneers.github.io/G.U.I.D.E/usage/remapping-input) ([#23](https://github.com/godotneers/G.U.I.D.E/issues/23)).

### Improved
- It is now possible to share both modifiers and triggers between multiple mappings to ensure that all mappings use the same settings. It is also possible to quickly copy a modifier or trigger from one mapping to another with drag & drop ([#31](https://github.com/godotneers/G.U.I.D.E/issues/31)).

### Fixed
- Cleaned up duplicate UIDs to prevent issues with Godot 4.4. ([#28](https://github.com/godotneers/G.U.I.D.E/issues/28)).



## [0.3.1] - 2025-02-14
### Breaking Changes
- G.U.I.D.E will now continue to process input when the tree is in pause mode. Also, the debugger and all icon rendering facilities will continue to work even when the tree is paused. Technically, this should have been the behaviour from the beginning because games need to remain controllable even when paused. Since the behaviour was changed, I'm declaring this a breaking change. Please check if your game still works as expected in pause mode. If you need to disable input when the game is paused, consider calling `GUIDE.disable_mapping_context()` or add specific checks to your game code to prevent actions while the game is paused ([#20](https://github.com/godotneers/G.U.I.D.E/issues/20)).


## [0.3.0] - 2025-02-10
### Breaking Changes
- `GUIDEModifierVirtualCursor` now tracks input as pixels rather than a virtual resolution independent value. This avoids the problem that the cursor movement speed is different for the x and y axes. The new implementation keeps a consistent speed on both axes. To achieve resolution independence, the modifier now has a separate setting which controls the screen scaling. Please check the [documentation](https://godotneers.github.io/G.U.I.D.E/reference/modifiers#virtual-cursor-experimental) for more information. Settings of existing projects will be migrated to the closest equivalent settings. Since the behaviour was changed, I declare this a breaking change. Please check your settings after updating and verify that the cursor behaves as expected ([#15](https://github.com/godotneers/G.U.I.D.E/issues/15)).

### Fixed
- Calling `cleanup` on `GUIDEInputFormatter` will no longer make the instance unusable. Usually it should not be necessary to call `cleanup` manually, but if you do, the formatter will make sure to recreate the necessary nodes when needed.

### Improved
- Further work on the test suite has been done. This is nowhere near complete, but it is a start. 

## [0.2.0] - 2025-01-30 
### Added
- It is now possible to override the action name and category for each input mapping, making it easier to remap actions that are mapped to multiple inputs (e.g. WASD for movement) ([#12](https://github.com/godotneers/G.U.I.D.E/issues/12)).
- `GUIDEInputFormatter` has a new method `cleanup` which allows tearing down the icon rendering infrastructure. This is mainly useful for automated tests, to avoid spurious records of orphan nodes ([#13](https://github.com/godotneers/G.U.I.D.E/issues/13)).

### Improved
- Icons are now set to scale with the editor scale, so they no longer should be too small on high resolution displays.
- The debugger will no longer update the UI when it is not visible. 

### Fixed
- The icon rendering infrastructure is now properly cleaned up when disabling the plugin.

## [0.1.3] - 2025-01-19
### Improved
- The debugger now shows the action priorities which are derived from analyzing overlapping input. This can help find problems in the action mapping and also gives a bit more information about what G.U.I.D.E does internally.

### Fixed
- Chains of chorded actions are now properly handled when calculating action priority from overlapping input ([#9](https://github.com/godotneers/G.U.I.D.E/issues/9))
- The plugin will now only register/unregister the `GUIDE` singleton when being enabled and disabled. This will avoid marking the project as modified just by loading it ([#11](https://github.com/godotneers/G.U.I.D.E/issues/11)).
- A few small bugs in the examples have been fixed.

## [0.1.2] - 2025-01-11
### Breaking Changes
- `GUIDEInputKey` now properly handles modifier keys (like shift, control, etc.). Until now, the handling of additional modifier keys had a bug that allowed you to press the key with a modifier even though _Allow additional modifiers_ was turned off. This has been fixed. However the more common use case is to ignore additional modifiers, so _Allow additional modifiers_ is now `true` by default. G.U.I.D.E cannot reliably migrate this new default for existing bindings, so if you want your existing key bindings to allow additional modifiers, you need to manually enable it for these. All new bindings will allow additional modifiers by default and you can disable this if you don't want it. 

### Improved
- The documentation of `GUIDEInputKey` has been updated to reflect the changes and add missing information about the modifier keys.

### Fixed
- `GUIDEInputKey` would not properly detect a key release if it was done in a certain sequence with modifier keys ([#7](https://github.com/godotneers/G.U.I.D.E/issues/7)). 

## [0.1.1] - 2025-01-10
### Added
- The _Any_ input now supports additional input types (mouse movement, joy axes and touch).

## [0.1.0] - 2025-01-09 
### Breaking Changes
- The `input_detected` signal of `GUIDEInputDetector` had a typo in it (was `input_dectected`) and was renamed to fix this. If your code uses this signal you will need to update it. Also check your scenes if you connected this signal using the editor.

### Added
- Support for touch input:
	- _Touch Position_  - will track the position of one or more fingers, similar to _Mouse Position_
	- _Touch Axis2D_ - will track the position change of one or more fingers, similar to _Mouse Axis2D_
	- _Touch Axis1D_ - similar to _Touch Axis2D_ but tracks a single axis, only.
	- _Touch Distance_ - tracks distance changes between two fingers. Useful for implementing pinch/zoom gestures.
	- _Touch Angle_ - tracks rotation changes between two fingers. Useful for implementing rotation gestures.
- New trigger type _Stability_ which triggers depending on whether the input has changed after initial actuatation. Useful for touch input to detect taps and drags.
- A new `touch` example has been added, showing how to use the new touch features to implement camera drags, pinch/zoom and rotation.
- New modifier _Normalize_ to normalize an input vector.

### Improved
- `GUIDEInputDetector` can now filter for device types, so you can limit detected input to keyboard, mouse or joystick/gamepad input.
- `GUIDEInputDetector` now has a `is_detecting` property to find out whether it is currently detecting input.
- `GUIDEInputDetector` now has a setting determining which joy index should be assigned to detected joy events.
- `GUIDERemapper` can now also filter for single actions, so it is easier to remap input for a specific action.
- The _Canvas Coordinates_ modifier can now also convert relative pixel coordinates into relative world coordinates.
- The `remapping` example's usability for controllers has been improved, showing some techniques on how to make UI more controller friendly.

### Fixed
- Triggers will no longer consider infinite input values as "actuating". Vector.INF is reserved for cases where no value is available.
- Modifiers now handle infinite input values more gracefully instead of producing `NaN` values.
- The text provider will no longer try to translate physical keys to labels on mobile platforms where Godot doesn't support this.
- Inputs of type `GUIDEInputAction` are now properly displayed in the debugger.

## [0.0.4] - 2024-12-28
### Fixed
- Fixed broken equality comparison on `GUIDEInputAny` ([#3](https://github.com/godotneers/G.U.I.D.E/issues/3)).

## [0.0.3] - 2024-12-21
### Added
- New trigger type _Released_ which triggers when the input is released (the opposite of _Pressed_).
- New modifier _Virtual Cursor_ which provides a virtual mouse cursor that can be controlled by any input (experimental).

### Changed
- In the debugger, inputs now show the raw Vector3 coming from the input. This helps understanding modifiers better as we can see the value that is going into the modifier.

### Fixed
- Added missing equality comparison for `GUIDEInputAny` and `GUIDEInputMousePosition` so these inputs are not needlessly duplicated and updated multiple times per frame.
- Triggers do no longer reset the action value to zero when they don't fire. They are intended to be orthogonal to the action values, so they should react to changes of the value, rather than modify it (for that we have modifiers).
- Fixed several smaller rendering problems with rendering items (e.g. broken direction indicator for Xbox controllers and joysticks, right trigger being shown as left trigger, etc.). To clear cached icons, go to _Project_ > _Open user data folder_  and in this folder delete the `_guide_cache` folder. This will recreate icons. 
- Fixed size of the icons which should be 16x16 not 32x32 ([#2](https://github.com/godotneers/G.U.I.D.E/issues/2)).

## [0.0.2] - 2024-12-02
### Breaking Changes
- Removed the leftover`get_value_axis_xxx` methods from the `GUIDEAction` class. Use the `value_axis_xxx` property instead.
- `GUIDEDebugger` is no longer a public node class because it cannot work as a standalone node. Use the provided `guide_debugger.tscn` scene to add a debugger to your project.
### Added
- `GUIDEAction` now has additional functions to check whether it is currently in `Completed` or `Ongoing` state.
- Added two new modifiers: _Curve_ which allows to apply a curve to the input value and _Map range_ which allows to map the input value to a different range. A huge thanks goes to [Regal Media](https://github.com/RegalMedia) for submitting a PR with this feature!
### Improved
- The `input_mappings_changed` signal in `GUIDE` now also fires when any joystick is connected or disconnected.


## [0.0.1] - 2024-11-17
- Initial release of the plugin.
