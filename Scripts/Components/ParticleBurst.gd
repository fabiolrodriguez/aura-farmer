extends CPUParticles2D

func burst() -> void:
	emitting = false
	restart()
	emitting = true
	await get_tree().create_timer(lifetime + 0.2).timeout
	queue_free()
