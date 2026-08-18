extends VehicleBody3D
# Max steering angle in radians
const MAX_STEER = 0.5
# Force applied to wheels when accelerating
const ENGINE_POWER = 125
# Speed cap — engine force tapers to 0 as car approaches this speed
const MAX_SPEED_KMH = 120.0
# Camera pan settings
const MOUSE_SENSITIVITY = 0.0025
const MAX_PAN_ANGLE = 50.0

@onready var wheels: Array[VehicleWheel3D] = [$front_left, $front_right, $back_left, $back_right]
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera_3d = $CameraPivot/SpringArm3D/Camera3D
@onready var reverse_camera = $CameraPivot/ReverseCamera
@onready var headlight_left: SpotLight3D = $HeadlightLeft
@onready var headlight_right: SpotLight3D = $HeadlightRight
@onready var needle: TextureRect = $CanvasLayer/Speedometer/Needle
@onready var engine_start_sound: AudioStreamPlayer3D = $EngineStart
@onready var engine_idle_sound: AudioStreamPlayer3D = $EngineIdle

@export var min_angle: float = 0.0
@export var max_angle: float = 264.0
@export var max_speed: float = 160.0


var headlights_on = false
var reverse_mode := false
var camera_yaw := 0.0  # horizontal pan offset from car's heading
var engine_running = false
var _off_road_warned := false 
var _off_road_check_enabled := false
 
# 0-100 timer
var timing := false
var timer := 0.0
var start_speed_threshold = 2.0  # km/h, starts when car actually moves
var test_done := false  # prevents repeated prints in one run
 
 
func _get_speed_scaled_steer() -> float:
	var speed_kmh = linear_velocity.length() * 3.6
	# Full steer angle up to 30 km/h, tapers to 20% at 120 km/h
	var steer_factor = clamp(1.0 - (speed_kmh / 120.0) * 0.8, 0.2, 1.0)
	return MAX_STEER * steer_factor
 

func _start_engine():
	engine_running = true
	engine_start_sound.play()
	# Wait for the starter sound to finish, then loop the idle sound
	await engine_start_sound.finished
	engine_idle_sound.play()


func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Start with main camera active
	camera_3d.current = true
	reverse_camera.current = false
	
	# Give the car a moment to settle onto the road before monitoring off-road state
	await get_tree().create_timer(1.5).timeout
	_off_road_check_enabled = true
 
 
func _input(event):
	if event.is_action_pressed("start_engine") and not engine_running:
		_start_engine()
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
		
	if event.is_action_pressed("toggle_headlights"):
		headlights_on = !headlights_on
		headlight_left.visible = headlights_on
		headlight_right.visible = headlights_on

 
 
func _physics_process(delta):
	_check_camera_switch() 
	
	_check_off_road()
	# Speed-scaled steering return rate (recalculated every frame)
	var speed_kmh = linear_velocity.length() * 3.6
	var return_rate = lerp(1.0, 3.5, clamp(speed_kmh / 100.0, 0.0, 1.0))
	
	# Speedometer -> Needle rotation
	var ratio = clamp(speed_kmh / max_speed, 0.0, 1.0)
	needle.rotation_degrees = lerp(min_angle, max_angle, ratio)
 
	# Steering — smoothly moves toward input direction
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * _get_speed_scaled_steer(),
		delta * return_rate
	)
	# Acceleration/braking — engine force tapers off as speed approaches the cap
	var speed_taper = clamp(1.0 - (speed_kmh / 120.0), 0.0, 1.0)	
	engine_force = Input.get_axis("steer_back", "steer_forward") * ENGINE_POWER * speed_taper if engine_running else 0.0

	# Snap pivot position to car each frame
	camera_pivot.global_position = global_position
	# Smoothly rotate pivot to match car heading + any pan offset
	camera_pivot.global_rotation.y = lerp_angle(
		camera_pivot.global_rotation.y,
		global_rotation.y + camera_yaw,
		delta * 5.0
	)
 
	spring_arm.rotation.x = 0.0
	spring_arm.rotation.z = 0.0
 
	# Drifting — lower friction on rear wheels
	if Input.is_action_pressed("drift"):
		$back_right.wheel_friction_slip = 0.5
		$back_left.wheel_friction_slip = 0.5
	else:
		$back_right.wheel_friction_slip = 1.5
		$back_left.wheel_friction_slip = 1.5
 
	# 0-100 km/h acceleration timer
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

func _check_off_road():
	if not _off_road_check_enabled:
		return

	var on_road_count := 0
	for wheel in wheels:
		var contact = wheel.get_contact_body()
		if contact and contact.is_in_group("road"):
			on_road_count += 1

	if on_road_count <= 1 and not _off_road_warned:
		_off_road_warned = true
		DialogueBox.show_dialogue("Instructor", "You've left the road — head back to the marked lane.")
	elif on_road_count >= 3 and _off_road_warned:
		_off_road_warned = false
		DialogueBox.hide_dialogue()
