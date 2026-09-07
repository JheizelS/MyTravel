extends Node

signal score_changed(new_score: int)

const POINTS_PER_TICK := 1
const TICK_INTERVAL := 1.0  # award points once per second of clean driving

var score: int = 0
var is_off_road: bool = false
var is_wrong_lane: bool = false

var _tick_timer: float = 0.0

func _process(delta: float) -> void:
	_tick_timer += delta
	if _tick_timer >= TICK_INTERVAL:
		_tick_timer = 0.0
		if not is_off_road and not is_wrong_lane:
			score += POINTS_PER_TICK
			score_changed.emit(score)

func set_off_road(value: bool) -> void:
	is_off_road = value

func set_wrong_lane(value: bool) -> void:
	is_wrong_lane = value
