extends Node

signal stage_changed(stage: Dictionary, index: int)

const StageData = preload("res://Resources/aura_stages_data.gd")

var stages: Array[Dictionary] = []
var current_stage_index: int = 0

func _ready() -> void:
	stages = StageData.get_stages()

func update_for_total_aura(total_aura: float) -> void:
	var next_index: int = 0
	for i in range(stages.size()):
		if total_aura >= float(stages[i]["threshold"]):
			next_index = i
	if next_index != current_stage_index:
		current_stage_index = next_index
		stage_changed.emit(get_current_stage(), current_stage_index)
		AudioManager.play_sfx(AudioManager.Sfx.NEW_STAGE)

func get_current_stage() -> Dictionary:
	if stages.is_empty():
		return {}
	return stages[clamp(current_stage_index, 0, stages.size() - 1)]

func get_next_stage() -> Dictionary:
	if current_stage_index + 1 >= stages.size():
		return {}
	return stages[current_stage_index + 1]

func apply_stage_id(stage_id: String) -> void:
	for i in range(stages.size()):
		if stages[i]["id"] == stage_id:
			current_stage_index = i
			stage_changed.emit(get_current_stage(), current_stage_index)
			return
