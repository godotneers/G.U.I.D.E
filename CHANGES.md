﻿# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Breaking Change: Removed the leftover`get_value_axis_xxx` methods from the `GUIDEAction` class. Use the `value_axis_xxx` property instead.
- Breaking Change: `GUIDEDebugger` is no longer a public node class because it cannot work as a standalone node. 
- `GUIDEAction` now has additional functions to check whether it is currently in `Completed` or `Ongoing` state.

## [0.0.1] - 2024-11-17
- Initial release of the plugin.