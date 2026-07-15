# To Do

This lists the currently open to do items in no particular order.

## Open
- [ ] The stick renderer throws errors about a signal being connected twice. Fix that.
- [ ] Add a C# API.
- [ ] Make C# API use strong typing where possible rather than using variant.
 
## Done
- [x] Virtual stick device change mid-game support.
- [x] Prepare for asset library (git attributes, page, etc.)
- [x] Icon for "Mouse Position" input.
- [x] document all possible inputs and how they map to action values
- [x] Add icon/text renderers for PS/XBOX/Nintendo controllers
- [x] Make the fallback icons less ugly.
- [x] Add functionality for runtime re-binding.
- [x] Fix icon/text for Any input
- [x] Fix remapping of WASD to ESDF
- [x] Implement input consumption and action prioritization.
- [x] Fix "incomplete format" error popping up when rendering an input icon.
- [x] Implement elapsed/triggered time.
- [x] Make an editor for setting up the system. The inspector is atrocious.
- [x] Decide whether to convert into C++ after the prototyping phase is done (decided against it, GDScript is fast enough, easier to maintain and works on all platforms out of the box).
- [x] Remove get_action_value_xxx from Action (replaced by value_xxx property)
- [x] Documentation
    - [x] document customizing the input prompt rendering
    - [x] document input remapping
