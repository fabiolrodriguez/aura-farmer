extends Control

@onready var aura_label: Label = %AuraLabel
@onready var total_label: Label = %TotalLabel
@onready var click_label: Label = %ClickLabel
@onready var second_label: Label = %SecondLabel
@onready var level_label: Label = %LevelLabel
@onready var next_stage_label: Label = %NextStageLabel
@onready var stage_panel: PanelContainer = %StagePanel
@onready var stage_progress: ProgressBar = %StageProgress
@onready var essence_panel: PanelContainer = %EssencePanel
@onready var essence_label: Label = %EssenceLabel
@onready var essence_gain_label: Label = %EssenceGainLabel
@onready var essence_progress: ProgressBar = %EssenceProgress
@onready var prestige_button: Button = %PrestigeButton
@onready var music_button: Button = %MusicButton
@onready var gym_background: Control = %GymBackground
@onready var shop_panel: Control = %ShopPanel
@onready var character_anchor: Control = %CharacterAnchor
@onready var character: Node2D = %Character
@onready var popup_layer: CanvasLayer = %PopupLayer

const OfflinePopupScene = preload("res://Scenes/Popup/OfflinePopup.tscn")
const CHARACTER_CLICK_RADIUS: float = 250.0

var _auto_feedback_timer: float = 0.0
var _pause_layer: CanvasLayer
var _pause_overlay: Control
var _pause_main_panel: VBoxContainer
var _pause_settings_panel: VBoxContainer
var _pause_title_label: Label
var _pause_resume_button: Button
var _pause_settings_button: Button
var _pause_exit_button: Button
var _pause_settings_title_label: Label
var _pause_settings_back_button: Button
var _pause_language_label: Label
var _pause_language: OptionButton
var _pause_sfx_label: Label
var _pause_music_label: Label
var _pause_music_enabled: CheckBox
var _pause_fullscreen: CheckBox
var _pause_reduced_motion: CheckBox
var _is_pause_settings_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	UIManager.register_game_scene(self)
	GameManager.aura_changed.connect(_refresh)
	GameManager.generation_changed.connect(_refresh)
	GameManager.prestige_changed.connect(_refresh)
	GameManager.offline_progress.connect(_show_offline_popup)
	AuraEvolutionManager.stage_changed.connect(_on_stage_changed)
	UpgradeManager.upgrade_purchased.connect(_on_upgrade_purchased)
	LocalizationManager.language_changed.connect(_refresh)
	LocalizationManager.language_changed.connect(_on_language_changed)
	character_anchor.gui_input.connect(_on_character_anchor_gui_input)
	prestige_button.pressed.connect(_on_prestige_pressed)
	prestige_button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	music_button.pressed.connect(_on_music_pressed)
	music_button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	_style_button(prestige_button, false)
	_style_button(music_button, true)
	_style_stage_panel()
	_style_essence_panel()
	_build_pause_menu()
	AuraEvolutionManager.validate_for_total_aura(GameManager.aura_total)
	_refresh()
	_refresh_pause_text()
	_on_stage_changed(AuraEvolutionManager.get_current_stage(), AuraEvolutionManager.current_stage_index)
	if GameManager.last_offline_amount > 0.0:
		_show_offline_popup(GameManager.last_offline_seconds, GameManager.last_offline_amount)
		GameManager.last_offline_seconds = 0.0
		GameManager.last_offline_amount = 0.0

func _exit_tree() -> void:
	get_tree().paused = false
	UIManager.unregister_game_scene(self)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _pause_overlay != null and _pause_overlay.visible and _is_pause_settings_open:
		_show_pause_main()
	else:
		_set_paused(not get_tree().paused)
	get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if GameManager.aura_per_second <= 0.0:
		return
	_auto_feedback_timer += delta
	if _auto_feedback_timer < 1.0:
		return
	_auto_feedback_timer = 0.0
	var amount: float = GameManager.aura_per_second * GameManager.global_multiplier
	EffectsManager.spawn_floating_text(self, character.global_position + Vector2(86.0, -18.0), "+" + NumberFormatter.format(amount) + "/s")

