extends CanvasLayer

@onready var panel: Panel = $Panel

var is_paused: bool = false
const SETTINGS_SCENE := preload("res://scenes/menus/settings_menu.tscn")
var _settings_instance: Node = null

func _ready() -> void:
	layer = 100

	# Must keep running while the tree is paused, or the menu can never unpause it
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		if _settings_instance:
			return
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.is_in_group("no_pause"):
			return
		# A popup has already paused the game, so don't let this menu fight with it
		if not is_paused and get_tree().paused:
			return
		_toggle_pause()


func _toggle_pause() -> void:
	is_paused = !is_paused
	panel.visible = is_paused
	get_tree().paused = is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_pause_button_pressed() -> void:
	_toggle_pause()


func _on_settings_button_pressed() -> void:
	if _settings_instance:
		return
	panel.visible = false
	_settings_instance = SETTINGS_SCENE.instantiate()
	_settings_instance.set_meta("from_pause", true)
	add_child(_settings_instance)


func close_settings() -> void:
	if _settings_instance:
		_settings_instance.queue_free()
		_settings_instance = null
	panel.visible = true


func _on_main_menu_pressed() -> void:
	panel.visible = false
	is_paused = false
	get_tree().paused = false
	DialogueBox.hide_dialogue()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
