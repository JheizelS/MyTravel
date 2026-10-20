extends CanvasLayer

@export var pulse_time := 0.3
@export var dark := Color(0.6, 0.35, 0.0)
@export var bright := Color(1.0, 0.7, 0.1)

@onready var title: Label = $VBoxContainer/StuckLabelTitle

var _pulse: Tween


func _ready() -> void:
	hide()


func show_indicator() -> void:
	if visible:
		return
	show()
	_pulse = create_tween().set_loops()
	_pulse.tween_property(title, "modulate", bright, pulse_time)
	_pulse.tween_property(title, "modulate", dark, pulse_time)


func hide_indicator() -> void:
	if _pulse:
		_pulse.kill()
	hide()
