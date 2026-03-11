extends VehicleBody3D

func _ready():
	print("=== CAR STARTUP ===")
	print("Mass: ", mass)
	
	# Check wheels
	var wheel_count = 0
	var traction_wheels = 0
	for child in get_children():
		if child is VehicleWheel3D:
			wheel_count += 1
			print("Wheel: ", child.name)
			print("  - Traction: ", child.use_as_traction)
			print("  - Steering: ", child.use_as_steering)
			print("  - Radius: ", child.wheel_radius)
			if child.use_as_traction:
				traction_wheels += 1
	
	print("Total wheels: ", wheel_count)
	print("Traction wheels: ", traction_wheels)
	if traction_wheels == 0:
		print("❌ ERROR: No traction wheels! Car won't move.")
	
	# Lift car slightly
	position.y = 0.5

func _process(delta):
	# Test with constant force
	engine_force = 300
	print("Velocity: ", linear_velocity.length())
