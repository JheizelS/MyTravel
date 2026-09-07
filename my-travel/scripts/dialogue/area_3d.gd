extends Area3D
@export var speaker_name: String = "Welcome to MyTravel!"
@export var dialogue_text: String = "In New Zealand, you drive on the left side of the road. Keep left and reach a score of 25 to complete this lesson."
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
	_waiting_for_continue = true
	DialogueBox.show_dialogue(speaker_name, dialogue_text + "\n\n(Click to continue)", "intro")


func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_continue:
		return
	if event is InputEventMouseButton and event.pressed or event.is_action_pressed("ui_accept"):
		_waiting_for_continue = false
		DialogueBox.hide_dialogue("intro")
		if lesson_intro:
			lesson_intro.start_sequence()
