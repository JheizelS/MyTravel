extends StaticBody3D

var _lesson_complete: bool = false

func _on_finish_zone_entered(area: Area3D) -> void:
	if area.is_in_group("finish_line") and not _lesson_complete:
		_lesson_complete = true
		ScoreManager.freeze_scoring()
		DialogueBox.show_dialogue("Instructor", "Lesson complete! Final score: %d" % ScoreManager.score, "lesson_complete")
