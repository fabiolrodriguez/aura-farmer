extends Node

signal aura_changed
signal generation_changed
signal prestige_changed
signal offline_progress(seconds: float, amount: float)

var aura_current: float = 0.0
var aura_total: float = 0.0
var aura_per_click: float = 1.0
var aura_per_second: float = 0.0
var global_multiplier: float = 1.0
var prestige_level: int = 0
var essence: float = 0.0
var last_offline_seconds: float = 0.0
var last_offline_amount: float = 0.0

func _ready() -> void:
	var data: Dictionary = SaveManager.load_game()
	if not data.is_empty():
		SettingsManager.apply_save_data(data.get("settings", {}))
		LocalizationManager.apply_language(SettingsManager.get_setting("language", "pt"))
		UpgradeManager.apply_save_data(data.get("upgrades", {}))
		apply_save_data(data.get("game", {}))
		AchievementManager.apply_save_data(data.get("achievements", {}))
		recalculate_generation()
		_apply_offline_progress(float(data.get("saved_at", Time.get_unix_time_from_system())))
	recalculate_generation()
	AuraEvolutionManager.update_for_total_aura(aura_total)
	AchievementManager.evaluate_all()

func _process(delta: float) -> void:
	if aura_per_second > 0.0:
		add_aura(aura_per_second * delta, false)

func click_aura(global_position: Vector2, effects_parent: Node) -> void:
	var gained: float = add_aura(aura_per_click, true)
	EffectsManager.spawn_click_feedback(effects_parent, global_position, gained)
	AudioManager.play_sfx(AudioManager.Sfx.CLICK)

func add_aura(amount: float, request_save_now: bool = true) -> float:
	var final_amount: float = amount * global_multiplier
	aura_current += final_amount
	aura_total += final_amount
	AuraEvolutionManager.update_for_total_aura(aura_total)
	aura_changed.emit()
	if request_save_now:
		SaveManager.request_save()
	return final_amount

func spend_aura(amount: float) -> bool:
	if aura_current < amount:
		return false
	aura_current -= amount
	aura_changed.emit()
	SaveManager.request_save()
	return true

func recalculate_generation() -> void:
	var prestige_multiplier: float = 1.0 + essence * 0.05
	global_multiplier = (1.0 + UpgradeManager.get_global_multiplier_bonus()) * prestige_multiplier
	aura_per_click = 1.0 + UpgradeManager.get_total_aura_per_click_bonus()
	aura_per_second = UpgradeManager.get_total_aura_per_second_bonus()
	generation_changed.emit()
	aura_changed.emit()

func can_prestige() -> bool:
	return aura_current >= 1000000.0

func prestige() -> bool:
	if not can_prestige():
		return false
	var gained_essence: float = max(1.0, floor(sqrt(aura_current / 1000000.0)))
	prestige_level += 1
	essence += gained_essence
	aura_current = 0.0
	UpgradeManager.apply_save_data({})
	recalculate_generation()
	prestige_changed.emit()
	aura_changed.emit()
	AudioManager.play_sfx(AudioManager.Sfx.PRESTIGE)
	SaveManager.request_save()
	return true

func get_save_data() -> Dictionary:
	return {
		"aura_current": aura_current,
		"aura_total": aura_total,
		"prestige_level": prestige_level,
		"essence": essence,
		"stage_id": AuraEvolutionManager.get_current_stage().get("id", "normal")
	}

func apply_save_data(data: Dictionary) -> void:
	aura_current = float(data.get("aura_current", 0.0))
	aura_total = float(data.get("aura_total", 0.0))
	prestige_level = int(data.get("prestige_level", 0))
	essence = float(data.get("essence", 0.0))
	AuraEvolutionManager.apply_stage_id(str(data.get("stage_id", "normal")))
	aura_changed.emit()
	prestige_changed.emit()

func _apply_offline_progress(saved_at: float) -> void:
	var now: float = Time.get_unix_time_from_system()
	var seconds: float = clamp(now - saved_at, 0.0, 60.0 * 60.0 * 24.0)
	if seconds < 5.0:
		return
	var gained: float = aura_per_second * seconds
	if gained <= 0.0:
		return
	var final_gain: float = add_aura(gained, false)
	last_offline_seconds = seconds
	last_offline_amount = final_gain
	offline_progress.emit(seconds, final_gain)
