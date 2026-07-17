extends Node

signal upgrades_changed
signal upgrade_purchased(upgrade_id: String)

const UpgradeData = preload("res://Resources/upgrades_data.gd")

var upgrades: Array[Dictionary] = []
var levels: Dictionary = {}

func _ready() -> void:
	upgrades = UpgradeData.get_upgrades()
	upgrades.sort_custom(_sort_by_base_price)
	for upgrade in upgrades:
		levels[upgrade["id"]] = 0

func _sort_by_base_price(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("base_price", 0.0)) < float(b.get("base_price", 0.0))

func apply_save_data(data: Dictionary) -> void:
	levels.clear()
	for upgrade in upgrades:
		levels[upgrade["id"]] = int(data.get(upgrade["id"], 0))
	upgrades_changed.emit()

func get_save_data() -> Dictionary:
	return levels.duplicate(true)

func get_price(upgrade: Dictionary) -> float:
	var level: int = int(levels.get(upgrade["id"], 0))
	return float(upgrade["base_price"]) * pow(float(upgrade["price_growth"]), level)

func can_buy(upgrade: Dictionary) -> bool:
	return GameManager.aura_current >= get_price(upgrade)

func get_category_key(upgrade: Dictionary) -> String:
	var category: String = str(upgrade.get("category", "click"))
	return "upgrade.category.%s" % category

func get_effect_text(upgrade: Dictionary) -> String:
	var parts: Array[String] = []
	var click_bonus: float = float(upgrade.get("aura_per_click", 0.0))
	var auto_bonus: float = float(upgrade.get("aura_per_second", 0.0))
	var multiplier_bonus: float = float(upgrade.get("global_multiplier", 0.0))
	if click_bonus > 0.0:
		parts.append(LocalizationManager.t("upgrade.effect.click", {"value": NumberFormatter.format(click_bonus)}))
	if auto_bonus > 0.0:
		parts.append(LocalizationManager.t("upgrade.effect.auto", {"value": NumberFormatter.format(auto_bonus)}))
	if multiplier_bonus > 0.0:
		parts.append(LocalizationManager.t("upgrade.effect.multiplier", {"value": NumberFormatter.format(multiplier_bonus * 100.0)}))
	if parts.is_empty():
		return LocalizationManager.t("upgrade.effect.flavor")
	return " | ".join(parts)

func buy(upgrade_id: String) -> bool:
	var upgrade: Dictionary = get_upgrade(upgrade_id)
	if upgrade.is_empty():
		return false
	var price: float = get_price(upgrade)
	if not GameManager.spend_aura(price):
		return false
	levels[upgrade_id] = int(levels.get(upgrade_id, 0)) + 1
	GameManager.recalculate_generation()
	upgrade_purchased.emit(upgrade_id)
	upgrades_changed.emit()
	AudioManager.play_sfx(AudioManager.Sfx.BUY)
	SaveManager.request_save()
	return true

func get_upgrade(upgrade_id: String) -> Dictionary:
	for upgrade in upgrades:
		if upgrade["id"] == upgrade_id:
			return upgrade
	return {}

func get_total_aura_per_click_bonus() -> float:
	var total: float = 0.0
	for upgrade in upgrades:
		total += float(upgrade.get("aura_per_click", 0.0)) * int(levels.get(upgrade["id"], 0))
	return total

func get_total_aura_per_second_bonus() -> float:
	var total: float = 0.0
	for upgrade in upgrades:
		total += float(upgrade.get("aura_per_second", 0.0)) * int(levels.get(upgrade["id"], 0))
	return total

func get_global_multiplier_bonus() -> float:
	var total: float = 0.0
	for upgrade in upgrades:
		total += float(upgrade.get("global_multiplier", 0.0)) * int(levels.get(upgrade["id"], 0))
	return total
