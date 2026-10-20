extends Node

signal assist_changed(enabled: bool)

const SAVE_PATH := "user://settings.cfg"

var assist_enabled: bool = false:
	set(value):
		if assist_enabled == value:
			return
		assist_enabled = value
		_save()
		assist_changed.emit(value)

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		assist_enabled = cfg.get_value("gameplay", "assist_enabled", false)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH) # keeps your existing settings, e.g. language
	cfg.set_value("gameplay", "assist_enabled", assist_enabled)
	cfg.save(SAVE_PATH)
