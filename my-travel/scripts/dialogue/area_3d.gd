extends Area3D

@export var trigger_once: bool = true
@export var lesson_intro: Node  # drag your LessonIntro node in here

var _has_triggered: bool = false
var _waiting_for_continue: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	if trigger_once and _has_triggered:
		return

	_has_triggered = true

	var tutorial: Node = get_tree().get_first_node_in_group("controls_tutorial")
	if tutorial:
		await tutorial.finished

	_waiting_for_continue = true
	var body_text: String = tr("lesson_welcome_body") % int(ScoreManager.target_score)
	DialogueBox.show_dialogue(
		tr("lesson_welcome_title"),
		body_text + "\n\n" + tr("lesson_click_continue"),
		"intro"
	)

func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_continue:
		return
	if event is InputEventMouseButton and event.pressed or event.is_action_pressed("ui_accept"):
		_waiting_for_continue = false
		DialogueBox.hide_dialogue("intro")
		if lesson_intro:
			lesson_intro.start_sequence()
