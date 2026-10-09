extends Area3D

@export var respawn_point: Marker3D


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		respawn(body)


func respawn(body: Node3D) -> void:
	if respawn_point == null:
		push_error("Barrier has no respawn_point assigned")
		return
	body.teleport_to(respawn_point.global_transform)
	ScoreManager.reset_score()