func _refresh() -> void:
	aura_label.text = "%s\n%s" % [LocalizationManager.t("ui.aura_current"), NumberFormatter.format(GameManager.aura_current)]
	total_label.text = "%s\n%s" % [LocalizationManager.t("ui.aura_total"), NumberFormatter.format(GameManager.aura_total)]
	click_label.text = "%s\n%s" % [LocalizationManager.t("ui.aura_per_click"), NumberFormatter.format(GameManager.aura_per_click * GameManager.global_multiplier)]
	second_label.text = "%s\n%s" % [LocalizationManager.t("ui.aura_per_second"), NumberFormatter.format(GameManager.aura_per_second * GameManager.global_multiplier)]
	level_label.text = "%s\n%s" % [LocalizationManager.t("ui.aura_level"), LocalizationManager.t(AuraEvolutionManager.get_current_stage().get("name_key", "stage.normal.name"))]
	_refresh_essence_meter()
	var next_stage: Dictionary = AuraEvolutionManager.get_next_stage()
	if next_stage.is_empty():
		next_stage_label.text = LocalizationManager.t("ui.max_stage")
		stage_progress.max_value = 1.0
		stage_progress.value = 1.0
	else:
		var current_stage: Dictionary = AuraEvolutionManager.get_current_stage()
		var current_threshold: float = float(current_stage.get("threshold", 0.0))
		var next_threshold: float = float(next_stage["threshold"])
		var progress_value: float = clamp((GameManager.aura_total - current_threshold) / max(1.0, next_threshold - current_threshold), 0.0, 1.0)
		next_stage_label.text = "%s\n%s - %s" % [
			LocalizationManager.t("ui.next_stage"),
			LocalizationManager.t(next_stage["name_key"]),
			NumberFormatter.format(float(next_stage["threshold"]))
		]
		stage_progress.max_value = 1.0
		stage_progress.value = progress_value
	prestige_button.text = LocalizationManager.t("ui.prestige")
	prestige_button.disabled = not GameManager.can_prestige()
	music_button.text = "♪" if AudioManager.is_music_enabled() else "×"

func _refresh_essence_meter() -> void:
	var prestige_requirement: float = 1000000.0
	var progress_value: float = clamp(GameManager.aura_current / prestige_requirement, 0.0, 1.0)
	var gained_essence: float = 0.0
	if GameManager.can_prestige():
		gained_essence = max(1.0, floor(sqrt(GameManager.aura_current / prestige_requirement)))
	var bonus_percent: float = GameManager.essence * 5.0
	essence_label.text = "%s\n%s" % [
		LocalizationManager.t("ui.essence"),
		LocalizationManager.t("ui.essence_bonus", {
			"amount": NumberFormatter.format(GameManager.essence),
			"bonus": NumberFormatter.format(bonus_percent)
		})
	]
	if GameManager.can_prestige():
		essence_gain_label.text = LocalizationManager.t("ui.essence_ready", {"amount": NumberFormatter.format(gained_essence)})
	else:
		essence_gain_label.text = LocalizationManager.t("ui.essence_next", {
			"percent": NumberFormatter.format(progress_value * 100.0),
			"target": NumberFormatter.format(prestige_requirement)
		})
	essence_progress.max_value = 1.0
	essence_progress.value = progress_value
	_apply_essence_meter_state()

func _on_language_changed(_language: String) -> void:
	_refresh_pause_text()

func _on_stage_changed(stage: Dictionary, _index: int) -> void:
	var background: ColorRect = %Background as ColorRect
	var background_color: Color = Color(stage.get("secondary_color", Color("#10131a")))
	background.color = background_color.darkened(0.22)
	_apply_stage_panel_colors(stage)
	if gym_background.has_method("apply_stage"):
		gym_background.call("apply_stage", stage, _index)
	if character.has_method("apply_stage"):
		character.apply_stage(stage)
	_refresh()

func _on_prestige_pressed() -> void:
	GameManager.prestige()

func _on_music_pressed() -> void:
	AudioManager.toggle_music()
	_refresh()

func _on_upgrade_purchased(_upgrade_id: String) -> void:
	_spawn_purchase_trail()

func _on_character_anchor_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if mouse_event.position.distance_to(character.position) > CHARACTER_CLICK_RADIUS:
		return
	if character.has_method("handle_player_click"):
		character.call("handle_player_click", self)
		accept_event()

