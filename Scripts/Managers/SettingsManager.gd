extends Node

signal setting_changed(key: String, value)

const SettingsData = preload("res://Resources/settings_data.gd")

var _settings: Dictionary = SettingsData.get_defaults().duplicate(true)

func _ready() -> void:
	_apply_fullscreen(bool(_settings.get("fullscreen", false)))

func apply_save_data(data: Dictionary) -> void:
	for key in data.keys():
		_settings[key] = data[key]
		setting_changed.emit(key, data[key])
	_apply_fullscreen(bool(_settings.get("fullscreen", false)))

func get_save_data() -> Dictionary:
	return _settings.duplicate(true)

func get_setting(key: String, default_value = null):
	return _settings.get(key, default_value)

func set_setting(key: String, value) -> void:
	_settings[key] = value
	if key == "fullscreen":
		_apply_fullscreen(bool(value))
	setting_changed.emit(key, value)
	SaveManager.request_save()

func _apply_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
