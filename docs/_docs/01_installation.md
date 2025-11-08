---
layout: page
title: Installation and Updates
permalink: /installation
description: "Here you can find the installation instructions for the plugin."
---

## Requirements

This plugin requires Godot 4.2.0 or later. Earlier versions of Godot 4 will not work because the plugin uses features that were introduced only in Godot 4.2.0. Godot 3 is not supported.

## Installation process
### Installation with the Godot Asset Library

The easiest way to install the plugin is to use the Godot Asset Library. Search for "G.U.I.D.E" and install the plugin. You can exclude the `guide_examples` folder if you don't need the examples.

### Manual installation

You can also download a ZIP file of this repository and extract it, then copy the `addons/guide` folder into your project's `addons` folder.

### Important steps after installation
After you installed it, make sure you enable the plugin in the project settings:

![Enabling the plugin in the project settings]({{ site.baseurl }}/assets/img/manual/installation_enable_plugin.png)

Also, please **restart the Godot editor** after enabling the plugin. This is required, because Godot usually doesn't fully pick up new plugins while it's running. If you don't restart the editor the plugin might not work correctly or not at all.

The following video shows the installation process in detail and launches one of the examples to verify that the plugin is working correctly.

{% include video.html path="assets/img/manual/manual_installation.mp4" %}


## Updating from an earlier version

The asset library currently has no support for plugin updates, therefore in order to update the plugin, perform the following steps:

- **Be sure you have a backup of your project or have it under version control, so you can go back in case things don't work out as intended.**
- Check the [CHANGES.md]({{site.repo}}/blob/main/CHANGES.md) for any breaking changes that might impact your project and any special update instructions.
- Download the version you want to install from the [Release List]({{site.repo}}/releases) (use the _Source Code ZIP_ link).
- Close Godot. It's important to not have the project opened while running the update.
- In your project locate the `guide` folder within the `addons` folder and delete the `guide` folder with all of its contents.
- Unpack your downloaded ZIP file somewhere. Inside of the unpacked ZIP file structure, locate the `guide` folder within the `addons` folder.
- Move the `guide` folder you located in the previous step into the `addons` folder of your project.
- The plugin is now updated. You can now open the project again in Godot and continue working on it.
