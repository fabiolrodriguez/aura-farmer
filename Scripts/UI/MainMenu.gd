extends Control

const MainCharacterTexture = preload("res://Assets/Sprites/Character/main_character.png")
const GameLogoTexture = preload("res://Assets/UI/Logo/aura_farmer_67_logo.png")

func _ready() -> void:
	_build()
	LocalizationManager.language_changed.connect(_on_language_changed)

func _build() -> void:
	for child in get_children():
		child.queue_free()
	var background: ColorRect = ColorRect.new()
	background.color = Color("#090b10")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var aura_band: ColorRect = ColorRect.new()
	aura_band.color = Color(0.96, 0.66, 0.12, 0.08)
	aura_band.set_anchors_preset(Control.PRESET_FULL_RECT)
	aura_band.offset_top = 420.0
	add_child(aura_band)

	var preview: TextureRect = TextureRect.new()
	preview.texture = MainCharacterTexture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(360, 540)
	preview.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	preview.offset_left = -430.0
	preview.offset_top = -290.0
	preview.offset_right = -70.0
	preview.offset_bottom = 250.0
	preview.modulate = Color(1.0, 0.94, 0.82, 0.92)
	add_child(preview)

	var center: VBoxContainer = VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	center.custom_minimum_size = Vector2(620, 460)
	center.offset_left = 88.0
	center.offset_top = -220.0
	center.offset_right = 708.0
	center.offset_bottom = 240.0
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 16)
	add_child(center)

	var logo: TextureRect = TextureRect.new()
	logo.texture = GameLogoTexture
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(560, 210)
	center.add_child(logo)

	var tagline: Label = Label.new()
	tagline.text = LocalizationManager.t("menu.tagline")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline.custom_minimum_size = Vector2(560, 56)
	tagline.add_theme_font_size_override("font_size", 18)
	tagline.add_theme_color_override("font_color", Color("#cbd5e1"))
	center.add_child(tagline)

	center.add_child(_make_button("menu.play", _on_play_pressed))
	center.add_child(_make_button("menu.achievements", _on_achievements_pressed))
	center.add_child(_make_button("menu.settings", _on_settings_pressed))
	center.add_child(_make_button("menu.quit", _on_quit_pressed))

func _make_button(text_key: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = LocalizationManager.t(text_key)
	button.custom_minimum_size = Vector2(310, 56)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_color_override("font_color", Color("#fff7d6"))
	button.add_theme_font_size_override("font_size", 18)
	_apply_button_style(button)
	button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER); _tween_scale(button, Vector2(1.04, 1.04)))
	button.mouse_exited.connect(func(): _tween_scale(button, Vector2.ONE))
	button.pressed.connect(callback)
	return button

func _apply_button_style(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.09, 0.12, 0.88)
	normal.border_color = Color(0.96, 0.72, 0.25, 0.42)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.12, 0.07, 0.96)
	hover.border_color = Color("#facc15")
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.04, 0.05, 0.075, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

func _tween_scale(control: Control, target: Vector2) -> void:
	if SettingsManager.get_setting("reduced_motion", false):
		control.scale = target
		return
	create_tween().tween_property(control, "scale", target, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings/Settings.tscn")

func _on_achievements_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Achievements/Achievements.tscn")

func _on_quit_pressed() -> void:
	SaveManager.save_game()
	get_tree().quit()

func _on_language_changed(_language: String) -> void:
	_build()
