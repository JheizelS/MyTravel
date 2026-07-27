extends Label

@export var speed_threshold: float = 0.5  # Minimum speed to display (km/h)

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player is VehicleBody3D:
		var speed_ms = player.linear_velocity.length()
		var speed_kmh = speed_ms * 3.6
		
		# Only show speed if above threshold, otherwise show 0
		if speed_kmh > speed_threshold:
			text = str(round(speed_kmh)) + " km/h"
		else:
			text = "0 km/h"
