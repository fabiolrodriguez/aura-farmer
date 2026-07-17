extends RefCounted

static func get_defaults() -> Dictionary:
	return {
		"language": "pt",
		"master_volume": 0.8,
		"music_volume": 0.5,
		"sfx_volume": 0.85,
		"music_enabled": true,
		"fullscreen": false,
		"reduced_motion": false
	}
