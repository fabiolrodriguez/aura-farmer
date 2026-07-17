extends PanelContainer

const UpgradeRowScene = preload("res://Scenes/Shop/UpgradeRow.tscn")

@onready var rows_container: VBoxContainer = %Rows
@onready var title_label: Label = %ShopTitle
@onready var subtitle_label: Label = %ShopSubtitle
@onready var filter_tabs: HBoxContainer = %FilterTabs

var _active_filter: String = "all"

func _ready() -> void:
	_apply_panel_style()
	GameManager.aura_changed.connect(_refresh)
	UpgradeManager.upgrades_changed.connect(_rebuild)
	LocalizationManager.language_changed.connect(_rebuild)
	_rebuild()

func _rebuild() -> void:
	title_label.text = LocalizationManager.t("ui.shop")
	subtitle_label.text = LocalizationManager.t("ui.shop_subtitle")
	_rebuild_filters()
	for child in rows_container.get_children():
		child.queue_free()
	for upgrade in UpgradeManager.upgrades:
		if not _should_show_upgrade(upgrade):
			continue
		var row: Node = UpgradeRowScene.instantiate()
		rows_container.add_child(row)
		row.call("setup", upgrade)
	_refresh()

func _rebuild_filters() -> void:
	for child in filter_tabs.get_children():
		child.queue_free()
	_add_filter_button("all", LocalizationManager.t("ui.all"))
	_add_filter_button("click", LocalizationManager.t("upgrade.category.click"))
	_add_filter_button("auto", LocalizationManager.t("upgrade.category.auto"))
	_add_filter_button("multiplier", LocalizationManager.t("upgrade.category.multiplier"))

func _add_filter_button(filter_id: String, label: String) -> void:
	var button: Button = Button.new()
	button.text = label
	button.toggle_mode = true
	button.button_pressed = _active_filter == filter_id
	button.custom_minimum_size = Vector2(64, 30)
	button.add_theme_font_size_override("font_size", 11)
	_apply_filter_button_style(button)
	button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER))
	button.pressed.connect(func(): _set_filter(filter_id))
	filter_tabs.add_child(button)

func _set_filter(filter_id: String) -> void:
	_active_filter = filter_id
	_rebuild()

func _should_show_upgrade(upgrade: Dictionary) -> bool:
	if _active_filter == "all":
		return true
	return str(upgrade.get("category", "click")) == _active_filter

func _apply_panel_style() -> void:
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.045, 0.07, 0.9)
	panel_style.border_color = Color(0.95, 0.72, 0.25, 0.32)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", panel_style)

func _apply_filter_button_style(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.095, 0.13, 0.9)
	normal.border_color = Color(0.8, 0.86, 1.0, 0.12)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 7
	normal.corner_radius_top_right = 7
	normal.corner_radius_bottom_left = 7
	normal.corner_radius_bottom_right = 7
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.border_color = Color(1.0, 0.78, 0.25, 0.6)
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.95, 0.66, 0.14, 0.95)
	pressed.border_color = Color("#facc15")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", Color("#dbeafe"))
	button.add_theme_color_override("font_pressed_color", Color("#15100a"))

func _refresh() -> void:
	for row in rows_container.get_children():
		if row.has_method("refresh"):
			row.refresh()
