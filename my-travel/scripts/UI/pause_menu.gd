extends CanvasLayer

@onready var panel: Panel = $Panel

var is_paused: bool = false


func _ready() -> void:
	panel.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.is_in_group("no_pause"):
			return
		_toggle_pause()


func _toggle_pause() -> void:
	is_paused = !is_paused
	panel.visible = is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_pause_button_pressed() -> void:
	_toggle_pause()


func _on_settings_button_pressed() -> void:
	panel.visible = false
	is_paused = false
	DialogueBox.hide_dialogue()
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_main_menu_pressed() -> void:
	panel.visible = false
	is_paused = false
	DialogueBox.hide_dialogue()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
