extends VehicleBody3D
# Max steering angle in radians
const MAX_STEER = 0.5
# Force applied to wheels when accelerating
const ENGINE_POWER = 125
# Camera pan settings
const MOUSE_SENSITIVITY = 0.0025
const MAX_PAN_ANGLE = 50.0
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera_3d = $CameraPivot/SpringArm3D/Camera3D
@onready var reverse_camera = $CameraPivot/ReverseCamera
var reverse_mode := false
var camera_yaw := 0.0  # horizontal pan offset from car's heading
# 0-100 timer
var timing := false
var timer := 0.0
var start_speed_threshold = 2.0  # km/h, starts when car actually moves
var test_done := false  # prevents repeated prints in one run

# Changes
var speed_kmh = linear_velocity.length() * 3.6
var return_rate = lerp(1.0, 3.5, clamp(speed_kmh / 100.0, 0.0, 1.0))

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Start with main camera active
	camera_3d.current = true
	reverse_camera.current = false


#Changes
func _get_speed_scaled_steer() -> float:
	var speed_kmh = linear_velocity.length() * 3.6
	# Full steer angle up to 30 km/h, tapers to 20% at 120 km/h
	var steer_factor = clamp(1.0 - (speed_kmh / 120.0) * 0.8, 0.2, 1.0)
	return MAX_STEER * steer_factor
	
	#Speed-scaled damping (CHANGES)
	linear_damp = lerp(0.0, 1.5, clamp(speed_kmh / 120.0, 0.0, 1.0))














func _input(event):
	# Laptop
	if event is InputEventMouseMotion and not reverse_mode: # Only pan when using main camera
		camera_yaw -= event.relative.x * MOUSE_SENSITIVITY
		# Clamp so player can't spin camera fully around
		camera_yaw = clamp(camera_yaw, deg_to_rad(-MAX_PAN_ANGLE), deg_to_rad(MAX_PAN_ANGLE))
	# Mobile
	if event is InputEventScreenDrag and not reverse_mode:
		camera_yaw -= event.relative.x * MOUSE_SENSITIVITY
		# Clamp
		camera_yaw = clamp(camera_yaw, deg_to_rad(-MAX_PAN_ANGLE), deg_to_rad(MAX_PAN_ANGLE))
	
func _physics_process(delta):
	_check_camera_switch()
	# Steering — smoothly moves toward input direction
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * _get_speed_scaled_steer(), #CHANGES
		delta * return_rate #CHANGES
	)
	# Acceleration/braking
	engine_force = Input.get_axis("steer_back", "steer_forward") * ENGINE_POWER
	
	var heading_diff = angle_difference(global_rotation.y, camera_pivot.global_rotation.y)
	camera_yaw = clamp(heading_diff, deg_to_rad(-MAX_PAN_ANGLE), deg_to_rad(MAX_PAN_ANGLE))
	
	# Snap pivot position to car each frame
	camera_pivot.global_position = global_position
	# Smoothly rotate pivot to match car heading + any pan offset
	camera_pivot.global_rotation.y = lerp_angle(
		camera_pivot.global_rotation.y,
		global_rotation.y + camera_yaw,
		delta * 5.0
	)
	# Drifting — lower friction on rear wheels
	if Input.is_action_pressed("drift"):
		$back_right.wheel_friction_slip = 0.5
		$back_left.wheel_friction_slip = 0.5
	else:
		$back_right.wheel_friction_slip = 1.5
		$back_left.wheel_friction_slip = 1.5
	
	# 0-100 km/h acceleration timer
	var speed_kmh = linear_velocity.length() * 3.6
	if not timing and not test_done and speed_kmh > start_speed_threshold:
		timing = true
		timer = 0.0
	if timing and speed_kmh < 100.0:
		timer += delta
	if timing and speed_kmh >= 100.0:
		print("0-100 km/h in %.2f seconds" % timer)
		timing = false
		test_done = true  # stops it firing again until scene is restarted

func _check_camera_switch():
	if Input.is_action_just_pressed("reverse_camera"):
		reverse_mode = !reverse_mode
		# Reset pan so reverse camera always starts centred
		if reverse_mode:
			camera_yaw = 0.0
	# Switch active camera based on mode
	if reverse_mode:
		reverse_camera.current = true
		camera_3d.current = false
	else:
		camera_3d.current = true
		reverse_camera.current = false
