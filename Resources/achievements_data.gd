extends RefCounted

static func get_achievements() -> Array[Dictionary]:
	return [
		{"id": "first_click", "steam_id": "AF_FIRST_CLICK", "name_key": "achievement.first_click.name", "description_key": "achievement.first_click.description", "icon": "✦", "metric": "aura_total", "target": 1.0},
		{"id": "aura_1k", "steam_id": "AF_AURA_1K", "name_key": "achievement.aura_1k.name", "description_key": "achievement.aura_1k.description", "icon": "◆", "metric": "aura_total", "target": 1000.0},
		{"id": "aura_1m", "steam_id": "AF_AURA_1M", "name_key": "achievement.aura_1m.name", "description_key": "achievement.aura_1m.description", "icon": "★", "metric": "aura_total", "target": 1000000.0},
		{"id": "aura_50m", "steam_id": "AF_ANCIENT_CHAMPION", "name_key": "achievement.aura_50m.name", "description_key": "achievement.aura_50m.description", "icon": "☀", "metric": "aura_total", "target": 50000000.0},
		{"id": "first_upgrade", "steam_id": "AF_FIRST_UPGRADE", "name_key": "achievement.first_upgrade.name", "description_key": "achievement.first_upgrade.description", "icon": "$", "metric": "upgrade_count", "target": 1.0},
		{"id": "auto_farm", "steam_id": "AF_AUTO_FARM", "name_key": "achievement.auto_farm.name", "description_key": "achievement.auto_farm.description", "icon": "⚙", "metric": "aura_per_second", "target": 1.0},
		{"id": "first_rebirth", "steam_id": "AF_FIRST_REBIRTH", "name_key": "achievement.first_rebirth.name", "description_key": "achievement.first_rebirth.description", "icon": "∞", "metric": "prestige_level", "target": 1.0},
		{"id": "legendary_skin", "steam_id": "AF_LEGENDARY_SKIN", "name_key": "achievement.legendary_skin.name", "description_key": "achievement.legendary_skin.description", "icon": "♛", "metric": "stage_index", "target": 7.0},
		{"id": "cosmic_form", "steam_id": "AF_COSMIC_FORM", "name_key": "achievement.cosmic_form.name", "description_key": "achievement.cosmic_form.description", "icon": "✺", "metric": "stage_index", "target": 12.0}
	]
