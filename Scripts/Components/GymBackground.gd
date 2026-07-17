extends Control

var _time: float = 0.0
var _stage_index: int = 0
var _primary_color: Color = Color("#f472b6")
var _secondary_color: Color = Color("#12072b")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func apply_stage(stage: Dictionary, stage_index: int) -> void:
	_stage_index = stage_index
	_primary_color = Color(stage.get("primary_color", Color("#f472b6")))
	_secondary_color = Color(stage.get("secondary_color", Color("#12072b")))
	queue_redraw()

func _draw() -> void:
	var viewport_size: Vector2 = size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var horizon_y: float = viewport_size.y * 0.57
	var neon_pink: Color = Color("#ff3fb7").lerp(_primary_color, 0.18)
	var neon_blue: Color = Color("#38bdf8").lerp(_primary_color, 0.12)
	var sun_color: Color = Color("#ff9a76").lerp(_primary_color, 0.12)
	_draw_sky(viewport_size, horizon_y)
	_draw_stars(viewport_size, horizon_y)
	_draw_sun(viewport_size, horizon_y, sun_color, neon_pink)
	_draw_wire_mountains(viewport_size, horizon_y, neon_blue, neon_pink)
	_draw_floor(viewport_size, horizon_y, neon_blue, neon_pink)
	_draw_reflection(viewport_size, horizon_y, sun_color, neon_pink)
	_draw_stage_glow(viewport_size, horizon_y, neon_blue, neon_pink)
	_draw_vignette(viewport_size)

func _draw_sky(viewport_size: Vector2, horizon_y: float) -> void:
	var top_color: Color = Color("#050416").lerp(_secondary_color, 0.20)
	var mid_color: Color = Color("#26105a").lerp(_secondary_color, 0.12)
	var band_count: int = 18
	for i in range(band_count):
		var ratio: float = float(i) / float(max(1, band_count - 1))
		var y: float = horizon_y * ratio
		var color: Color = top_color.lerp(mid_color, pow(ratio, 1.45))
		color.a = 1.0
		draw_rect(Rect2(Vector2(0.0, y), Vector2(viewport_size.x, horizon_y / float(band_count) + 1.0)), color)
	var haze: Color = Color("#ff3fb7")
	haze.a = 0.10
	draw_rect(Rect2(Vector2(0.0, horizon_y - viewport_size.y * 0.16), Vector2(viewport_size.x, viewport_size.y * 0.18)), haze)
	var horizon_line: Color = Color("#67e8f9")
	horizon_line.a = 0.32
	draw_line(Vector2(0.0, horizon_y), Vector2(viewport_size.x, horizon_y), horizon_line, 2.0)

func _draw_stars(viewport_size: Vector2, horizon_y: float) -> void:
	for i in range(48):
		var x_seed: float = fmod(float(i * 73), 100.0) / 100.0
		var y_seed: float = fmod(float(i * 41), 100.0) / 100.0
		var point: Vector2 = Vector2(x_seed * viewport_size.x, y_seed * horizon_y * 0.72)
		var twinkle: float = 0.5 + sin(_time * 0.75 + float(i)) * 0.5
		var star: Color = Color.WHITE
		star.a = 0.035 + twinkle * 0.045
		draw_circle(point, 0.9 + float(i % 3) * 0.35, star)

func _draw_sun(viewport_size: Vector2, horizon_y: float, sun_color: Color, stripe_color: Color) -> void:
	var center: Vector2 = Vector2(viewport_size.x * 0.50, horizon_y - viewport_size.y * 0.16)
	var radius: float = min(viewport_size.x, viewport_size.y) * 0.135
	var glow: Color = stripe_color
	glow.a = 0.075
	draw_circle(center, radius * 1.65, glow)
	var sun: Color = sun_color
	sun.a = 0.92
	draw_circle(center, radius, sun)
	var lower: Color = Color("#ff3fb7")
	lower.a = 0.24
	draw_rect(Rect2(Vector2(center.x - radius, center.y), Vector2(radius * 2.0, radius)), lower)
	for i in range(6):
		var y: float = center.y + radius * (-0.10 + float(i) * 0.18)
		var half_width: float = sqrt(max(0.0, radius * radius - pow(y - center.y, 2.0)))
		var stripe: Color = stripe_color
		stripe.a = 0.82
		draw_line(Vector2(center.x - half_width, y), Vector2(center.x + half_width, y), stripe, 4.0 + float(i) * 0.5)

func _draw_wire_mountains(viewport_size: Vector2, horizon_y: float, blue: Color, pink: Color) -> void:
	var left_points: PackedVector2Array = _make_mountain_points(viewport_size, horizon_y, true)
	var right_points: PackedVector2Array = _make_mountain_points(viewport_size, horizon_y, false)
	_draw_mountain_mesh(left_points, horizon_y, blue, pink)
	_draw_mountain_mesh(right_points, horizon_y, blue, pink)

