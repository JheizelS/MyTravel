extends Node2D

@export var spin_speed: float = 1.2
var angle: float = 0.0

# Colours
const TYRE_COLOR       = Color(0.08, 0.08, 0.09)
const TYRE_DETAIL      = Color(0.14, 0.14, 0.16)
const RIM_COLOR        = Color(0.72, 0.62, 0.31)
const RIM_HIGHLIGHT    = Color(0.92, 0.82, 0.48)
const RIM_SHADOW       = Color(0.38, 0.28, 0.08)
const SPOKE_COLOR      = Color(0.78, 0.65, 0.32)
const HUB_COLOR        = Color(0.80, 0.68, 0.33)
const HUB_DARK         = Color(0.10, 0.10, 0.10)

func _process(delta: float) -> void:
	angle -= spin_speed * delta
	queue_redraw()

func _draw() -> void:
	var r = 280.0  # tyre radius — adjust to fit your viewport

	# --- Tyre ---
	draw_circle(Vector2.ZERO, r, TYRE_COLOR)

	# Tyre tread blocks around the edge
	var tread_count = 32
	for i in tread_count:
		var a1 = angle + (float(i) / tread_count) * TAU
		var a2 = a1 + (TAU / tread_count) * 0.55
		var points = PackedVector2Array()
		var steps = 10
		for s in steps:
			var a = lerp(a1, a2, float(s) / (steps - 1))
			points.append(Vector2(cos(a), sin(a)) * r * 0.97)
		for s in steps:
			var a = lerp(a2, a1, float(s) / (steps - 1))
			points.append(Vector2(cos(a), sin(a)) * r * 0.82)
		var col = TYRE_DETAIL if i % 2 == 0 else TYRE_COLOR
		draw_colored_polygon(points, col)

	# Sidewall ring
	draw_arc(Vector2.ZERO, r * 0.88, 0, TAU, 64, Color(1,1,1,0.04), r * 0.06)
	draw_arc(Vector2.ZERO, r * 0.80, 0, TAU, 64, Color(1,1,1,0.03), r * 0.02)

	# --- Rim ---
	var rim_r = r * 0.70
	draw_circle(Vector2.ZERO, rim_r, RIM_COLOR)

	# --- Spokes x5 ---
	var spoke_count = 5
	var hub_r = r * 0.16
	for i in spoke_count:
		var a = angle + (float(i) / spoke_count) * TAU
		var dir = Vector2(cos(a), sin(a))
		var perp = Vector2(-sin(a), cos(a))

		var p1 = dir * hub_r * 1.2 + perp * r * 0.055
		var p2 = dir * rim_r * 0.92 + perp * r * 0.028
		var p3 = dir * rim_r * 0.92 - perp * r * 0.028
		var p4 = dir * hub_r * 1.2 - perp * r * 0.055

		draw_colored_polygon(
			PackedVector2Array([p1, p2, p3, p4]),
			SPOKE_COLOR
		)
		# Spoke highlight line
		draw_line(
			dir * hub_r * 1.3 + perp * 1.0,
			dir * rim_r * 0.88 + perp * 0.5,
			Color(1.0, 0.92, 0.55, 0.4), 1.5
		)

	# Rim outer ring
	draw_arc(Vector2.ZERO, rim_r, 0, TAU, 64, Color(1,1,1,0.15), 2.0)

	# --- Hub ---
	draw_circle(Vector2.ZERO, hub_r, HUB_COLOR)
	draw_arc(Vector2.ZERO, hub_r, 0, TAU, 32, Color(1,1,1,0.35), 1.5)
	draw_circle(Vector2.ZERO, hub_r * 0.42, HUB_DARK)
