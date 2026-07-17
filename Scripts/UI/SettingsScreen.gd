extends Control

func _ready() -> void:
	_build()
	LocalizationManager.language_changed.connect(_on_language_changed)

func _build() -> void:
	for child in get_children():
		child.queue_free()
	var background: ColorRect = ColorRect.new()
	background.color = Color("#10131a")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var panel: VBoxContainer = VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 420)
	panel.position = Vector2(-240, -210)
	panel.add_theme_constant_override("separation", 16)
	add_child(panel)

	var title: Label = Label.new()
	title.text = LocalizationManager.t("ui.settings")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	panel.add_child(title)

	var language: OptionButton = OptionButton.new()
	language.add_item("Português", 0)
	language.add_item("English", 1)
	language.selected = 0 if LocalizationManager.language == "pt" else 1
	language.item_selected.connect(func(index: int): LocalizationManager.set_language("pt" if index == 0 else "en"))
	_style_button(language)
	panel.add_child(_with_label("settings.language", language))

	var sfx_volume: HSlider = HSlider.new()
	sfx_volume.min_value = 0.0
	sfx_volume.max_value = 1.0
	sfx_volume.step = 0.01
	sfx_volume.value = SettingsManager.get_setting("sfx_volume", 0.85)
	sfx_volume.value_changed.connect(func(value: float): SettingsManager.set_setting("sfx_volume", value))
	panel.add_child(_with_label("settings.sfx_volume", sfx_volume))

	var music_volume: HSlider = HSlider.new()
	music_volume.min_value = 0.0
	music_volume.max_value = 1.0
	music_volume.step = 0.01
	music_volume.value = SettingsManager.get_setting("music_volume", 0.5)
	music_volume.value_changed.connect(func(value: float): SettingsManager.set_setting("music_volume", value))
	panel.add_child(_with_label("settings.music_volume", music_volume))

	var music_enabled: CheckBox = CheckBox.new()
	music_enabled.text = LocalizationManager.t("settings.music_enabled")
	music_enabled.button_pressed = SettingsManager.get_setting("music_enabled", true)
	music_enabled.toggled.connect(func(value: bool): AudioManager.set_music_enabled(value))
	music_enabled.add_theme_color_override("font_color", Color("#dbeafe"))
	panel.add_child(music_enabled)

	var fullscreen: CheckBox = CheckBox.new()
	fullscreen.text = LocalizationManager.t("settings.fullscreen")
	fullscreen.button_pressed = SettingsManager.get_setting("fullscreen", false)
	fullscreen.toggled.connect(func(value: bool): SettingsManager.set_setting("fullscreen", value))
	fullscreen.add_theme_color_override("font_color", Color("#dbeafe"))
	panel.add_child(fullscreen)

	var reduced_motion: CheckBox = CheckBox.new()
	reduced_motion.text = LocalizationManager.t("settings.reduced_motion")
	reduced_motion.button_pressed = SettingsManager.get_setting("reduced_motion", false)
	reduced_motion.toggled.connect(func(value: bool): SettingsManager.set_setting("reduced_motion", value))
	panel.add_child(reduced_motion)

	var back: Button = Button.new()
	back.text = LocalizationManager.t("ui.back")
	back.custom_minimum_size = Vector2(220, 48)
	_style_button(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn"))
	panel.add_child(back)

func _with_label(key: String, control: Control) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	var label: Label = Label.new()
	label.text = LocalizationManager.t(key)
	box.add_child(label)
	box.add_child(control)
	return box

func _on_language_changed(_language: String) -> void:
	_build()

func _style_button(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.09, 0.12, 0.92)
	normal.border_color = Color(1.0, 0.78, 0.25, 0.35)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.15, 0.12, 0.075, 0.98)
	hover.border_color = Color("#facc15")
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.045, 0.052, 0.075, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#fff7d6"))
