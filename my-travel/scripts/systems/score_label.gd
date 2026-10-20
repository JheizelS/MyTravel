extends Label


@export var target_score := 25


func _ready():
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)


func _on_score_changed(new_score: int):
	text = tr("hud_score") % [new_score, ScoreManager.target_score]
