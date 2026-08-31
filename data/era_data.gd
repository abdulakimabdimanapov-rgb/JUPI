extends RefCounted
class_name EraData


enum EraID { PRESENT, PAST, FUTURE, COLLAPSED }

static var ERAS: Dictionary = {
	"present": {
		"id": "present",
		"name": "PRESENT",
		"full_name": "The Present Day",
		"description": "Modern city district. Rain-slicked streets, neon signs, and shadowy alleys.",
		"danger": "LOW",
		"recommended_level": 1,
		"discovered": true,
		"bg_color": Color(0.04, 0.03, 0.06),
		"ground_color": Color(0.18, 0.18, 0.20),
		"wall_color": Color(0.42, 0.32, 0.28),
		"accent_color": Color(0.85, 0.65, 0.25),
		"neon_color": Color(0.9, 0.25, 0.35),
		"lighting": "electric",
		"ambient": "rain, city noise, distant sirens",
		"enemies": ["guard", "fast", "heavy", "dumbler"],
		"enemy_hp_mult": 1.0,
		"enemy_dmg_mult": 1.0,
		"enemy_speed_mult": 1.0,
		"loot_mult": 1.0,
		"xp_mult": 1.0,
		"npcs": [
			{"name": "Trader", "color": Color(0.7, 0.6, 0.2), "dialogue": "Welcome! Browse my wares."},
			{"name": "Informant", "color": Color(0.4, 0.55, 0.75), "dialogue": "I heard something about a man named Harlan."},
			{"name": "Citizen", "color": Color(0.5, 0.55, 0.55), "dialogue": "This city never sleeps. Too many shadows."},
		],
		"contract_pool": ["contract_001", "contract_003", "contract_004", "contract_005"],
		"unlock_condition": "",
		"music_profile": "modern_dark",
	},
	"past": {
		"id": "past",
		"name": "PAST",
		"full_name": "The Iron Century",
		"description": "Medieval village under threat. Cobblestone roads, torchlit buildings, armed soldiers.",
		"danger": "MEDIUM",
		"recommended_level": 3,
		"discovered": false,
		"bg_color": Color(0.06, 0.04, 0.03),
		"ground_color": Color(0.25, 0.22, 0.18),
		"wall_color": Color(0.45, 0.35, 0.25),
		"accent_color": Color(0.75, 0.6, 0.3),
		"neon_color": Color(0.9, 0.7, 0.2),
		"lighting": "candlelight",
		"ambient": "wind, distant bells, crackling fire",
		"enemies": ["soldier", "hunter", "heavy_knight", "sniper"],
		"enemy_hp_mult": 1.2,
		"enemy_dmg_mult": 1.1,
		"enemy_speed_mult": 0.9,
		"loot_mult": 0.8,
		"xp_mult": 1.3,
		"npcs": [
			{"name": "Merchant", "color": Color(0.6, 0.5, 0.3), "dialogue": "Fine goods from the southern provinces!"},
			{"name": "Guard Captain", "color": Color(0.5, 0.4, 0.35), "dialogue": "The village needs protection. Will you help?"},
			{"name": "Elder", "color": Color(0.55, 0.5, 0.45), "dialogue": "Dark times have befallen us."},
		],
		"contract_pool": ["past_001", "past_002"],
		"unlock_condition": "complete_any_contract",
		"music_profile": "medieval_dark",
	},
	"future": {
		"id": "future",
		"name": "FUTURE",
		"full_name": "The Bleeding Edge",
		"description": "Near-future cyberpunk district. Holographic signs, drones, android enforcers.",
		"danger": "HIGH",
		"recommended_level": 5,
		"discovered": false,
		"bg_color": Color(0.02, 0.03, 0.06),
		"ground_color": Color(0.12, 0.14, 0.20),
		"wall_color": Color(0.18, 0.22, 0.35),
		"accent_color": Color(0.2, 0.6, 0.9),
		"neon_color": Color(0.0, 0.8, 1.0),
		"lighting": "neon",
		"ambient": "hum of machines, electronic pulse, distant drones",
		"enemies": ["drone", "android", "plasma_guard", "mage"],
		"enemy_hp_mult": 1.5,
		"enemy_dmg_mult": 1.4,
		"enemy_speed_mult": 1.2,
		"loot_mult": 1.5,
		"xp_mult": 1.5,
		"npcs": [
			{"name": "Engineer", "color": Color(0.3, 0.5, 0.8), "dialogue": "The temporal grid is destabilizing."},
			{"name": "Scientist", "color": Color(0.6, 0.7, 0.8), "dialogue": "Be careful with the time streams."},
			{"name": "Informant", "color": Color(0.4, 0.6, 0.5), "dialogue": "Androids patrol the north sector. Avoid them."},
		],
		"contract_pool": ["future_001", "future_002"],
		"unlock_condition": "player_level_5",
		"music_profile": "synth_dark",
	},
	"collapsed": {
		"id": "collapsed",
		"name": "COLLAPSED",
		"full_name": "The Last Dawn",
		"description": "Destroyed future. Ruined buildings, mutated creatures, rare technology.",
		"danger": "EXTREME",
		"recommended_level": 8,
		"discovered": false,
		"bg_color": Color(0.05, 0.02, 0.02),
		"ground_color": Color(0.15, 0.12, 0.10),
		"wall_color": Color(0.35, 0.25, 0.20),
		"accent_color": Color(0.8, 0.3, 0.2),
		"neon_color": Color(0.6, 0.15, 0.1),
		"lighting": "dim_red",
		"ambient": "wind through ruins, distant roars, crackling energy",
		"enemies": ["mutant", "rogue_machine", "elite_hunter", "dumbler", "mage"],
		"enemy_hp_mult": 2.0,
		"enemy_dmg_mult": 1.8,
		"enemy_speed_mult": 1.1,
		"loot_mult": 2.0,
		"xp_mult": 2.0,
		"npcs": [
			{"name": "Survivor", "color": Color(0.5, 0.4, 0.35), "dialogue": "You're alive? Most aren't, out here."},
			{"name": "Scavenger", "color": Color(0.45, 0.4, 0.45), "dialogue": "Found some tech in the ruins. Interested?"},
		],
		"contract_pool": ["collapsed_001", "collapsed_002"],
		"unlock_condition": "complete_3_contracts",
		"music_profile": "ambient_dark",
	},
}

