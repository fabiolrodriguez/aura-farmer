extends Node2D

const MAIN_TEXTURE_PATH: String = "res://Assets/Sprites/Character/main_character.png"
const UPGRADED_TEXTURE_PATH: String = "res://Assets/Sprites/Character/upgraded_character.png"
const GOLDEN_TEXTURE_PATH: String = "res://Assets/Sprites/Character/golden_overdrive_character.png"
const LEGENDARY_TEXTURE_PATH: String = "res://Assets/Sprites/Character/legendary_character.png"
const LEGENDARY_DRIP_TEXTURE_PATH: String = "res://Assets/Sprites/Character/legendary_drip_character.png"
const HEROIC_TEXTURE_PATH: String = "res://Assets/Sprites/Character/heroic_champion_character.png"
const COSMIC_TEXTURE_PATH: String = "res://Assets/Sprites/Character/cosmic_character.png"
const VOID_TEXTURE_PATH: String = "res://Assets/Sprites/Character/void_emperor_character.png"

var stage: Dictionary = {}
var _float_time: float = 0.0
var _orbit_angle: float = 0.0
var _base_position: Vector2 = Vector2.ZERO
var _last_click_msec: int = 0
var _stage_scale: float = 0.72

@onready var click_area: Area2D = %ClickArea
@onready var character_sprite: Sprite2D = %CharacterSprite
@onready var accessory_overlay: Node2D = %AccessoryOverlay

func _ready() -> void:
	_base_position = position
	scale = Vector2.ONE * _stage_scale
	click_area.input_event.connect(_on_input_event)
	UpgradeManager.upgrades_changed.connect(_refresh_visuals)
	set_process(true)

func _process(delta: float) -> void:
	_float_time += delta
	_orbit_angle += delta
	if bool(stage.get("float", false)) and not SettingsManager.get_setting("reduced_motion", false):
		position.y = _base_position.y + sin(_float_time * 2.0) * 10.0
	else:
		position.y = _base_position.y
	queue_redraw()

func apply_stage(new_stage: Dictionary) -> void:
	stage = new_stage
	var stage_index: int = AuraEvolutionManager.current_stage_index
	_stage_scale = float(stage.get("character_scale", 0.72))
	var primary: Color = Color(stage.get("primary_color", Color.WHITE))
	_apply_stage_texture()
	character_sprite.modulate = Color.WHITE.lerp(primary, clamp(float(stage_index) * 0.025, 0.0, 0.22))
	_refresh_accessories()
	if not SettingsManager.get_setting("reduced_motion", false):
		var tween: Tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ONE * _stage_scale, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		scale = Vector2.ONE * _stage_scale
	queue_redraw()

func _apply_stage_texture() -> void:
	var texture_path: String = _get_character_texture_path()
	var texture: Texture2D = ResourceLoader.load(texture_path) as Texture2D
	if texture != null:
		character_sprite.texture = texture

func _get_character_texture_path() -> String:
	var stage_texture: String = str(stage.get("character_texture", ""))
	if not stage_texture.is_empty():
		return stage_texture
	if _has_visual_upgrade_skin():
		return UPGRADED_TEXTURE_PATH
	return MAIN_TEXTURE_PATH

func _has_visual_upgrade_skin() -> bool:
	var visual_upgrade_ids: Array[String] = [
		"dark_glasses",
		"gold_chain",
		"expensive_sneakers"
	]
	for upgrade_id in visual_upgrade_ids:
		if int(UpgradeManager.levels.get(upgrade_id, 0)) > 0:
			return true
	return false

func _refresh_visuals() -> void:
	if not is_inside_tree():
		return
	_apply_stage_texture()
	_refresh_accessories()

func _refresh_accessories() -> void:
	if not is_inside_tree():
		return
	var texture_path: String = _get_character_texture_path()
	var is_legendary: bool = [GOLDEN_TEXTURE_PATH, LEGENDARY_TEXTURE_PATH, LEGENDARY_DRIP_TEXTURE_PATH, HEROIC_TEXTURE_PATH, COSMIC_TEXTURE_PATH, VOID_TEXTURE_PATH].has(texture_path)
	if accessory_overlay.has_method("set_legendary_skin"):
		accessory_overlay.call("set_legendary_skin", is_legendary)
	accessory_overlay.queue_redraw()

func _draw() -> void:
	var primary: Color = Color(stage.get("primary_color", Color("#93a4b8")))
	var energy: float = float(stage.get("light_energy", 0.0))
	var orbitals: int = int(stage.get("orbitals", 0))
	var aura_fill: Color = primary.darkened(0.58)
	aura_fill.a = 0.24 + energy * 0.08
	draw_circle(Vector2(0, -12), 132.0 + energy * 26.0, aura_fill, true)
	draw_arc(Vector2(0, -12), 138.0 + energy * 20.0, 0.0, TAU, 128, primary, 4.0 + energy * 2.0)
	draw_arc(Vector2(0, -12), 104.0 + energy * 12.0, 0.0, TAU, 128, primary.lerp(Color.WHITE, 0.35), 2.0 + energy)
	for i in range(orbitals):
		var angle: float = _orbit_angle * (1.0 + i * 0.04) + TAU * float(i) / max(1.0, float(orbitals))
		var radius: float = 132.0 + (i % 4) * 14.0
		var point: Vector2 = Vector2(cos(angle), sin(angle * 0.82)) * radius + Vector2(0, -12)
		draw_circle(point, 6.0 + float(i % 3), primary.lerp(Color.WHITE, 0.35), true)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_player_click(get_tree().current_scene)

func handle_player_click(effects_parent: Node) -> void:
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_click_msec < 35:
		return
	_last_click_msec = now_msec
	GameManager.click_aura(global_position, effects_parent)
	_squash()

func _squash() -> void:
	if SettingsManager.get_setting("reduced_motion", false):
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 0.88) * _stage_scale, 0.055)
	tween.tween_property(self, "scale", Vector2(0.94, 1.08) * _stage_scale, 0.075)
	tween.tween_property(self, "scale", Vector2.ONE * _stage_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
