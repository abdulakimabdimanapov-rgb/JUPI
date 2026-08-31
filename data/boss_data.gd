extends RefCounted
class_name BossData


var id: String = ""
var display_name: String = ""
var era: String = "present"
var max_hp: float = 500.0
var damage: float = 25.0
var movement_speed: float = 40.0
var attack_range: float = 24.0
var attack_cooldown: float = 1.5
var detection_range: float = 200.0
var xp_reward: float = 200.0
var currency_reward: int = 500
var loot_table: Dictionary = {}
var phases: Array[Dictionary] = []
var attack_types: Array[String] = []
var difficulty: int = 1

static var BOSSES: Dictionary = {
	"corporate_enforcer": {
		"id": "corporate_enforcer",
		"name": "Corporate Enforcer",
		"era": "present",
		"description": "Elite corporate security officer with advanced weaponry.",
		"max_hp": 400.0,
		"damage": 20.0,
		"movement_speed": 50.0,
		"attack_range": 22.0,
		"attack_cooldown": 1.2,
		"detection_range": 200.0,
		"xp_reward": 200.0,
		"currency_reward": 400,
		"difficulty": 2,
		"attack_types": ["melee", "ranged", "dash"],
		"phases": [
			{"name": "Standard", "hp_threshold": 0.6, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "ranged"]},
			{"name": "Enraged", "hp_threshold": 0.3, "speed_mult": 1.3, "damage_mult": 1.4, "attacks": ["melee", "ranged", "dash"]},
			{"name": "Desperate", "hp_threshold": 0.0, "speed_mult": 1.6, "damage_mult": 1.8, "attacks": ["melee", "ranged", "dash"]},
		],
		"loot": {"currency": 400, "xp": 200, "unique_item": "enforcer_badge"},
	},
	"warlord": {
		"id": "warlord",
		"name": "The Warlord",
		"era": "past",
		"description": "Ancient warlord with brute strength and loyal soldiers.",
		"max_hp": 600.0,
		"damage": 30.0,
		"movement_speed": 35.0,
		"attack_range": 28.0,
		"attack_cooldown": 1.8,
		"detection_range": 180.0,
		"xp_reward": 350.0,
		"currency_reward": 600,
		"difficulty": 3,
		"attack_types": ["melee", "summon", "area"],
		"phases": [
			{"name": "Warlord", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "summon"]},
			{"name": "Berserker", "hp_threshold": 0.25, "speed_mult": 1.4, "damage_mult": 1.5, "attacks": ["melee", "area", "summon"]},
			{"name": "Final Stand", "hp_threshold": 0.0, "speed_mult": 1.8, "damage_mult": 2.0, "attacks": ["melee", "area"]},
		],
		"loot": {"currency": 600, "xp": 350, "unique_item": "ancient_blade"},
	},
	"cyber_guardian": {
		"id": "cyber_guardian",
		"name": "Cyber Guardian",
		"era": "future",
		"description": "Advanced AI security system with drone support.",
		"max_hp": 500.0,
		"damage": 25.0,
		"movement_speed": 45.0,
		"attack_range": 100.0,
		"attack_cooldown": 1.0,
		"detection_range": 250.0,
		"xp_reward": 400.0,
		"currency_reward": 700,
		"difficulty": 4,
		"attack_types": ["ranged", "area", "summon"],
		"phases": [
			{"name": "Guardian", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["ranged", "summon"]},
			{"name": "Overcharged", "hp_threshold": 0.25, "speed_mult": 1.2, "damage_mult": 1.5, "attacks": ["ranged", "area", "summon"]},
			{"name": "Self-Destruct", "hp_threshold": 0.0, "speed_mult": 1.5, "damage_mult": 2.0, "attacks": ["area", "ranged"]},
		],
		"loot": {"currency": 700, "xp": 400, "unique_item": "pulse_core"},
	},
	"time_devourer": {
		"id": "time_devourer",
		"name": "Time Devourer",
		"era": "collapsed",
		"description": "Entity that feeds on temporal energy. Reality warps around it.",
		"max_hp": 800.0,
		"damage": 35.0,
		"movement_speed": 40.0,
		"attack_range": 30.0,
		"attack_cooldown": 1.5,
		"detection_range": 300.0,
		"xp_reward": 600.0,
		"currency_reward": 1000,
		"difficulty": 5,
		"attack_types": ["melee", "area", "special"],
		"phases": [
			{"name": "Devourer", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "area"]},
			{"name": "Ravenous", "hp_threshold": 0.25, "speed_mult": 1.3, "damage_mult": 1.6, "attacks": ["melee", "area", "special"]},
			{"name": "Chrono Collapse", "hp_threshold": 0.0, "speed_mult": 1.7, "damage_mult": 2.2, "attacks": ["area", "special"]},
		],
		"loot": {"currency": 1000, "xp": 600, "unique_item": "chrono_shard"},
	},
}

static func get_boss(id: String) -> Dictionary:
	return BOSSES.get(id, {}).duplicate(true)

static func get_boss_for_era(era_id: String) -> Dictionary:
	for boss_id in BOSSES:
		if BOSSES[boss_id].get("era", "") == era_id:
			return BOSSES[boss_id].duplicate(true)
	return {}

static func get_all_bosses() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for boss_id in BOSSES:
		result.append(BOSSES[boss_id])
	return result

static func get_phase(boss_id: String, hp_percent: float) -> Dictionary:
	var boss := get_boss(boss_id)
	var phases: Array = boss.get("phases", [])
	for phase in phases:
		if hp_percent > phase.get("hp_threshold", 0.0):
			return phase
	return phases[phases.size() - 1] if not phases.is_empty() else {}