static func get_era(id: String) -> Dictionary:
	return ERAS.get(id, ERAS["present"]).duplicate(true)

static func get_all_eras() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ERAS:
		result.append(ERAS[id])
	return result

static func get_unlocked_eras(unlocked_ids: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ERAS:
		if unlocked_ids.has(id) or ERAS[id].get("discovered", false):
			result.append(ERAS[id])
	return result

static func can_unlock(era_id: String, player_level: int, completed_contracts: int, world_flags: Dictionary) -> bool:
	var era: Dictionary = ERAS.get(era_id, {})
	if era.is_empty():
		return false
	var condition: String = era.get("unlock_condition", "")
	if condition == "":
		return true
	match condition:
		"complete_any_contract":
			return completed_contracts > 0
		"player_level_5":
			return player_level >= 5
		"complete_3_contracts":
			return completed_contracts >= 3
	return true

static func get_enemies_for_era(era_id: String) -> Array[String]:
	var era: Dictionary = ERAS.get(era_id, ERAS["present"])
	var enemies: Array = era.get("enemies", ["guard"])
	var result: Array[String] = []
	for e in enemies:
		result.append(e)
	return result

static func get_npcs_for_era(era_id: String) -> Array[Dictionary]:
	var era: Dictionary = ERAS.get(era_id, ERAS["present"])
	var npcs: Array = era.get("npcs", [])
	var result: Array[Dictionary] = []
	for n in npcs:
		result.append(n)
	return result

static func get_contracts_for_era(era_id: String) -> Array[String]:
	var era: Dictionary = ERAS.get(era_id, ERAS["present"])
	var contracts: Array = era.get("contract_pool", [])
	var result: Array[String] = []
	for c in contracts:
		result.append(c)
	return result

static func apply_era_modifiers(base_hp: float, base_dmg: float, era_id: String) -> Dictionary:
	var era: Dictionary = ERAS.get(era_id, ERAS["present"])
	return {
		"hp": base_hp * era.get("enemy_hp_mult", 1.0),
		"damage": base_dmg * era.get("enemy_dmg_mult", 1.0),
		"speed_mult": era.get("enemy_speed_mult", 1.0),
		"loot_mult": era.get("loot_mult", 1.0),
		"xp_mult": era.get("xp_mult", 1.0),
	}
