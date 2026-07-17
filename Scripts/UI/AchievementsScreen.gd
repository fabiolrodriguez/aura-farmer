extends Control

var _grid: GridContainer
var _title: Label
var _subtitle: Label
var _progress: ProgressBar
var _back_button: Button

func _ready() -> void:
	_build()
	LocalizationManager.language_changed.connect(_on_language_changed)
	AchievementManager.achievements_changed.connect(_refresh)

func _build() -> void:
	for child in get_children():
		child.queue_free()
	var background: ColorRect = ColorRect.new()
	background.color = Color("#070516")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow: ColorRect = ColorRect.new()
	glow.color = Color(1.0, 0.18, 0.72, 0.08)
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.offset_top = 430.0
	add_child(glow)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 54)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 54)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 42)
	_title.add_theme_color_override("font_color", Color("#fff7d6"))
	layout.add_child(_title)

	_subtitle = Label.new()
	_subtitle.add_theme_font_size_override("font_size", 17)
	_subtitle.add_theme_color_override("font_color", Color("#cbd5e1"))
	layout.add_child(_subtitle)

	_progress = ProgressBar.new()
	_progress.custom_minimum_size = Vector2(720.0, 20.0)
	_progress.show_percentage = false
	_style_progress(_progress)
	layout.add_child(_progress)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_grid)

	_back_button = _make_button("ui.back", _on_back_pressed)
	layout.add_child(_back_button)
	_refresh()

func _refresh() -> void:
	if _grid == null:
		return
	_title.text = LocalizationManager.t("achievements.title")
	_subtitle.text = LocalizationManager.t("achievements.subtitle", {
		"unlocked": str(AchievementManager.get_unlocked_count()),
		"total": str(AchievementManager.achievements.size())
	})
	_progress.max_value = max(1.0, float(AchievementManager.achievements.size()))
	_progress.value = float(AchievementManager.get_unlocked_count())
	_back_button.text = LocalizationManager.t("ui.back")
	for child in _grid.get_children():
		child.queue_free()
	for achievement in AchievementManager.achievements:
		_grid.add_child(_make_badge_card(achievement))

func _make_badge_card(achievement: Dictionary) -> PanelContainer:
	var unlocked: bool = AchievementManager.is_unlocked(str(achievement["id"]))
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(360.0, 138.0)
	card.add_theme_stylebox_override("panel", _make_card_style(unlocked))

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var icon: Label = Label.new()
	icon.custom_minimum_size = Vector2(70.0, 70.0)
	icon.text = str(achievement.get("icon", "?"))
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 42)
	icon.add_theme_color_override("font_color", Color("#facc15") if unlocked else Color("#64748b"))
	row.add_child(icon)

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 6)
	row.add_child(text_box)

	var name_label: Label = Label.new()
	name_label.text = LocalizationManager.t(str(achievement["name_key"])) if unlocked else LocalizationManager.t("achievements.locked")
	name_label.add_theme_font_size_override("font_size", 19)
	name_label.add_theme_color_override("font_color", Color("#fff7d6") if unlocked else Color("#94a3b8"))
	text_box.add_child(name_label)

	var description_label: Label = Label.new()
	description_label.text = LocalizationManager.t(str(achievement["description_key"])) if unlocked else LocalizationManager.t("achievements.locked_hint")
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 13)
	description_label.add_theme_color_override("font_color", Color("#cbd5e1") if unlocked else Color("#64748b"))
	text_box.add_child(description_label)

	var steam_id: Label = Label.new()
	steam_id.text = str(achievement.get("steam_id", ""))
	steam_id.add_theme_font_size_override("font_size", 11)
	steam_id.add_theme_color_override("font_color", Color(0.56, 0.74, 1.0, 0.52))
	text_box.add_child(steam_id)
	return card

func _make_card_style(unlocked: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.075, 0.11, 0.94) if unlocked else Color(0.035, 0.04, 0.06, 0.92)
	style.border_color = Color(1.0, 0.78, 0.25, 0.56) if unlocked else Color(0.34, 0.42, 0.56, 0.28)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func _make_button(text_key: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = LocalizationManager.t(text_key)
	button.custom_minimum_size = Vector2(260.0, 52.0)
	button.pressed.connect(callback)
	button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.09, 0.12, 0.92)
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
	button.add_theme_font_size_override("font_size", 17)
	return button

func _style_progress(progress: ProgressBar) -> void:
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.02, 0.025, 0.04, 0.96)
	background.corner_radius_top_left = 6
	background.corner_radius_top_right = 6
	background.corner_radius_bottom_left = 6
	background.corner_radius_bottom_right = 6
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#facc15")
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	progress.add_theme_stylebox_override("background", background)
	progress.add_theme_stylebox_override("fill", fill)

func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.Sfx.CLICK)
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func _on_language_changed(_language: String) -> void:
	_refresh()
