class_name ControlsTutorial
extends CanvasLayer

signal finished

static var active: bool = false

var _done: bool = false
var _step: int = 0
var _steps: Array[Control] = []


func _ready() -> void:
	add_to_group("controls_tutorial")
	active = true
	_steps = [
		$ColorRect/CenterContainer/Step1,
		$ColorRect/CenterContainer/Step2,
	]
	_show_step(0)


func _show_step(index: int) -> void:
	for i in _steps.size():
		_steps[i].visible = (i == index)


func _input(event: InputEvent) -> void:
	if _done:
		return
	var clicked: bool = event is InputEventMouseButton and event.pressed
	if clicked or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_step += 1
		if _step < _steps.size():
			_show_step(_step)
		else:
			_done = true
			active = false
			finished.emit()
			queue_free()
