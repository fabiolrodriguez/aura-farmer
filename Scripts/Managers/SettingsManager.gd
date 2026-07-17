extends Node

signal setting_changed(key: String, value)

const SettingsData = preload("res://Resources/settings_data.gd")

var _settings: Dictionary = SettingsData.get_defaults().duplicate(true)

func apply_save_data(data: Dictionary) -> void:
	for key in data.keys():
		_settings[key] = data[key]
		setting_changed.emit(key, data[key])

func get_save_data() -> Dictionary:
	return _settings.duplicate(true)

func get_setting(key: String, default_value = null):
	return _settings.get(key, default_value)

func set_setting(key: String, value) -> void:
	_settings[key] = value
	setting_changed.emit(key, value)
	SaveManager.request_save()
