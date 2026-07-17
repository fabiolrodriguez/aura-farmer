extends RefCounted

var _steam_api: Object = null

func setup(steam_api: Object) -> void:
	_steam_api = steam_api

func unlock_achievement(steam_id: String) -> void:
	if _steam_api == null:
		return
	if _steam_api.has_method("setAchievement"):
		_steam_api.call("setAchievement", steam_id)
	if _steam_api.has_method("storeStats"):
		_steam_api.call("storeStats")
