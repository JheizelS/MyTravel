extends Area3D
 
@export var speaker_name: String = "Welcome to MyTravel!"
@export var dialogue_text: String = "To firstly introduce you to the NZ roads, we drive on the left." + " Keep to the left side of the road."
@export var trigger_once: bool = true
 
var _has_triggered: bool = false
 
 
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
 
 
func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	if trigger_once and _has_triggered:
		return
 
	_has_triggered = true
	DialogueBox.show_dialogue(speaker_name, dialogue_text, "intro")
 
 
func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
 
	DialogueBox.hide_dialogue("intro")
