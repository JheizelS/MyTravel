extends Control


@onready var high_quality_button: Button = $Panel/MarginContainer2/HBoxContainer/HighQualityButton
@onready var low_quality_button: Button = $Panel/MarginContainer2/HBoxContainer/LowQualityButton
@onready var back_button: Button = $Panel/BackButton


func _ready() -> void:
	high_quality_button.pressed.connect(_on_high_pressed)
	low_quality_button.pressed.connect(_on_low_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_update_button_states()

func _on_high_pressed() -> void:
	GraphicsSettings.set_quality(GraphicsSettings.Quality.HIGH)
	_update_button_states()

func _on_low_pressed() -> void:
	GraphicsSettings.set_quality(GraphicsSettings.Quality.LOW)
	_update_button_states()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _update_button_states() -> void:
	high_quality_button.disabled = (GraphicsSettings.current_quality == GraphicsSettings.Quality.HIGH)
	low_quality_button.disabled = (GraphicsSettings.current_quality == GraphicsSettings.Quality.LOW)

	var selected_color = Color(0.3, 0.85, 0.4)  # green — feel free to pick your own
	var normal_color = Color(1, 1, 1)

	high_quality_button.modulate = selected_color if GraphicsSettings.current_quality == GraphicsSettings.Quality.HIGH else normal_color
	low_quality_button.modulate = selected_color if GraphicsSettings.current_quality == GraphicsSettings.Quality.LOW else normal_color
