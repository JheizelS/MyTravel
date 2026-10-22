extends Control

@export_file("*.tscn") var main_menu_scene: String
@export var scroll_speed: float = 45.0

@onready var return_button: Button = $BackButton
@onready var scroll: ScrollContainer = $ScrollContainer

var _scroll_pos: float = 0.0


func _ready() -> void:
	_translate_credits()
	return_button.pressed.connect(_on_return_pressed)
	return_button.grab_focus()


func _process(delta: float) -> void:
	var max_scroll: float = scroll.get_v_scroll_bar().max_value - scroll.size.y
	if _scroll_pos < max_scroll:
		_scroll_pos += scroll_speed * delta
		scroll.scroll_vertical = int(_scroll_pos)

func _translate_credits() -> void:
	var rich: RichTextLabel = $ScrollContainer/RichTextLabel
	var t: String = rich.text
	t = t.replace("@credits_created_by@", tr("credits_created_by"))
	t = t.replace("@credits_assets@", tr("credits_assets"))
	t = t.replace("@credits_made_with@", tr("credits_made_with"))
	t = t.replace("@credits_thanks@", tr("credits_thanks"))
	t = t.replace("@credits_feedback@", tr("credits_feedback"))
	rich.text = t

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
