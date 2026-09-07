extends Area3D

@export var respawn_point: Marker3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.global_transform = respawn_point.global_transform
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		ScoreManager.reset_score()
