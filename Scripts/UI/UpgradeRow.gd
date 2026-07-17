extends PanelContainer

var upgrade: Dictionary = {}

@onready var icon: Control = %Icon
@onready var category_label: Label = %CategoryLabel
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var effect_label: Label = %EffectLabel
@onready var level_label: Label = %LevelLabel
@onready var price_label: Label = %PriceLabel
@onready var buy_button: Button = %BuyButton

func _ready() -> void:
	_apply_style()
	_apply_buy_button_style()
	buy_button.pressed.connect(_on_buy_pressed)
	buy_button.mouse_entered.connect(func(): AudioManager.play_sfx(AudioManager.Sfx.HOVER); _set_hovered(true))
	buy_button.mouse_exited.connect(func(): _set_hovered(false))

func setup(data: Dictionary) -> void:
	upgrade = data
	refresh()

func refresh() -> void:
	if upgrade.is_empty() or not is_inside_tree():
		return
	var level: int = int(UpgradeManager.levels.get(upgrade["id"], 0))
	var price: float = UpgradeManager.get_price(upgrade)
	if icon.has_method("setup"):
		icon.call("setup", upgrade)
	category_label.text = LocalizationManager.t(UpgradeManager.get_category_key(upgrade))
	name_label.text = LocalizationManager.t(upgrade["name_key"])
	description_label.text = LocalizationManager.t(upgrade["description_key"])
	effect_label.text = UpgradeManager.get_effect_text(upgrade)
	level_label.text = "%s %d" % [LocalizationManager.t("ui.level"), level]
	price_label.text = NumberFormatter.format(price)
	buy_button.text = LocalizationManager.t("ui.buy")
	buy_button.disabled = not UpgradeManager.can_buy(upgrade)

func _on_buy_pressed() -> void:
	if UpgradeManager.buy(upgrade["id"]):
		_pulse()

func _set_hovered(is_hovered: bool) -> void:
	var target: Vector2 = Vector2(1.015, 1.015) if is_hovered else Vector2.ONE
	create_tween().tween_property(self, "scale", target, 0.1)

func _pulse() -> void:
	scale = Vector2(1.03, 1.03)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _apply_style() -> void:
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.075, 0.085, 0.115, 0.92)
	panel_style.border_color = Color(1.0, 0.8, 0.28, 0.16)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", panel_style)

func _apply_buy_button_style() -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.95, 0.66, 0.14, 0.95)
	normal.border_color = Color("#fff2a8")
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#facc15")
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#b7791f")
	var disabled: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.2, 0.22, 0.27, 0.8)
	disabled.border_color = Color(0.45, 0.48, 0.55, 0.35)
	buy_button.add_theme_stylebox_override("normal", normal)
	buy_button.add_theme_stylebox_override("hover", hover)
	buy_button.add_theme_stylebox_override("pressed", pressed)
	buy_button.add_theme_stylebox_override("disabled", disabled)
	buy_button.add_theme_color_override("font_color", Color("#15100a"))
	buy_button.add_theme_color_override("font_disabled_color", Color("#9ca3af"))
	buy_button.add_theme_font_size_override("font_size", 13)
