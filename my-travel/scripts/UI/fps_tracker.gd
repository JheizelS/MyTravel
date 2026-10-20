extends Node

@export var shown_scenes: Array[String] = ["Level1"]

@onready var label: Label = $Label

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	label.visible = scene != null and scene.name in shown_scenes
	if label.visible:
		label.text = "FPS: %d" % Engine.get_frames_per_second()