func _make_mountain_points(viewport_size: Vector2, horizon_y: float, left_side: bool) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var start_x: float = 0.0 if left_side else viewport_size.x * 0.62
	var end_x: float = viewport_size.x * 0.38 if left_side else viewport_size.x
	var count: int = 18
	for i in range(count):
		var ratio: float = float(i) / float(count - 1)
		var x: float = lerp(start_x, end_x, ratio)
		var ridge: float = sin(ratio * PI * 2.2 + (0.4 if left_side else 1.1)) * 18.0
		var detail: float = sin(ratio * PI * 9.0) * 7.0
		var center_fade: float = abs(ratio - (1.0 if left_side else 0.0))
		var height: float = viewport_size.y * (0.09 + center_fade * 0.05)
		var y: float = horizon_y - height + ridge + detail
		points.append(Vector2(x, y))
	return points

func _draw_mountain_mesh(points: PackedVector2Array, horizon_y: float, blue: Color, pink: Color) -> void:
	var fill: Color = Color("#080518")
	fill.a = 0.58
	var polygon: PackedVector2Array = PackedVector2Array(points)
	polygon.append(Vector2(points[points.size() - 1].x, horizon_y))
	polygon.append(Vector2(points[0].x, horizon_y))
	var fill_colors: PackedColorArray = PackedColorArray()
	for i in range(polygon.size()):
		fill_colors.append(fill)
	draw_polygon(polygon, fill_colors)
	var mesh_color: Color = blue
	mesh_color.a = 0.34
	var ridge_color: Color = pink
	ridge_color.a = 0.44
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], ridge_color, 1.2)
		var ground: Vector2 = Vector2(points[i].x, horizon_y)
		draw_line(points[i], ground, mesh_color, 0.8)
	for j in range(1, 5):
		var t: float = float(j) / 5.0
		for i in range(points.size() - 1):
			var a: Vector2 = points[i].lerp(Vector2(points[i].x, horizon_y), t)
			var b: Vector2 = points[i + 1].lerp(Vector2(points[i + 1].x, horizon_y), t)
			draw_line(a, b, mesh_color, 0.7)

func _draw_floor(viewport_size: Vector2, horizon_y: float, blue: Color, pink: Color) -> void:
	var floor_top: Color = Color("#170b3f").lerp(_secondary_color, 0.16)
	var floor_bottom: Color = Color("#09051f")
	var rows: int = 18
	for row in range(rows):
		var ratio: float = float(row) / float(rows)
		var y: float = horizon_y + (viewport_size.y - horizon_y) * ratio
		var color: Color = floor_top.lerp(floor_bottom, pow(ratio, 1.2))
		draw_rect(Rect2(Vector2(0.0, y), Vector2(viewport_size.x, (viewport_size.y - horizon_y) / float(rows) + 1.0)), color)
	var center: Vector2 = Vector2(viewport_size.x * 0.5, horizon_y)
	var line_color: Color = blue
	line_color.a = 0.46
	for i in range(-14, 15):
		var end_x: float = viewport_size.x * 0.5 + float(i) * viewport_size.x * 0.078
		draw_line(center, Vector2(end_x, viewport_size.y), line_color, 1.0)
	var cross_color: Color = pink
	cross_color.a = 0.38
	for row in range(11):
		var t: float = float(row + 1) / 11.0
		var y: float = horizon_y + pow(t, 1.85) * (viewport_size.y - horizon_y)
		draw_line(Vector2(0.0, y), Vector2(viewport_size.x, y), cross_color, 1.0)

func _draw_reflection(viewport_size: Vector2, horizon_y: float, sun_color: Color, pink: Color) -> void:
	var reflection: Color = sun_color
	reflection.a = 0.12
	var center_x: float = viewport_size.x * 0.5
	var top_y: float = horizon_y + 8.0
	for i in range(8):
		var t: float = float(i) / 7.0
		var y: float = top_y + t * viewport_size.y * 0.30
		var width: float = viewport_size.x * (0.18 - t * 0.08)
		var line: Color = reflection.lerp(pink, t * 0.35)
		line.a = max(0.0, reflection.a * (1.0 - t * 0.88))
		draw_line(Vector2(center_x - width, y), Vector2(center_x + width, y), line, 12.0 - t * 8.0)

func _draw_stage_glow(viewport_size: Vector2, horizon_y: float, blue: Color, pink: Color) -> void:
	var progression: float = clamp(float(_stage_index) / 14.0, 0.0, 1.0)
	var glow: Color = blue.lerp(pink, 0.45 + sin(_time * 0.35) * 0.10)
	glow.a = 0.05 + progression * 0.07
	draw_circle(Vector2(viewport_size.x * 0.5, horizon_y), viewport_size.y * (0.35 + progression * 0.08), glow)

func _draw_vignette(viewport_size: Vector2) -> void:
	var top: Color = Color.BLACK
	top.a = 0.20
	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, 48.0)), top)
	var bottom: Color = Color.BLACK
	bottom.a = 0.15
	draw_rect(Rect2(Vector2(0.0, viewport_size.y - 68.0), Vector2(viewport_size.x, 68.0)), bottom)
	var side: Color = Color.BLACK
	side.a = 0.13
	draw_rect(Rect2(Vector2.ZERO, Vector2(42.0, viewport_size.y)), side)
	draw_rect(Rect2(Vector2(viewport_size.x - 42.0, 0.0), Vector2(42.0, viewport_size.y)), side)