func _show_offline_popup(seconds: float, amount: float) -> void:
	var popup: Node = OfflinePopupScene.instantiate()
	popup_layer.add_child(popup)
	popup.call("setup", seconds, amount)

func _spawn_purchase_trail() -> void:
	var start: Vector2 = shop_panel.global_position + Vector2(36.0, 120.0)
	var end: Vector2 = character.global_position + Vector2(0.0, -90.0)
	for i in range(7):
		var symbol: Label = Label.new()
		symbol.text = "$" if i % 2 == 0 else "+"
		symbol.add_theme_font_size_override("font_size", 26)
		symbol.add_theme_color_override("font_color", Color("#facc15"))
		symbol.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		symbol.add_theme_constant_override("shadow_offset_x", 2)
		symbol.add_theme_constant_override("shadow_offset_y", 2)
		symbol.global_position = start + Vector2(0.0, float(i) * 18.0)
		add_child(symbol)
		var mid: Vector2 = start.lerp(end, 0.5) + Vector2(randf_range(-80.0, 60.0), randf_range(-120.0, -40.0))
		var tween: Tween = create_tween()
		tween.tween_property(symbol, "global_position", mid, 0.22 + float(i) * 0.015).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(symbol, "global_position", end + Vector2(randf_range(-16.0, 16.0), randf_range(-18.0, 18.0)), 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(symbol, "scale", Vector2(0.55, 0.55), 0.28)
		tween.parallel().tween_property(symbol, "modulate:a", 0.0, 0.28)
		tween.finished.connect(symbol.queue_free)

func _style_button(button: Button, compact: bool) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.09, 0.105, 0.14, 0.94)
	normal.border_color = Color(1.0, 0.78, 0.25, 0.45)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.16, 0.13, 0.08, 0.98)
	hover.border_color = Color("#facc15")
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.06, 0.07, 0.095, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_color_override("font_color", Color("#fff7d6"))
	button.add_theme_font_size_override("font_size", 22 if compact else 15)

func _style_stage_panel() -> void:
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.04, 0.07, 0.82)
	panel_style.border_color = Color(1.0, 0.23, 0.72, 0.30)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	stage_panel.add_theme_stylebox_override("panel", panel_style)
	level_label.add_theme_color_override("font_color", Color("#fff7d6"))
	level_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.18, 0.72, 0.36))
	level_label.add_theme_constant_override("shadow_offset_x", 2)
	level_label.add_theme_constant_override("shadow_offset_y", 2)
	next_stage_label.add_theme_color_override("font_color", Color("#67e8f9"))
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.0, 0.0, 0.0, 0.34)
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
	stage_progress.add_theme_stylebox_override("background", background)
	stage_progress.add_theme_stylebox_override("fill", fill)

func _style_essence_panel() -> void:
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.035, 0.07, 0.88)
	panel_style.border_color = Color(0.36, 0.91, 1.0, 0.42)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	essence_panel.add_theme_stylebox_override("panel", panel_style)
	essence_label.add_theme_color_override("font_color", Color("#ecfeff"))
	essence_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	essence_label.add_theme_constant_override("shadow_offset_x", 2)
	essence_label.add_theme_constant_override("shadow_offset_y", 2)
	essence_gain_label.add_theme_color_override("font_color", Color("#facc15"))
	essence_gain_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	essence_gain_label.add_theme_constant_override("shadow_offset_x", 1)
	essence_gain_label.add_theme_constant_override("shadow_offset_y", 1)
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.0, 0.0, 0.0, 0.38)
	background.corner_radius_top_left = 6
	background.corner_radius_top_right = 6
	background.corner_radius_bottom_left = 6
	background.corner_radius_bottom_right = 6
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#22d3ee")
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	essence_progress.add_theme_stylebox_override("background", background)
	essence_progress.add_theme_stylebox_override("fill", fill)

func _apply_essence_meter_state() -> void:
	var panel_style: StyleBoxFlat = essence_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	var fill: StyleBoxFlat = essence_progress.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	if GameManager.can_prestige():
		panel_style.border_color = Color(1.0, 0.78, 0.25, 0.70)
		fill.bg_color = Color("#facc15")
		essence_gain_label.add_theme_color_override("font_color", Color("#fff7d6"))
	else:
		panel_style.border_color = Color(0.36, 0.91, 1.0, 0.42)
		fill.bg_color = Color("#22d3ee")
		essence_gain_label.add_theme_color_override("font_color", Color("#facc15"))
	essence_panel.add_theme_stylebox_override("panel", panel_style)
	essence_progress.add_theme_stylebox_override("fill", fill)

