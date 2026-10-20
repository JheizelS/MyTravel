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
			# Stay on the goal message until the player is actually fast enough to score
			if _speed_kmh() >= ScoreManager.MIN_SCORING_SPEED_KMH:
				_advance()


func _speed_kmh() -> float:
	return player.linear_velocity.length() * 3.6


func _advance() -> void:
	DialogueBox.hide_dialogue("lesson_intro")
	current_step += 1
	if current_step != Step.DONE:
		_show_step(current_step)
	else:
		player.slow_check_enabled = true

func _show_step(step: Step) -> void:
	match step:
		Step.IGNITION:
			DialogueBox.show_dialogue(tr("lesson_speaker"), tr("lesson_start_engine"), "lesson_intro")
		Step.HEADLIGHTS:
			DialogueBox.show_dialogue(tr("lesson_speaker"), tr("lesson_headlights"), "lesson_intro")
		Step.GOAL:
			DialogueBox.show_dialogue(
				tr("lesson_speaker"),
				tr("lesson_loop") % [
					int(ScoreManager.MIN_SCORING_SPEED_KMH),
					int(player.speeding_threshold_kmh)
				],
				"lesson_intro"
			)
