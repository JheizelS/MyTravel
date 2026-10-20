extends GridContainer

@onready var w_key = $keyboard_w
@onready var a_key = $keyboard_a
@onready var s_key = $keyboard_s
@onready var d_key = $keyboard_d
@onready var keyboard_r: TextureRect = $"../SideUIContainer/keyboard_r"
@onready var keyboard_t: TextureRect = $"../SideUIContainer/keyboard_t"


var reverse_camera_on = false
var headlights_on = false

func _ready() -> void:
	print("Script on: ", get_path())
	print("keyboard_t: ", keyboard_t)
	print("keyboard_r: ", keyboard_r)


func _process(_delta):
	update_key(w_key, "steer_forward")
	update_key(a_key, "steer_left")
	update_key(s_key, "steer_back")
	update_key(d_key, "steer_right")

	if Input.is_action_just_pressed("toggle_headlights"):
		headlights_on = !headlights_on

	if headlights_on:
		keyboard_t.modulate = Color.CADET_BLUE
	else:
		keyboard_t.modulate = Color(1.0, 1.0, 1.0, 0.4)
	
	if Input.is_action_just_pressed("reverse_camera"):
		reverse_camera_on = !reverse_camera_on
	
	if reverse_camera_on:
		keyboard_r.modulate = Color.CADET_BLUE
	
	else:
		keyboard_r.modulate = Color(1.0, 1.0, 1.0, 0.4)

func update_key(key_node: TextureRect, action_name: String):
	if Input.is_action_pressed(action_name):
		key_node.modulate = Color.CADET_BLUE
	else:
		key_node.modulate = Color(1.0, 1.0, 1.0, 0.4)
