extends Node

signal save_loaded(data: Dictionary)
signal save_written

const SAVE_PATH: String = "user://aura_farmer_save.json"

var _save_requested: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if _save_requested:
		_save_requested = false
		save_game()

func request_save() -> void:
	_save_requested = true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	save_loaded.emit(parsed)
	return parsed

func save_game() -> void:
	var data: Dictionary = {
		"game": GameManager.get_save_data(),
		"upgrades": UpgradeManager.get_save_data(),
		"achievements": AchievementManager.get_save_data(),
		"settings": SettingsManager.get_save_data(),
		"saved_at": Time.get_unix_time_from_system()
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	save_written.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
