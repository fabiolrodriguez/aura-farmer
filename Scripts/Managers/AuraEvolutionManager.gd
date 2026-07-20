extends Node

signal stage_changed(stage: Dictionary, index: int)

const StageData = preload("res://Resources/aura_stages_data.gd")

var stages: Array[Dictionary] = []
var current_stage_index: int = 0

func _ready() -> void:
	_ensure_stages()

func update_for_total_aura(total_aura: float) -> void:
	_set_stage_for_total_aura(total_aura, false, true)

func validate_for_total_aura(total_aura: float) -> void:
	_set_stage_for_total_aura(total_aura, false, false)

func emit_current_stage() -> void:
	_ensure_stages()
	stage_changed.emit(get_current_stage(), current_stage_index)

func _set_stage_for_total_aura(total_aura: float, emit_if_same: bool, play_sound: bool) -> void:
	_ensure_stages()
	var next_index: int = 0
	for i in range(stages.size()):
		if total_aura >= float(stages[i]["threshold"]):
			next_index = i
	var changed: bool = next_index != current_stage_index
	if changed or emit_if_same:
		current_stage_index = next_index
		stage_changed.emit(get_current_stage(), current_stage_index)
		if changed and play_sound:
			AudioManager.play_sfx(AudioManager.Sfx.NEW_STAGE)

func get_current_stage() -> Dictionary:
	_ensure_stages()
	if stages.is_empty():
		return {}
	return stages[clamp(current_stage_index, 0, stages.size() - 1)]

func get_next_stage() -> Dictionary:
	_ensure_stages()
	if current_stage_index + 1 >= stages.size():
		return {}
	return stages[current_stage_index + 1]

func apply_stage_id(stage_id: String) -> void:
	_ensure_stages()
	for i in range(stages.size()):
		if stages[i]["id"] == stage_id:
			current_stage_index = i
			stage_changed.emit(get_current_stage(), current_stage_index)
			return

func _ensure_stages() -> void:
	if stages.is_empty():
		stages = StageData.get_stages()
