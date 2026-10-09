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
@onready var wrong_lane_detector: Area3D = $WrongLaneDetector
@onready var finish_detector: Area3D = $FinishDetector
@onready var speed_bg: Panel = $CanvasLayer/Speedometer/SpeedBackground

@export var stuck_speed_threshold: float = 1.0 # m/s , not moving 
@export var stuck_time_required: float = 3.5 # seconds required before flagging as stuck
@export var min_angle: float = 0.0
@export var max_angle: float = 264.0
@export var max_speed: float = 160.0
@export var target_score := 25
@export var speeding_threshold_kmh: float = 50.0
@export var speeding_warning_delay: float = 5.0
@export var resume_speed_kmh: float = 45.0
@export var slow_warning_delay: float = 6.0
@export var slow_resume_speed_kmh: float = 40.0
@export var good_speed_color := Color(0.2, 0.8, 0.3, 0.6)
@export var bad_speed_color := Color(0.9, 0.15, 0.15, 0.6)
@export var idle_speed_color := Color(1, 1, 1, 0.0)


var _lesson_complete := false
var headlights_on = false
var reverse_mode := false
var camera_yaw := 0.0  # horizontal pan offset from car's heading
var engine_running = false
var _off_road_warned := false 
var _off_road_check_enabled := false
var _in_wrong_lane := false
var speeding_timer: float = 0.0
var speeding_warning_active: bool = false
var slow_timer: float = 0.0
var slow_warning_active: bool = false
var _stuck_timer: float = 0.0
var is_stuck: bool = false
var slow_check_enabled := false
var _pending_teleport := false
var _teleport_transform := Transform3D.IDENTITY


 
func _get_speed_scaled_steer() -> float:
	var speed_kmh = linear_velocity.length() * 3.6
	# Full steer angle up to 30 km/h, tapers to 20% at 120 km/h
	var steer_factor = clamp(1.0 - (speed_kmh / 120.0) * 0.8, 0.2, 1.0)
	return MAX_STEER * steer_factor
 

func _start_engine():
	engine_running = true
	engine_start_sound.play()


func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Start with main camera active
	camera_3d.current = true
	reverse_camera.current = false
	
	GraphicsSettings.apply_quality()
	SpeedingPopup.dismissed.connect(_on_speeding_dismissed)
	SlowPopup.dismissed.connect(_on_slow_dismissed)
	WrongLanePopup.dismissed.connect(_on_wrong_lane_dismissed)
	OffRoadIndicator.hide_indicator()
	StuckIndicator.hide_indicator()
	# Give the car a moment to settle onto the road before monitoring off-road state
	await get_tree().create_timer(1.5).timeout
	_off_road_check_enabled = true
 
	finish_detector.area_entered.connect(_on_finish_detector_area_entered)
 

func _input(event):
	
	if PauseMenu.is_paused:
		return
	if event.is_action_pressed("start_engine") and not engine_running:
		_start_engine()
	
	if event.is_action_pressed("retry_lesson") and is_stuck:
		# DEBUG: print("R pressed | is_stuck: ", is_stuck)
		_respawn()
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
	if event.is_action_pressed("retry_lesson") and _lesson_complete and ScoreManager.score < ScoreManager.target_score:
		ScoreManager.reset_score()
		get_tree().reload_current_scene()
 

func _physics_process(delta):
	_check_camera_switch() 

	_check_off_road()
	_check_wrong_lane()
	_check_speeding(delta)
	_check_slow(delta)
	_check_stuck(delta)

	# Speed-scaled steering return rate (recalculated every frame)
	var speed_kmh = linear_velocity.length() * 3.6
	var return_rate = lerp(1.0, 3.5, clamp(speed_kmh / 100.0, 0.0, 1.0))
	
	ScoreManager.set_speed(speed_kmh) 
	
	# Speedometer -> Needle rotation
	var ratio = clamp(speed_kmh / max_speed, 0.0, 1.0)
	needle.rotation_degrees = lerp(min_angle, max_angle, ratio)
	_update_speed_background(speed_kmh, delta)
	
	if PauseMenu.is_paused:
		steering = move_toward(steering, 0.0, delta * return_rate)
		engine_force = 0.0
	else:
		steering = move_toward(
			steering,
			Input.get_axis("steer_right", "steer_left") * _get_speed_scaled_steer(),
			delta * return_rate
		)
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
	if not _off_road_check_enabled or _lesson_complete:
		return

	var on_road_count := 0
	for wheel in wheels:
		var contact = wheel.get_contact_body()
		if contact and contact.is_in_group("road"):
			on_road_count += 1

	if on_road_count <= 1 and not _off_road_warned:
		_off_road_warned = true
		ScoreManager.set_off_road(true)
		OffRoadIndicator.show_indicator()
	elif on_road_count >= 3 and _off_road_warned:
		_off_road_warned = false
		ScoreManager.set_off_road(false)
		OffRoadIndicator.hide_indicator()
		
		