func _apply_stage_panel_colors(stage: Dictionary) -> void:
	var primary: Color = Color(stage.get("primary_color", Color("#facc15")))
	var panel_style: StyleBoxFlat = stage_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel_style.border_color = primary.lerp(Color("#ff3fb7"), 0.35)
	panel_style.border_color.a = 0.48
	stage_panel.add_theme_stylebox_override("panel", panel_style)
	level_label.add_theme_color_override("font_shadow_color", primary.darkened(0.25))
	next_stage_label.add_theme_color_override("font_color", primary.lerp(Color("#67e8f9"), 0.55))
	var fill: StyleBoxFlat = stage_progress.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	fill.bg_color = primary.lerp(Color("#facc15"), 0.35)
	stage_progress.add_theme_stylebox_override("fill", fill)

func _build_pause_menu() -> void:
	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 30
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.visible = false
	add_child(_pause_layer)

	_pause_overlay = Control.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.add_child(_pause_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(dim)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(430.0, 380.0)
	panel.position = Vector2(-215.0, -190.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	_pause_overlay.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	_pause_main_panel = VBoxContainer.new()
	_pause_main_panel.add_theme_constant_override("separation", 14)
	margin.add_child(_pause_main_panel)

	_pause_settings_panel = VBoxContainer.new()
	_pause_settings_panel.add_theme_constant_override("separation", 12)
	_pause_settings_panel.visible = false
	margin.add_child(_pause_settings_panel)

	_pause_title_label = Label.new()
	_pause_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause_title_label.add_theme_font_size_override("font_size", 34)
	_pause_title_label.add_theme_color_override("font_color", Color("#fff7d6"))
	_pause_main_panel.add_child(_pause_title_label)

	_pause_resume_button = _make_pause_button("", _on_pause_resume_pressed)
	_pause_settings_button = _make_pause_button("", _on_pause_settings_pressed)
	_pause_exit_button = _make_pause_button("", _on_pause_exit_pressed)
	_pause_main_panel.add_child(_pause_resume_button)
	_pause_main_panel.add_child(_pause_settings_button)
	_pause_main_panel.add_child(_pause_exit_button)

	_pause_settings_title_label = Label.new()
	_pause_settings_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause_settings_title_label.add_theme_font_size_override("font_size", 28)
	_pause_settings_title_label.add_theme_color_override("font_color", Color("#fff7d6"))
	_pause_settings_panel.add_child(_pause_settings_title_label)

	_pause_language = OptionButton.new()
	_pause_language.add_item("Português", 0)
	_pause_language.add_item("English", 1)
	_pause_language.selected = 0 if LocalizationManager.language == "pt" else 1
	_pause_language.item_selected.connect(_on_pause_language_selected)
	_style_button(_pause_language, false)
	var language_box: VBoxContainer = _make_setting_row("")
	_pause_language_label = language_box.get_child(0) as Label
	language_box.add_child(_pause_language)
	_pause_settings_panel.add_child(language_box)

	var sfx_slider: HSlider = _make_slider(SettingsManager.get_setting("sfx_volume", 0.85))
	sfx_slider.value_changed.connect(func(value: float): SettingsManager.set_setting("sfx_volume", value))
	var sfx_box: VBoxContainer = _make_setting_row("")
	_pause_sfx_label = sfx_box.get_child(0) as Label
	sfx_box.add_child(sfx_slider)
	_pause_settings_panel.add_child(sfx_box)

	var music_slider: HSlider = _make_slider(SettingsManager.get_setting("music_volume", 0.5))
	music_slider.value_changed.connect(func(value: float): SettingsManager.set_setting("music_volume", value))
	var music_box: VBoxContainer = _make_setting_row("")
	_pause_music_label = music_box.get_child(0) as Label
	music_box.add_child(music_slider)
	_pause_settings_panel.add_child(music_box)

	_pause_music_enabled = CheckBox.new()
	_pause_music_enabled.button_pressed = SettingsManager.get_setting("music_enabled", true)
	_pause_music_enabled.toggled.connect(func(value: bool): AudioManager.set_music_enabled(value))
	_pause_music_enabled.add_theme_color_override("font_color", Color("#dbeafe"))
	_pause_settings_panel.add_child(_pause_music_enabled)

	_pause_fullscreen = CheckBox.new()
	_pause_fullscreen.button_pressed = SettingsManager.get_setting("fullscreen", false)
	_pause_fullscreen.toggled.connect(func(value: bool): SettingsManager.set_setting("fullscreen", value))
	_pause_fullscreen.add_theme_color_override("font_color", Color("#dbeafe"))
	_pause_settings_panel.add_child(_pause_fullscreen)

	_pause_reduced_motion = CheckBox.new()
	_pause_reduced_motion.button_pressed = SettingsManager.get_setting("reduced_motion", false)
	_pause_reduced_motion.toggled.connect(func(value: bool): SettingsManager.set_setting("reduced_motion", value))
	_pause_reduced_motion.add_theme_color_override("font_color", Color("#dbeafe"))
	_pause_settings_panel.add_child(_pause_reduced_motion)

	_pause_settings_back_button = _make_pause_button("", _show_pause_main)
	_pause_settings_panel.add_child(_pause_settings_back_button)

func _make_pause_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260.0, 50.0)
	button.pressed.connect(callback)
	button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	_style_button(button, false)
	return button

func _make_slider(value: float) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = value
	slider.custom_minimum_size = Vector2(300.0, 28.0)
	return slider

func _make_setting_row(label_text: String) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#dbeafe"))
	box.add_child(label)
	return box

func _make_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.065, 0.09, 0.98)
	style.border_color = Color(1.0, 0.78, 0.25, 0.50)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_pause_layer.visible = paused
	if paused:
		_show_pause_main()
		AudioManager.play_sfx(AudioManager.Sfx.CLICK)

