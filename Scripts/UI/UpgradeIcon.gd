extends Control

var upgrade: Dictionary = {}
var base_color: Color = Color("#facc15")

func setup(data: Dictionary) -> void:
	upgrade = data
	var category: String = str(upgrade.get("category", "click"))
	match category:
		"auto":
			base_color = Color("#22d3ee")
		"multiplier":
			base_color = Color("#a78bfa")
		_:
			base_color = Color("#facc15")
	queue_redraw()

func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	var center: Vector2 = rect.get_center()
	var radius: float = min(size.x, size.y) * 0.42
	draw_circle(center, radius, base_color.darkened(0.42), true)
	draw_arc(center, radius - 2.0, 0.0, TAU, 48, base_color, 3.0)
	draw_circle(center, radius * 0.72, base_color.darkened(0.18), true)
	_draw_symbol(center, radius)

func _draw_symbol(center: Vector2, radius: float) -> void:
	var upgrade_id: String = str(upgrade.get("id", ""))
	var color: Color = Color.WHITE
	if upgrade_id.contains("glasses"):
		_draw_glasses(center, color)
	elif upgrade_id.contains("chain"):
		_draw_chain(center, color)
	elif upgrade_id.contains("sneakers"):
		_draw_shoe(center, color)
	elif upgrade_id.contains("coffee"):
		_draw_cup(center, color)
	elif upgrade_id.contains("creatine"):
		_draw_bolt(center, color)
	elif upgrade_id.contains("npc"):
		_draw_people(center, color)
	elif upgrade_id.contains("laptop") or upgrade_id.contains("editor"):
		_draw_screen(center, color)
	elif str(upgrade.get("category", "")) == "auto":
		_draw_clock(center, radius, color)
	elif str(upgrade.get("category", "")) == "multiplier":
		_draw_star(center, radius, color)
	else:
		_draw_bolt(center, color)

func _draw_glasses(center: Vector2, color: Color) -> void:
	draw_rect(Rect2(center + Vector2(-18, -6), Vector2(14, 9)), color, true)
	draw_rect(Rect2(center + Vector2(4, -6), Vector2(14, 9)), color, true)
	draw_line(center + Vector2(-4, -2), center + Vector2(4, -2), color, 2.0)

func _draw_chain(center: Vector2, color: Color) -> void:
	draw_arc(center + Vector2(0, -3), 17.0, 0.15 * PI, 0.85 * PI, 24, color, 4.0)
	draw_circle(center + Vector2(0, 9), 5.0, color, true)

func _draw_shoe(center: Vector2, color: Color) -> void:
	draw_polygon(PackedVector2Array([
		center + Vector2(-18, 7),
		center + Vector2(4, 7),
		center + Vector2(17, 2),
		center + Vector2(20, 10),
		center + Vector2(-18, 12)
	]), PackedColorArray([color]))
	draw_line(center + Vector2(-10, 4), center + Vector2(8, 4), color, 3.0)

func _draw_cup(center: Vector2, color: Color) -> void:
	draw_rect(Rect2(center + Vector2(-10, -8), Vector2(17, 20)), color, true)
	draw_arc(center + Vector2(9, 1), 8.0, -0.5 * PI, 0.5 * PI, 12, color, 3.0)
	draw_line(center + Vector2(-8, -14), center + Vector2(-5, -19), color, 2.0)
	draw_line(center + Vector2(0, -14), center + Vector2(3, -19), color, 2.0)

func _draw_bolt(center: Vector2, color: Color) -> void:
	draw_polygon(PackedVector2Array([
		center + Vector2(2, -21),
		center + Vector2(-11, 1),
		center + Vector2(0, 1),
		center + Vector2(-4, 21),
		center + Vector2(13, -4),
		center + Vector2(2, -4)
	]), PackedColorArray([color]))

func _draw_people(center: Vector2, color: Color) -> void:
	draw_circle(center + Vector2(-8, -4), 5.0, color, true)
	draw_circle(center + Vector2(8, -4), 5.0, color, true)
	draw_rect(Rect2(center + Vector2(-15, 4), Vector2(12, 13)), color, true)
	draw_rect(Rect2(center + Vector2(3, 4), Vector2(12, 13)), color, true)

func _draw_screen(center: Vector2, color: Color) -> void:
	draw_rect(Rect2(center + Vector2(-18, -13), Vector2(36, 24)), color, false, 3.0)
	draw_line(center + Vector2(-8, 16), center + Vector2(8, 16), color, 3.0)

func _draw_clock(center: Vector2, radius: float, color: Color) -> void:
	draw_arc(center, radius * 0.42, 0.0, TAU, 32, color, 3.0)
	draw_line(center, center + Vector2(0, -10), color, 3.0)
	draw_line(center, center + Vector2(9, 5), color, 3.0)

func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var angle: float = -PI / 2.0 + float(i) * TAU / 10.0
		var point_radius: float = radius * (0.52 if i % 2 == 0 else 0.24)
		points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
	draw_polygon(points, PackedColorArray([color]))
