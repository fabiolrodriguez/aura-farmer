extends Node

const SteamAchievementBridge = preload("res://Scripts/Integrations/SteamAchievementBridge.gd")
const APP_ID: int = 1259394
const STEAM_INIT_OK: int = 0
const STEAM_RESULT_OK: int = 1

var is_available: bool = false
var stats_ready: bool = false
var _steam_api: Object = null
var _achievement_bridge: Object = null
var _steam_initialized: bool = false

func _init() -> void:
	var app_id_text: String = str(APP_ID)
	OS.set_environment("SteamAppId", app_id_text)
	OS.set_environment("SteamAppID", app_id_text)
	OS.set_environment("SteamGameId", app_id_text)
	OS.set_environment("SteamGameID", app_id_text)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_steam()

func _process(_delta: float) -> void:
	if not _steam_initialized or _steam_api == null:
		return
	if _steam_api.has_method("run_callbacks"):
		_steam_api.call("run_callbacks")

func _initialize_steam() -> void:
	if not Engine.has_singleton("Steam"):
		print("SteamManager: GodotSteam is not available; continuing without Steam.")
		return
	_steam_api = Engine.get_singleton("Steam")
	if _steam_api == null:
		push_warning("SteamManager: Steam singleton could not be acquired.")
		return
	_connect_callbacks()
	var init_result: Variant = _init_api()
	if not _did_init_succeed(init_result):
		var message: String = _get_init_message(init_result)
		print("SteamManager: Steam initialization unavailable (%s); continuing without Steam." % message)
		return
	_steam_initialized = true
	is_available = true
	print("SteamManager: Steam initialized for AppID %d." % APP_ID)
	if not _request_current_stats():
		push_warning("SteamManager: failed to request current user stats.")

func _connect_callbacks() -> void:
	if _steam_api.has_signal("user_stats_received"):
		var callback := Callable(self, "_on_user_stats_received")
		if not _steam_api.is_connected("user_stats_received", callback):
			_steam_api.connect("user_stats_received", callback)
	if _steam_api.has_signal("user_stats_stored"):
		var callback := Callable(self, "_on_user_stats_stored")
		if not _steam_api.is_connected("user_stats_stored", callback):
			_steam_api.connect("user_stats_stored", callback)

func _init_api() -> Variant:
	if _steam_api == null:
		return {}
	if _steam_api.has_method("steamInitEx"):
		return _steam_api.call("steamInitEx")
	if _steam_api.has_method("steamInit"):
		return _steam_api.call("steamInit")
	return {}

func _did_init_succeed(result: Variant) -> bool:
	if result is Dictionary:
		return int(result.get("status", -1)) == STEAM_INIT_OK
	if result is bool:
		return bool(result)
	return false

func _get_init_message(result: Variant) -> String:
	if result is Dictionary:
		return str(result.get("verbal", "status %s" % result.get("status", "unknown")))
	return str(result)

func _request_current_stats() -> bool:
	if _steam_api == null:
		return false
	if _steam_api.has_method("requestCurrentStats"):
		return bool(_steam_api.call("requestCurrentStats"))
	if _steam_api.has_method("requestUserStats") and _steam_api.has_method("getSteamID"):
		var steam_id: int = int(_steam_api.call("getSteamID"))
		return bool(_steam_api.call("requestUserStats", steam_id))
	return false

func _register_achievement_bridge() -> void:
	if not is_available or not stats_ready:
		return
	if _achievement_bridge != null:
		return
	_achievement_bridge = SteamAchievementBridge.new()
	_achievement_bridge.call("setup", _steam_api)
	AchievementManager.set_steam_bridge(_achievement_bridge)

func _on_user_stats_received(game_id: int, result: int, _user_id: int) -> void:
	if game_id != APP_ID:
		return
	if result != STEAM_RESULT_OK:
		push_warning("SteamManager: user stats request failed with result %d." % result)
		return
	stats_ready = true
	print("SteamManager: user stats loaded; achievements are ready.")
	call_deferred("_register_achievement_bridge")

func _on_user_stats_stored(game_id: int, result: int) -> void:
	if game_id != APP_ID:
		return
	if result != STEAM_RESULT_OK:
		push_warning("SteamManager: storing user stats failed with result %d." % result)

func _exit_tree() -> void:
	if not _steam_initialized or _steam_api == null:
		return
	if _steam_api.has_method("steamShutdown"):
		_steam_api.call("steamShutdown")
	_steam_initialized = false
	is_available = false
	stats_ready = false
