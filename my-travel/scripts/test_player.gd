extends VehicleBody3D

const MAX_STEER = 0.6
const ENGINE_POWER = 400

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Car ready! Use WASD to drive")

func _process(delta):
	# Get input
	var steer_input = Input.get_axis("steer_left", "steer_right")
	var throttle_input = Input.get_axis("steer_backward", "steer_forward")
	
	# Apply controls
	steering = move_toward(steering, steer_input * MAX_STEER, delta * 2.5)
	engine_force = throttle_input * ENGINE_POWER
	
	# Auto-brake when no input
	brake = 5.0 if throttle_input == 0 else 0.0
	
	# Press Space for debug info
	if Input.is_action_just_pressed("ui_accept"):
		debug_info()

func debug_info():
	print("\n=== CAR DEBUG ===")
	print("Velocity: ", linear_velocity.length())
	print("Engine Force: ", engine_force)
	print("Steering: ", steering)
	
	# Check each wheel
	for child in get_children():
		if child is VehicleWheel3D:
			print(child.name, " in contact: ", child.is_in_contact())
