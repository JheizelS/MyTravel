extends CanvasLayer

@onready var panel: Panel = $Panel
 
var is_paused: bool = false
 
 
func _ready() -> void:
	panel.visible = false
 
 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
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
