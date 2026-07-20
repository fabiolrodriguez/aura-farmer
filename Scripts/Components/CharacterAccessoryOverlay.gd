extends Node2D

func set_legendary_skin(_value: bool) -> void:
	queue_redraw()

func _draw() -> void:
	if UpgradeManager.levels.is_empty():
		return
	if _has_upgrade("premium_coffee"):
		_draw_coffee_spark()
	if _has_upgrade("infinite_creatine"):
		_draw_creatine_mark()
	if _has_upgrade("sigma_mode"):
		_draw_sigma_aura()

func _has_upgrade(upgrade_id: String) -> bool:
	return int(UpgradeManager.levels.get(upgrade_id, 0)) > 0

func _draw_coffee_spark() -> void:
	var color: Color = Color("#d9a15f")
	for i in range(3):
		var offset: Vector2 = Vector2(86.0 + float(i) * 10.0, -76.0 - float(i % 2) * 12.0)
		draw_line(offset + Vector2(-4, 0), offset + Vector2(4, 0), color, 2.0)
		draw_line(offset + Vector2(0, -4), offset + Vector2(0, 4), color, 2.0)

func _draw_creatine_mark() -> void:
	var color: Color = Color(0.95, 0.95, 1.0, 0.78)
	draw_arc(Vector2(-104, -4), 18.0, -0.25 * PI, 0.65 * PI, 24, color, 4.0)
	draw_arc(Vector2(104, -4), 18.0, 0.35 * PI, 1.25 * PI, 24, color, 4.0)

func _draw_sigma_aura() -> void:
	var color: Color = Color(0.75, 0.6, 1.0, 0.55)
	draw_arc(Vector2(0, -24), 168.0, 0.05 * PI, 0.95 * PI, 64, color, 3.0)
	draw_arc(Vector2(0, -24), 178.0, 1.05 * PI, 1.95 * PI, 64, color, 3.0)