func _check_wrong_lane():
	if _lesson_complete:
		return
		
	var overlapping_areas = wrong_lane_detector.get_overlapping_areas()
	var in_wrong_lane_now := false
 
	for area in overlapping_areas:
		if area.is_in_group("WrongLaneZone"):
			in_wrong_lane_now = true
			break

	if in_wrong_lane_now and not _in_wrong_lane:
		_in_wrong_lane = true
		ScoreManager.set_wrong_lane(true)
		WrongLanePopup.show_popup()
		get_tree().paused = true
	elif not in_wrong_lane_now and _in_wrong_lane:
		_in_wrong_lane = false
		ScoreManager.set_wrong_lane(false)


func _on_wrong_lane_dismissed() -> void:
	get_tree().paused = false


func _on_finish_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("finish_line") and not _lesson_complete:
		_lesson_complete = true
		ScoreManager.freeze_scoring()
		if ScoreManager.score >= ScoreManager.target_score:
			DialogueBox.show_dialogue("Instructor:", "Lesson complete! Final score: %d" % ScoreManager.score, "lesson_complete")
		else:
			DialogueBox.show_dialogue("Instructor:", "Score: %d / %d — not quite. Press R to try again." % [ScoreManager.score, ScoreManager.target_score], "lesson_failed")


func _check_speeding(delta: float) -> void:
	if _lesson_complete:
		speeding_timer = 0.0
		return

	var speed_kmh = linear_velocity.length() * 3.6
	if speed_kmh > speeding_threshold_kmh:
		speeding_timer += delta
		if speeding_timer >= speeding_warning_delay and not speeding_warning_active:
			speeding_warning_active = true
			ScoreManager.set_speeding(true)
			SpeedingPopup.show_popup()
			get_tree().paused = true
	else:
		speeding_timer = 0.0


func _on_speeding_dismissed() -> void:
	get_tree().paused = false
	# Keep the car's current direction, but drop the speed to resume_speed_kmh
	linear_velocity = linear_velocity.normalized() * (resume_speed_kmh / 3.6)
	speeding_warning_active = false
	speeding_timer = 0.0
	ScoreManager.set_speeding(false)


func _check_slow(delta: float) -> void:
	var reversing = Input.get_axis("steer_back", "steer_forward") < 0.0
	var too_slow: bool = (
		slow_check_enabled
		and engine_running
		and _off_road_check_enabled
		and not is_stuck
		and not _lesson_complete
		and not PauseMenu.is_paused
		and not ScoreManager.is_off_road
		and not ScoreManager.is_wrong_lane
		and not reversing
		and not slow_warning_active
		and linear_velocity.length() * 3.6 < ScoreManager.MIN_SCORING_SPEED_KMH
	)

	if too_slow:
		slow_timer += delta
		if slow_timer >= slow_warning_delay:
			slow_warning_active = true
			SlowPopup.show_popup()
			get_tree().paused = true
	else:
		slow_timer = 0.0

func _on_slow_dismissed() -> void:
	get_tree().paused = false
	# The car may be standing still, so work out "forward" from the wheels
	linear_velocity = _get_forward_direction() * (slow_resume_speed_kmh / 3.6)
	slow_warning_active = false
	slow_timer = 0.0

func _get_forward_direction() -> Vector3:
	var front = (wheels[0].global_position + wheels[1].global_position) * 0.5
	var back = (wheels[2].global_position + wheels[3].global_position) * 0.5
	var dir = front - back
	dir.y = 0.0
	return dir.normalized()



func _check_stuck(delta: float) -> void:
	if not engine_running or PauseMenu.is_paused or not slow_check_enabled:
		_stuck_timer = 0.0
		if is_stuck:
			is_stuck = false
			StuckIndicator.hide_indicator()
		return

	if linear_velocity.length() < stuck_speed_threshold:
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0

	if _stuck_timer >= stuck_time_required and not is_stuck:
		is_stuck = true
		# Stuck takes priority over the off-road icon so they don't overlap
		OffRoadIndicator.hide_indicator()
		StuckIndicator.show_indicator()
	elif _stuck_timer < stuck_time_required and is_stuck:
		is_stuck = false
		StuckIndicator.hide_indicator()


func _respawn() -> void:
	var barrier := get_tree().get_first_node_in_group("respawn_trigger")
	# DEBUG: print("respawn barrier found: ", barrier)
	if barrier:
		barrier.respawn(self)
		StuckIndicator.hide_indicator()
		is_stuck = false
		_stuck_timer = 0.0


func teleport_to(target: Transform3D) -> void:
	_teleport_transform = target
	_pending_teleport = true
	steering = 0.0
	engine_force = 0.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _pending_teleport:
		_pending_teleport = false
		state.transform = _teleport_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		

func _update_speed_background(speed_kmh: float, delta: float) -> void:
	print("engine: ", engine_running, " | intro done: ", slow_check_enabled, " | kmh: ", snappedf(speed_kmh, 0.1))
	var target: Color
	if not engine_running or not slow_check_enabled:
		target = idle_speed_color
	elif speed_kmh >= ScoreManager.MIN_MOVING_SPEED_KMH and speed_kmh <= speeding_threshold_kmh:
			target = good_speed_color
	else:
		target = bad_speed_color
	speed_bg.modulate = speed_bg.modulate.lerp(target, delta * 8.0)
