extends RefCounted

var _steam_api: Object = null

func setup(steam_api: Object) -> void:
	_steam_api = steam_api

func unlock_achievement(steam_id: String) -> bool:
	if _steam_api == null:
		return false
	if steam_id.is_empty():
		return false
	if not _steam_api.has_method("setAchievement"):
		return false
	if not bool(_steam_api.call("setAchievement", steam_id)):
		push_warning("SteamAchievementBridge: failed to set achievement %s." % steam_id)
		return false
	if not _steam_api.has_method("storeStats"):
		return true
	if not bool(_steam_api.call("storeStats")):
		push_warning("SteamAchievementBridge: failed to store achievement %s." % steam_id)
		return false
	return true
