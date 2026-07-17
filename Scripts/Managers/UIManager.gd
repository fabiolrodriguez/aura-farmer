extends Node

var current_game_scene: Node = null

func register_game_scene(scene: Node) -> void:
	current_game_scene = scene

func unregister_game_scene(scene: Node) -> void:
	if current_game_scene == scene:
		current_game_scene = null
