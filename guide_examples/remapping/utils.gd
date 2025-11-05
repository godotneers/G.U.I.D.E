const REMAPPING_CONFIG_PATH:String = "user://remapping_config.tres"

# Constants for custom data that we store in the remapping config.
const CUSTOM_DATA_INVERT_HORIZONTAL:String = "invert_horizontal"
const CUSTOM_DATA_INVERT_VERTICAL:String = "invert_vertical"

## Loads the saved remapping config if it exists, or an empty remapping
## config if none exists.
static func load_remapping_config() -> GUIDERemappingConfig:
	if ResourceLoader.exists(REMAPPING_CONFIG_PATH):
		return ResourceLoader.load(REMAPPING_CONFIG_PATH)
	else:
		return GUIDERemappingConfig.new()

## Saves the given remapping config to the user folder
static func save_remapping_config(config:GUIDERemappingConfig) -> void:
	ResourceSaver.save(config, REMAPPING_CONFIG_PATH)
	config.take_over_path(REMAPPING_CONFIG_PATH)
