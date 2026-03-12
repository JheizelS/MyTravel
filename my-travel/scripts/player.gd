extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 300

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var reverse_camera: Camera3D = $CameraPivot/ReverseCamera

var look_at

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_at = global_position
	
func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("steer_right","steer_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("steer_back","steer_forward") * ENGINE_POWER
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20.0)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(look_at)
	reverse_camera.look_at(look_at)
	_check_camera_switch()
	
func _check_camera_switch():
	if linear_velocity.length() < 0.5:
		return
	
	
	if linear_velocity.dot(transform.basis.z) > 0:
		camera_3d.current = true
	else:
		reverse_camera.current = true
