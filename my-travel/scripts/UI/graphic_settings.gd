extends Node

enum Quality { LOW, HIGH }

var current_quality: Quality = Quality.HIGH

const HIGH_CLOUDS_SAMPLES := 32
const HIGH_SHADOW_SAMPLES := 4
const LOW_CLOUDS_SAMPLES := 8
const LOW_SHADOW_SAMPLES := 2

const SAVE_PATH := "user://graphics_settings.cfg"

func _ready() -> void:
	_load_settings()

func set_quality(quality: Quality) -> void:
	current_quality = quality
	apply_quality()
	_save_settings()

func apply_quality() -> void:
	var world_env = get_tree().get_first_node_in_group("world_environment")
	if not world_env:
		return  # no WorldEnvironment in the current scene (e.g. main menu) — nothing to apply
	
	#print("DEBUG: Found WorldEnvironment, applying quality: ", current_quality)

	var sky_material = world_env.environment.sky.sky_material
	if current_quality == Quality.HIGH:
		sky_material.set_shader_parameter("clouds_samples", HIGH_CLOUDS_SAMPLES)
		sky_material.set_shader_parameter("shadow_sample", HIGH_SHADOW_SAMPLES)
	else:
		sky_material.set_shader_parameter("clouds_samples", LOW_CLOUDS_SAMPLES)
		sky_material.set_shader_parameter("shadow_sample", LOW_SHADOW_SAMPLES)
		
	

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("graphics", "quality", current_quality)
	config.save(SAVE_PATH)

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		current_quality = config.get_value("graphics", "quality", Quality.HIGH)
