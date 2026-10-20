extends Control


func _on_start_journey_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")



func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
