extends CanvasLayer

signal dismissed

@export var lock_time := 3.0
@export var title_dark := Color(0.6, 0.0, 0.0)
@export var title_bright := Color(1.0, 0.15, 0.15)
@export var title_pulse_time := 0.3

@onready var title: Label = $VBoxContainer/Title
@onready var prompt: HBoxContainer = $VBoxContainer/HBoxContainer

var _can_dismiss := false
var _pulse: Tween
var _title_pulse: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func show_popup() -> void:
	# DEBUG:print("show_popup on: ", name, " | title: ", title, " | prompt: ", prompt)
	_can_dismiss = false
	_can_dismiss = false
	prompt.modulate.a = 0.0
	show()

	# Danger pulse starts immediately
	_title_pulse = create_tween().set_loops()
	_title_pulse.tween_property(title, "modulate", title_bright, title_pulse_time)
	_title_pulse.tween_property(title, "modulate", title_dark, title_pulse_time)

	await get_tree().create_timer(lock_time).timeout
	_can_dismiss = true
	_pulse = create_tween().set_loops()
	_pulse.tween_property(prompt, "modulate:a", 0.4, 0.5)
	_pulse.tween_property(prompt, "modulate:a", 1.0, 0.5)


func hide_popup() -> void:
	_stop_pulses()
	hide()


func _stop_pulses() -> void:
	if _pulse:
		_pulse.kill()
	if _title_pulse:
		_title_pulse.kill()


func _input(event: InputEvent) -> void:
	if visible and _can_dismiss and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_stop_pulses()
		hide()
		dismissed.emit()
