extends Node
signal score_changed(new_score: int)
const POINTS_PER_TICK := 1
const PENALTY_PER_TICK := 1
const TICK_INTERVAL := 1.0
const MIN_MOVING_SPEED_KMH := 5.0

@export var target_score := 25

var score: int = 0
var is_off_road: bool = false
var is_wrong_lane: bool = false
var is_speeding: bool = false
var current_speed_kmh: float = 0.0
var _scoring_frozen: bool = false
var _tick_timer: float = 0.0

func _process(delta: float) -> void:
	if _scoring_frozen or PauseMenu.is_paused:
		return
	_tick_timer += delta
	if _tick_timer >= TICK_INTERVAL:
		_tick_timer = 0.0
		var is_moving = current_speed_kmh >= MIN_MOVING_SPEED_KMH
		var is_breaking_rule = is_off_road or is_wrong_lane or is_speeding
		if is_breaking_rule and is_moving:
			score = max(score - PENALTY_PER_TICK, 0)
			score_changed.emit(score)
		elif is_moving and not is_breaking_rule and score < target_score:
			score = min(score + POINTS_PER_TICK, target_score)
			score_changed.emit(score)

func set_off_road(value: bool) -> void:
	is_off_road = value

func set_wrong_lane(value: bool) -> void:
	is_wrong_lane = value

func set_speeding(value: bool) -> void:
	is_speeding = value

func set_speed(speed_kmh: float) -> void:
	current_speed_kmh = speed_kmh

func freeze_scoring() -> void:
	_scoring_frozen = true

func reset_score() -> void:
	score = 0
	_scoring_frozen = false
	_tick_timer = 0.0
	score_changed.emit(score)