func _show_pause_main() -> void:
	_is_pause_settings_open = false
	_pause_main_panel.visible = true
	_pause_settings_panel.visible = false

func _show_pause_settings() -> void:
	_is_pause_settings_open = true
	_pause_main_panel.visible = false
	_pause_settings_panel.visible = true
	_pause_music_enabled.button_pressed = SettingsManager.get_setting("music_enabled", true)
	_pause_fullscreen.button_pressed = SettingsManager.get_setting("fullscreen", false)
	_pause_reduced_motion.button_pressed = SettingsManager.get_setting("reduced_motion", false)

func _on_pause_resume_pressed() -> void:
	AudioManager.play_sfx(AudioManager.Sfx.CLICK)
	_set_paused(false)

func _on_pause_settings_pressed() -> void:
	AudioManager.play_sfx(AudioManager.Sfx.CLICK)
	_show_pause_settings()

func _on_pause_exit_pressed() -> void:
	AudioManager.play_sfx(AudioManager.Sfx.CLICK)
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func _on_pause_language_selected(index: int) -> void:
	LocalizationManager.set_language("pt" if index == 0 else "en")

func _refresh_pause_text() -> void:
	if _pause_overlay == null:
		return
	_pause_title_label.text = LocalizationManager.t("ui.pause")
	_pause_resume_button.text = LocalizationManager.t("ui.resume")
	_pause_settings_button.text = LocalizationManager.t("menu.settings")
	_pause_exit_button.text = LocalizationManager.t("ui.exit_to_menu")
	_pause_settings_title_label.text = LocalizationManager.t("ui.settings")
	_pause_settings_back_button.text = LocalizationManager.t("ui.back")
	_pause_language_label.text = LocalizationManager.t("settings.language")
	_pause_sfx_label.text = LocalizationManager.t("settings.sfx_volume")
	_pause_music_label.text = LocalizationManager.t("settings.music_volume")
	_pause_music_enabled.text = LocalizationManager.t("settings.music_enabled")
	_pause_fullscreen.text = LocalizationManager.t("settings.fullscreen")
	_pause_reduced_motion.text = LocalizationManager.t("settings.reduced_motion")
	_pause_language.selected = 0 if LocalizationManager.language == "pt" else 1
