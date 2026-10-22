extends Control

const SETTINGS_PATH = "user://settings.cfg"
const DISCLAIMER_SCREEN = "res://scenes/localisation/disclaimer_screen.tscn"


func _on_english_button_pressed() -> void:
	_select_locale("en")


func _on_maori_button_pressed() -> void:
	_select_locale("mi")


func _on_chinese_button_pressed() -> void:
	_select_locale("zh")


func _on_hindi_button_pressed() -> void:
	_select_locale("hi")


func _on_korean_button_pressed() -> void:
	_select_locale("ko")


func _on_filipino_button_pressed() -> void:
	_select_locale("fil")


func _select_locale(locale_code: String) -> void:
	TranslationServer.set_locale(locale_code)
	_save_locale(locale_code)
	get_tree().change_scene_to_file(DISCLAIMER_SCREEN)
 
 
func _save_locale(locale: String) -> void:
	var config = ConfigFile.new()
	config.load(SETTINGS_PATH)  # load first so we don't wipe other saved settings
	config.set_value("settings", "locale", locale)
	config.save(SETTINGS_PATH)
 
