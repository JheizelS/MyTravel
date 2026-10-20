extends Control

@onready var high_quality_button: Button = $Panel/VBoxContainer/MarginContainer2/HBoxContainer/HighQualityButton
@onready var low_quality_button: Button = $Panel/VBoxContainer/MarginContainer2/HBoxContainer/LowQualityButton
@onready var back_button: Button = $BackButton
@export var assist_on: Button
@export var assist_off: Button

const SELECTED_COLOR := Color(0.3, 0.85, 0.4)
const NORMAL_COLOR := Color(1, 1, 1)

func _ready() -> void:
	high_quality_button.pressed.connect(_on_high_pressed)
	low_quality_button.pressed.connect(_on_low_pressed)
	back_button.pressed.connect(_on_back_pressed)
	assist_on.pressed.connect(_on_assist_on_pressed)
	assist_off.pressed.connect(_on_assist_off_pressed)

	_update_button_states()
	_update_assist_states()

	var group := ButtonGroup.new()
	for b in [assist_on, assist_off]:
		b.toggle_mode = true
		b.button_group = group

	assist_on.pressed.connect(func(): AssistSettings.assist_enabled = true)
	assist_off.pressed.connect(func(): AssistSettings.assist_enabled = false)

	# show the saved choice when the panel opens
	assist_on.button_pressed = AssistSettings.assist_enabled
	assist_off.button_pressed = not AssistSettings.assist_enabled

func _on_high_pressed() -> void:
	GraphicsSettings.set_quality(GraphicsSettings.Quality.HIGH)
	_update_button_states()


func _on_low_pressed() -> void:
	GraphicsSettings.set_quality(GraphicsSettings.Quality.LOW)
	_update_button_states()


func _on_assist_on_pressed() -> void:
	AssistSettings.assist_enabled = true
	_update_assist_states()


func _on_assist_off_pressed() -> void:
	AssistSettings.assist_enabled = false
	_update_assist_states()


func _on_back_pressed() -> void:
	if has_meta("from_pause"):
		PauseMenu.close_settings()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _update_button_states() -> void:
	var is_high := GraphicsSettings.current_quality == GraphicsSettings.Quality.HIGH
	high_quality_button.disabled = is_high
	low_quality_button.disabled = not is_high
	high_quality_button.modulate = SELECTED_COLOR if is_high else NORMAL_COLOR
	low_quality_button.modulate = NORMAL_COLOR if is_high else SELECTED_COLOR


func _update_assist_states() -> void:
	var is_on := AssistSettings.assist_enabled
	assist_on.disabled = is_on
	assist_off.disabled = not is_on
	assist_on.modulate = SELECTED_COLOR if is_on else NORMAL_COLOR
	assist_off.modulate = NORMAL_COLOR if is_on else SELECTED_COLOR
