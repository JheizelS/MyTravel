extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 300

# Camera pan settings
const MOUSE_SENSITIVITY = 0.003
const CAMERA_PITCH_MIN = -20.0  # degrees
const CAMERA_PITCH_MAX = 40.0
const MAX_PAN_ANGLE = 70.0

@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera_3d = $CameraPivot/SpringArm3D/Camera3D
@onready var reverse_camera = $CameraPivot/SpringArm3D/ReverseCamera

var reverse_mode := false
var camera_yaw := 0.0    # horizontal offset from car's heading

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_3d.current = true
	reverse_camera.current = false

func _input(event):
	if event is InputEventMouseMotion and not reverse_mode:
		# Horizontal pan — offset yaw from car direction
		camera_yaw -= event.relative.x * MOUSE_SENSITIVITY
		camera_yaw = clamp(camera_yaw, deg_to_rad(-MAX_PAN_ANGLE), deg_to_rad(MAX_PAN_ANGLE))

func _physics_process(delta):
	_check_camera_switch()

	# CAR MOVEMENT
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * MAX_STEER,
		delta * 2.5
	)
	engine_force = Input.get_axis("steer_back", "steer_forward") * ENGINE_POWER

	# CAMERA FOLLOW
	camera_pivot.global_position = global_position

	# Pivot Y = car's heading + player's horizontal pan offset
	camera_pivot.global_rotation.y = lerp_angle(
		camera_pivot.global_rotation.y,
		global_rotation.y + camera_yaw,
		delta * 5.0
	)

	# DRIFTING
	if Input.is_action_pressed("drift"):
		$back_right.wheel_friction_slip = 0.5
		$back_left.wheel_friction_slip = 0.5
	else:
		$back_right.wheel_friction_slip = 1.5
		$back_left.wheel_friction_slip = 1.5

func _check_camera_switch():
	if Input.is_action_just_pressed("reverse_camera"):
		reverse_mode = !reverse_mode
		if reverse_mode:
			camera_yaw = 0.0  # snap back to centre when entering reverse, so reverse camera is unpanable
	if reverse_mode:
		reverse_camera.current = true
		camera_3d.current = false
	else:
		camera_3d.current = true
		reverse_camera.current = false
