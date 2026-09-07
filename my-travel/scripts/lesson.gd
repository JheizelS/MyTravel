extends Node3D
@export var player: VehicleBody3D
enum Step { IGNITION, HEADLIGHTS, GOAL, DONE }
var current_step: Step = Step.IGNITION
var sequence_started: bool = false

func _ready() -> void:
	pass # sequence starts via start_sequence() in this script, called externally

func start_sequence() -> void:
	sequence_started = true
	current_step = Step.IGNITION
	_show_step(current_step)

func _process(_delta: float) -> void:
	if not sequence_started:
		return
	match current_step:
		Step.IGNITION:
			if player.engine_running:
				_advance()
		Step.HEADLIGHTS:
			if player.headlights_on:
				_advance()
		Step.GOAL:
			if player.linear_velocity.length() * 3.6 > 5.0:
				_advance()

func _advance() -> void:
	DialogueBox.hide_dialogue("lesson_intro")
	current_step += 1
	if current_step != Step.DONE:
		_show_step(current_step)

func _show_step(step: Step) -> void:
	match step:
		Step.IGNITION:
			DialogueBox.show_dialogue("Instructor", "Press Tab to start the engine.", "lesson_intro")
		Step.HEADLIGHTS:
			DialogueBox.show_dialogue("Instructor", "Good. Now press T to turn on your headlights — you'll need them tonight.", "lesson_intro")
		Step.GOAL:
			DialogueBox.show_dialogue("Instructor", "Complete one full loop of the track to pass this lesson.", "lesson_intro")
