extends Node

const FloatingTextScene = preload("res://Scenes/FloatingText/FloatingText.tscn")
const ParticleScene = preload("res://Scenes/Particles/ClickParticles.tscn")

func spawn_click_feedback(parent: Node, position: Vector2, amount: float) -> void:
	spawn_floating_text(parent, position + Vector2(randf_range(-24.0, 24.0), -72.0), "+" + NumberFormatter.format(amount))
	spawn_particles(parent, position)

func spawn_floating_text(parent: Node, position: Vector2, text: String) -> void:
	if parent == null:
		return
	var floating_text: Node = FloatingTextScene.instantiate()
	parent.add_child(floating_text)
	floating_text.global_position = position
	floating_text.call("setup", text)

func spawn_particles(parent: Node, position: Vector2) -> void:
	if parent == null:
		return
	var particles: Node = ParticleScene.instantiate()
	parent.add_child(particles)
	particles.global_position = position
	particles.call("burst")
