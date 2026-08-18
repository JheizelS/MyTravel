extends CanvasLayer


@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: Label = $Panel/MarginContainer/VBoxContainer/DialogueLabel
 
# Optional: how long a tip stays on screen before auto-hiding.
# Set to 0 if you'd rather it stay until manually dismissed.
@export var display_duration: float = 4.0
 
var _hide_timer: Timer
 
 
func _ready() -> void:
	panel.visible = false
	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	add_child(_hide_timer)
	_hide_timer.timeout.connect(_on_hide_timer_timeout)
 
 
func show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	dialogue_label.text = text
	panel.visible = true
 
	if display_duration > 0.0:
		_hide_timer.start(display_duration)
 
 
func hide_dialogue() -> void:
	panel.visible = false
 
 
func _on_hide_timer_timeout() -> void:
	hide_dialogue()
 
