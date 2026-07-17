extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var amount_label: Label = %AmountLabel
@onready var time_label: Label = %TimeLabel
@onready var body_label: Label = %BodyLabel
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(queue_free)
	close_button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	_style_popup()
	AudioManager.play_sfx(AudioManager.Sfx.POPUP)

func setup(seconds: float, amount: float) -> void:
	if not is_inside_tree():
		await ready
	title_label.text = LocalizationManager.t("ui.offline_title")
	amount_label.text = "+" + NumberFormatter.format(amount) + " Aura"
	time_label.text = LocalizationManager.t("ui.offline_time", {"time": NumberFormatter.format_time(seconds)})
	body_label.text = LocalizationManager.t("ui.offline_body")
	close_button.text = LocalizationManager.t("ui.close")
	modulate.a = 0.0
	scale = Vector2(0.94, 0.94)
	var tween: Tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _style_popup() -> void:
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.035, 0.07, 0.97)
	panel_style.border_color = Color(1.0, 0.23, 0.72, 0.62)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", panel_style)
	title_label.add_theme_color_override("font_color", Color("#fff7d6"))
	amount_label.add_theme_color_override("font_color", Color("#facc15"))
	amount_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.18, 0.72, 0.45))
	amount_label.add_theme_constant_override("shadow_offset_x", 2)
	amount_label.add_theme_constant_override("shadow_offset_y", 2)
	time_label.add_theme_color_override("font_color", Color("#67e8f9"))
	body_label.add_theme_color_override("font_color", Color("#cbd5e1"))
	_style_button(close_button)

func _style_button(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.09, 0.095, 0.14, 0.96)
	normal.border_color = Color(1.0, 0.78, 0.25, 0.42)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.12, 0.07, 0.98)
	hover.border_color = Color("#facc15")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("#fff7d6"))
