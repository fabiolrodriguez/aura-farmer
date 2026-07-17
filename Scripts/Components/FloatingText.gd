extends Label

func setup(text_value: String) -> void:
	text = text_value
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _ready() -> void:
	pivot_offset = size * 0.5
	add_theme_font_size_override("font_size", 28)
	add_theme_color_override("font_color", Color("#fef08a"))
	var tween: Tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y - 58.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.7)
	tween.finished.connect(queue_free)
