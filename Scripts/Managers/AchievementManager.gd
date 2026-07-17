extends Node

signal achievement_unlocked(achievement: Dictionary)
signal achievements_changed

const AchievementData = preload("res://Resources/achievements_data.gd")

var achievements: Array[Dictionary] = []
var unlocked: Dictionary = {}
var _steam_bridge: Object = null

func _ready() -> void:
	achievements = AchievementData.get_achievements()
	call_deferred("_connect_game_signals")

func _connect_game_signals() -> void:
	GameManager.aura_changed.connect(evaluate_all)
	GameManager.generation_changed.connect(evaluate_all)
	GameManager.prestige_changed.connect(evaluate_all)
	UpgradeManager.upgrade_purchased.connect(_on_upgrade_purchased)
	AuraEvolutionManager.stage_changed.connect(_on_stage_changed)
	evaluate_all()

func set_steam_bridge(bridge: Object) -> void:
	_steam_bridge = bridge
	for achievement in achievements:
		if is_unlocked(str(achievement["id"])):
			_notify_backend(achievement)

func apply_save_data(data: Dictionary) -> void:
	unlocked.clear()
	var unlocked_ids: Array = data.get("unlocked", []) as Array
	for id_value in unlocked_ids:
		unlocked[str(id_value)] = true
	achievements_changed.emit()
	call_deferred("evaluate_all")

func get_save_data() -> Dictionary:
	return {
		"unlocked": unlocked.keys()
	}

func is_unlocked(achievement_id: String) -> bool:
	return bool(unlocked.get(achievement_id, false))

func get_unlocked_count() -> int:
	return unlocked.size()

func get_completion_ratio() -> float:
	if achievements.is_empty():
		return 0.0
	return float(get_unlocked_count()) / float(achievements.size())

func evaluate_all() -> void:
	for achievement in achievements:
		if _is_condition_met(achievement):
			unlock(str(achievement["id"]))

func unlock(achievement_id: String) -> void:
	if is_unlocked(achievement_id):
		return
	var achievement: Dictionary = get_achievement(achievement_id)
	if achievement.is_empty():
		return
	unlocked[achievement_id] = true
	_notify_backend(achievement)
	achievement_unlocked.emit(achievement)
	achievements_changed.emit()
	SaveManager.request_save()

func get_achievement(achievement_id: String) -> Dictionary:
	for achievement in achievements:
		if str(achievement["id"]) == achievement_id:
			return achievement
	return {}

func _is_condition_met(achievement: Dictionary) -> bool:
	var metric: String = str(achievement.get("metric", ""))
	var target: float = float(achievement.get("target", 0.0))
	if metric == "aura_total":
		return GameManager.aura_total >= target
	if metric == "clicks_total":
		return float(GameManager.clicks_total) >= target
	if metric == "upgrade_count":
		return float(_get_total_upgrade_levels()) >= target
	if metric == "specific_upgrade_level":
		return float(UpgradeManager.levels.get(str(achievement.get("upgrade_id", "")), 0)) >= target
	if metric == "max_upgrade_level":
		return float(_get_max_upgrade_level()) >= target
	if metric == "category_level":
		return float(_get_category_upgrade_levels(str(achievement.get("category", "")))) >= target
	if metric == "aura_per_second":
		return GameManager.aura_per_second >= target
	if metric == "aura_per_click":
		return GameManager.aura_per_click * GameManager.global_multiplier >= target
	if metric == "essence":
		return GameManager.essence >= target
	if metric == "prestige_level":
		return float(GameManager.prestige_level) >= target
	if metric == "stage_index":
		return float(AuraEvolutionManager.current_stage_index) >= target
	if metric == "platinum":
		return get_unlocked_count() >= achievements.size() - 1
	return false

func _get_total_upgrade_levels() -> int:
	var total: int = 0
	for upgrade_id in UpgradeManager.levels.keys():
		total += int(UpgradeManager.levels.get(upgrade_id, 0))
	return total

func _get_max_upgrade_level() -> int:
	var highest: int = 0
	for upgrade_id in UpgradeManager.levels.keys():
		highest = max(highest, int(UpgradeManager.levels.get(upgrade_id, 0)))
	return highest

func _get_category_upgrade_levels(category: String) -> int:
	var total: int = 0
	for upgrade in UpgradeManager.upgrades:
		if str(upgrade.get("category", "")) == category:
			total += int(UpgradeManager.levels.get(str(upgrade["id"]), 0))
	return total

func _notify_backend(achievement: Dictionary) -> void:
	if _steam_bridge == null:
		return
	if not _steam_bridge.has_method("unlock_achievement"):
		return
	_steam_bridge.call("unlock_achievement", str(achievement.get("steam_id", achievement.get("id", ""))))

func _on_upgrade_purchased(_upgrade_id: String) -> void:
	evaluate_all()

func _on_stage_changed(_stage: Dictionary, _index: int) -> void:
	evaluate_all()
