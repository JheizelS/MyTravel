extends Control


@onready var continue_button: Button = $Button
@onready var continue_timer: Timer = $ContinueTimer
@onready var title_label: Label = $ColorRect/MarginContainer/VBoxContainer/Title
@onready var body_label: Label = $ColorRect/MarginContainer/VBoxContainer/Warning
@onready var hint_label: Label = $ColorRect/MarginContainer/VBoxContainer/ContinueInstructions
@onready var agree_label: Label = $ColorRect/MarginContainer2/VBoxContainer2/Label

func _ready():
	title_label.text = tr("disclaimer_title")
	body_label.text = tr("disclaimer_body")
	hint_label.text = tr("disclaimer_hint")
	agree_label.text = tr("disclaimer_agree")
	
	continue_button.disabled = true
	continue_timer.wait_time = 5.0
	continue_timer.one_shot = true
	continue_timer.start()
	continue_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	continue_button.disabled = false

func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
