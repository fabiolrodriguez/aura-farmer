extends Node

const SteamAchievementBridge = preload("res://Scripts/Integrations/SteamAchievementBridge.gd")
const APP_ID: int = 1259394

var is_available: bool = false
var _steam_api: Object = null
var _achievement_bridge: Object = null

func _init() -> void:
	var app_id_text: String = str(APP_ID)
	OS.set_environment("SteamAppId", app_id_text)
	OS.set_environment("SteamAppID", app_id_text)
	OS.set_environment("SteamGameId", app_id_text)
	OS.set_environment("SteamGameID", app_id_text)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_steam()
	call_deferred("_register_achievement_bridge")

func _process(_delta: float) -> void:
	if not is_available:
		return
	if _steam_api == null:
		return
	if _steam_api.has_method("run_callbacks"):
		_steam_api.call("run_callbacks")

func _initialize_steam() -> void:
	if not Engine.has_singleton("Steam"):
		return
	_steam_api = Engine.get_singleton("Steam")
	if _steam_api == null:
		return
	_init_api()
	if _steam_api.has_method("isSteamRunning") and not bool(_steam_api.call("isSteamRunning")):
		return
	is_available = true
	_request_current_stats()

func _init_api() -> void:
	if _steam_api == null:
		return
	if _steam_api.has_method("steamInitEx"):
		_steam_api.call("steamInitEx")
	elif _steam_api.has_method("steamInit"):
		_steam_api.call("steamInit")

func _request_current_stats() -> void:
	if _steam_api == null:
		return
	if _steam_api.has_method("requestCurrentStats"):
		_steam_api.call("requestCurrentStats")
	elif _steam_api.has_method("requestUserStats") and _steam_api.has_method("getSteamID"):
		var steam_id: int = int(_steam_api.call("getSteamID"))
		_steam_api.call("requestUserStats", steam_id)

func _register_achievement_bridge() -> void:
	if not is_available:
		return
	_achievement_bridge = SteamAchievementBridge.new()
	_achievement_bridge.call("setup", _steam_api)
	AchievementManager.set_steam_bridge(_achievement_bridge)
