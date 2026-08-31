class_name LootTable
extends RefCounted



static var LOOT_ITEMS: Dictionary = {
	"health_small": {
		"name": "Small Health Pack",
		"description": "Restores 25 HP.",
		"type": "consumable",
		"effect": "heal",
		"value": 25.0,
		"rarity": "common",
		"icon_color": Color(0.8, 0.2, 0.2),
	},
	"energy_small": {
		"name": "Small Energy Pack",
		"description": "Restores 25 Energy.",
		"type": "consumable",
		"effect": "energy",
		"value": 25.0,
		"rarity": "common",
		"icon_color": Color(0.2, 0.5, 0.9),
	},
	"credits_low": {
		"name": "Credit Chip",
		"description": "Contains 25-75 credits.",
		"type": "currency",
		"effect": "credits",
		"value_min": 25,
		"value_max": 75,
		"rarity": "common",
		"icon_color": Color(0.9, 0.8, 0.2),
	},
	"ammo_pack": {
		"name": "Ammo Pack",
		"description": "Restores 5 ammo.",
		"type": "consumable",
		"effect": "ammo",
		"value": 5,
		"rarity": "common",
		"icon_color": Color(0.7, 0.6, 0.3),
	},
	"health_medium": {
		"name": "Health Potion",
		"description": "Restores 50 HP.",
		"type": "consumable",
		"effect": "heal",
		"value": 50.0,
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.15, 0.15),
	},
	"energy_medium": {
		"name": "Energy Potion",
		"description": "Restores 50 Energy.",
		"type": "consumable",
		"effect": "energy",
		"value": 50.0,
		"rarity": "uncommon",
		"icon_color": Color(0.15, 0.4, 0.95),
	},
	"credits_medium": {
		"name": "Credit Cache",
		"description": "Contains 100-200 credits.",
		"type": "currency",
		"effect": "credits",
		"value_min": 100,
		"value_max": 200,
		"rarity": "uncommon",
		"icon_color": Color(0.95, 0.85, 0.15),
	},
	"chrono_shard": {
		"name": "Chrono Shard",
		"description": "A fragment of crystallized time. Valuable.",
		"type": "quest_item",
		"effect": "none",
		"value": 0,
		"rarity": "uncommon",
		"icon_color": Color(0.4, 0.8, 1.0),
	},
	"temporal_key": {
		"name": "Temporal Key",
		"description": "Opens sealed time portals.",
		"type": "quest_item",
		"effect": "none",
		"value": 0,
		"rarity": "uncommon",
		"icon_color": Color(0.6, 0.3, 0.9),
	},
	"health_large": {
		"name": "Health Elixir",
		"description": "Restores 100 HP.",
		"type": "consumable",
		"effect": "heal",
		"value": 100.0,
		"rarity": "rare",
		"icon_color": Color(1.0, 0.1, 0.1),
	},
	"energy_large": {
		"name": "Energy Elixir",
		"description": "Restores 100 Energy.",
		"type": "consumable",
		"effect": "energy",
		"value": 100.0,
		"rarity": "rare",
		"icon_color": Color(0.1, 0.3, 1.0),
	},
	"credits_high": {
		"name": "Credit Vault",
		"description": "Contains 300-500 credits.",
		"type": "currency",
		"effect": "credits",
		"value_min": 300,
		"value_max": 500,
		"rarity": "rare",
		"icon_color": Color(1.0, 0.9, 0.1),
	},
	"damage_booster": {
		"name": "Damage Booster",
		"description": "+10% damage for 60 seconds.",
		"type": "buff",
		"effect": "damage_boost",
		"value": 0.1,
		"duration": 60.0,
		"rarity": "rare",
		"icon_color": Color(0.9, 0.3, 0.1),
	},
	"speed_booster": {
		"name": "Speed Booster",
		"description": "+20% movement speed for 30 seconds.",
		"type": "buff",
		"effect": "speed_boost",
		"value": 0.2,
		"duration": 30.0,
		"rarity": "rare",
		"icon_color": Color(0.2, 0.9, 0.5),
	},
	"shield_module": {
		"name": "Shield Module",
		"description": "Grants 50 temporary HP.",
		"type": "buff",
		"effect": "temp_hp",
		"value": 50.0,
		"rarity": "rare",
		"icon_color": Color(0.3, 0.7, 0.9),
	},
	"health_full": {
		"name": "Full Restore",
		"description": "Fully restores HP and Energy.",
		"type": "consumable",
		"effect": "full_restore",
		"value": 0,
		"rarity": "epic",
		"icon_color": Color(1.0, 0.2, 0.8),
	},
	"chrono_crystal": {
		"name": "Chrono Crystal",
		"description": "A rare crystal of temporal energy. Extremely valuable.",
		"type": "currency",
		"effect": "credits",
		"value_min": 500,
		"value_max": 1000,
		"rarity": "epic",
		"icon_color": Color(0.5, 0.9, 1.0),
	},
	"crit_enhancer": {
		"name": "Critical Enhancer",
		"description": "+15% crit chance for 120 seconds.",
		"type": "buff",
		"effect": "crit_boost",
		"value": 0.15,
		"duration": 120.0,
		"rarity": "epic",
		"icon_color": Color(0.9, 0.5, 0.1),
	},
	"temporal_surge": {
		"name": "Temporal Surge",
		"description": "Doubles all stats for 30 seconds.",
		"type": "buff",
		"effect": "all_boost",
		"value": 1.0,
		"duration": 30.0,
		"rarity": "legendary",
		"icon_color": Color(1.0, 0.8, 0.0),
	},
	"enforcer_badge": {
		"name": "Enforcer Badge",
		"description": "Proof of defeating the Corporate Enforcer.",
		"type": "unique",
		"effect": "none",
		"value": 0,
		"rarity": "legendary",
		"icon_color": Color(0.8, 0.6, 0.2),
	},
	"ancient_blade": {
		"name": "Ancient Blade",
		"description": "A blade forged in the medieval past.",
		"type": "unique",
		"effect": "none",
		"value": 0,
		"rarity": "legendary",
		"icon_color": Color(0.7, 0.5, 0.3),
	},
	"pulse_core": {
		"name": "Pulse Core",
		"description": "The heart of the Cyber Guardian.",
		"type": "unique",
		"effect": "none",
		"value": 0,
		"rarity": "legendary",
		"icon_color": Color(0.2, 0.8, 1.0),
	},
	"chrono_shard_legendary": {
		"name": "Chrono Shard (Legendary)",
		"description": "A perfect shard of crystallized time.",
		"type": "unique",
		"effect": "none",
		"value": 0,
		"rarity": "legendary",
		"icon_color": Color(0.9, 0.7, 1.0),
	},
}


static var RARITY_WEIGHTS: Dictionary = {
	"common": 45.0,
	"uncommon": 30.0,
	"rare": 15.0,
	"epic": 7.0,
	"legendary": 3.0,
}

static var RARITY_COLORS: Dictionary = {
	"common": Color(0.6, 0.6, 0.6),
	"uncommon": Color(0.2, 0.8, 0.3),
	"rare": Color(0.2, 0.5, 1.0),
	"epic": Color(0.7, 0.2, 0.9),
	"legendary": Color(1.0, 0.7, 0.1),
}


static var BOSS_LOOT: Dictionary = {
	"corporate_enforcer": {
		"guaranteed": ["enforcer_badge"],
		"random_count": [2, 4],
		"pool": ["health_medium", "energy_medium", "credits_medium", "chrono_shard", "damage_booster", "speed_booster", "shield_module"],
		"bonus_credits": 400,
		"bonus_xp": 200,
	},
	"warlord": {
		"guaranteed": ["ancient_blade"],
		"random_count": [2, 4],
		"pool": ["health_medium", "health_large", "credits_medium", "chrono_shard", "temporal_key", "damage_booster", "shield_module"],
		"bonus_credits": 600,
		"bonus_xp": 350,
	},
	"cyber_guardian": {
		"guaranteed": ["pulse_core"],
		"random_count": [2, 5],
		"pool": ["energy_medium", "energy_large", "credits_high", "chrono_shard", "speed_booster", "crit_enhancer", "shield_module"],
		"bonus_credits": 700,
		"bonus_xp": 400,
	},
	"time_devourer": {
		"guaranteed": ["chrono_shard_legendary"],
		"random_count": [3, 5],
		"pool": ["health_full", "credits_high", "chrono_crystal", "temporal_surge", "crit_enhancer", "damage_booster", "speed_booster"],
		"bonus_credits": 1000,
		"bonus_xp": 600,
	},
}

static var ENEMY_LOOT: Dictionary = {
	"guard": {
		"drop_chance": 0.3,
		"pool": ["health_small", "energy_small", "credits_low", "ammo_pack"],
		"max_drops": 1,
	},
	"fast": {
		"drop_chance": 0.25,
		"pool": ["health_small", "credits_low", "ammo_pack"],
		"max_drops": 1,
	},
	"heavy": {
		"drop_chance": 0.5,
		"pool": ["health_small", "health_medium", "energy_small", "credits_low", "credits_medium", "ammo_pack"],
		"max_drops": 2,
	},
	"soldier": {
		"drop_chance": 0.35,
		"pool": ["health_small", "energy_small", "credits_low", "ammo_pack"],
		"max_drops": 1,
	},
	"hunter": {
		"drop_chance": 0.3,
		"pool": ["health_small", "credits_low", "temporal_key"],
		"max_drops": 1,
	},
	"drone": {
		"drop_chance": 0.4,
		"pool": ["energy_small", "energy_medium", "credits_low", "chrono_shard"],
		"max_drops": 1,
	},
	"android": {
		"drop_chance": 0.45,
		"pool": ["energy_medium", "credits_medium", "chrono_shard", "speed_booster"],
		"max_drops": 2,
	},
	"mutant": {
		"drop_chance": 0.5,
		"pool": ["health_medium", "health_large", "credits_medium", "chrono_shard", "temporal_key"],
		"max_drops": 2,
	},
	"elite": {
		"drop_chance": 0.6,
		"pool": ["health_large", "credits_high", "chrono_shard", "damage_booster", "shield_module"],
		"max_drops": 2,
	},
}

static var OBJECT_LOOT: Dictionary = {
	"crate": {
		"drop_chance": 0.6,
		"pool": ["health_small", "energy_small", "credits_low", "ammo_pack"],
		"max_drops": 1,
	},
	"barrel": {
		"drop_chance": 0.4,
		"pool": ["health_small", "credits_low"],
		"max_drops": 1,
	},
	"dumpster": {
		"drop_chance": 0.7,
		"pool": ["health_small", "energy_small", "credits_low", "credits_medium", "ammo_pack"],
		"max_drops": 2,
	},
	"chest": {
		"drop_chance": 1.0,
		"pool": ["health_medium", "energy_medium", "credits_medium", "chrono_shard", "damage_booster", "speed_booster"],
		"max_drops": 3,
	},
}


static func roll_boss_loot(boss_id: String) -> Array[Dictionary]:

	var table: Dictionary = BOSS_LOOT.get(boss_id, {})
	if table.is_empty():
		return []

	var result: Array[Dictionary] = []

	for item_id in table.get("guaranteed", []):
		var item: Dictionary = LOOT_ITEMS.get(item_id, {}).duplicate()
		if not item.is_empty():
			item["id"] = item_id
			result.append(item)

	var pool: Array = table.get("pool", [])
	var min_count: int = table.get("random_count", [1, 3])[0]
	var max_count: int = table.get("random_count", [1, 3])[1]
	var count := randi_range(min_count, max_count)

	for i in range(count):
		if pool.is_empty():
			break
		var item_id: String = pool[randi() % pool.size()]
		var item: Dictionary = LOOT_ITEMS.get(item_id, {}).duplicate()
		if not item.is_empty():
			item["id"] = item_id
			if item.get("type") == "currency":
				var min_val: int = item.get("value_min", 0)
				var max_val: int = item.get("value_max", min_val)
				item["value"] = randi_range(min_val, max_val)
			result.append(item)

	return result

static func roll_enemy_loot(enemy_type: String) -> Array[Dictionary]:

	var table: Dictionary = ENEMY_LOOT.get(enemy_type, {})
	if table.is_empty():
		return []

	var drop_chance: float = table.get("drop_chance", 0.3)
	if randf() > drop_chance:
		return []

	var result: Array[Dictionary] = []
	var pool: Array = table.get("pool", [])
	var max_drops: int = table.get("max_drops", 1)
	var count := randi_range(1, max_drops)

	for i in range(count):
		if pool.is_empty():
			break
		var item_id: String = pool[randi() % pool.size()]
		var item: Dictionary = LOOT_ITEMS.get(item_id, {}).duplicate()
		if not item.is_empty():
			item["id"] = item_id
			if item.get("type") == "currency":
				var min_val: int = item.get("value_min", 0)
				var max_val: int = item.get("value_max", min_val)
				item["value"] = randi_range(min_val, max_val)
			result.append(item)

	return result

static func roll_object_loot(object_type: String) -> Array[Dictionary]:

	var table: Dictionary = OBJECT_LOOT.get(object_type, {})
	if table.is_empty():
		return []

	var drop_chance: float = table.get("drop_chance", 0.5)
	if randf() > drop_chance:
		return []

	var result: Array[Dictionary] = []
	var pool: Array = table.get("pool", [])
	var max_drops: int = table.get("max_drops", 1)
	var count := randi_range(1, max_drops)

	for i in range(count):
		if pool.is_empty():
			break
		var item_id: String = pool[randi() % pool.size()]
		var item: Dictionary = LOOT_ITEMS.get(item_id, {}).duplicate()
		if not item.is_empty():
			item["id"] = item_id
			if item.get("type") == "currency":
				var min_val: int = item.get("value_min", 0)
				var max_val: int = item.get("value_max", min_val)
				item["value"] = randi_range(min_val, max_val)
			result.append(item)

	return result

static func apply_loot(item: Dictionary, game_manager: Node) -> void:

	if item.is_empty():
		return
	var item_type: String = item.get("type", "")
	var effect: String = item.get("effect", "")
	match item_type:
		"consumable":
			match effect:
				"heal":
					game_manager.player_hp = minf(game_manager.player_hp + item.get("value", 0), game_manager.player_max_hp)
				"energy":
					game_manager.player_energy = minf(game_manager.player_energy + item.get("value", 0), 100.0)
				"full_restore":
					game_manager.player_hp = game_manager.player_max_hp
					game_manager.player_energy = 100.0
				"ammo":
					pass
		"currency":
			var credits: int = item.get("value", 0)
			if credits > 0:
				game_manager.add_currency(credits)
		"quest_item":
			var flag: String = "has_%s" % item.get("id", "")
			game_manager.set_world_flag(flag, true)
		"buff":
			pass
		"unique":
			var flag: String = "has_%s" % item.get("id", "")
			game_manager.set_world_flag(flag, true)
	game_manager.collect_loot(item.get("id", "unknown"), item.get("value", 1.0))

static func get_item(item_id: String) -> Dictionary:
	return LOOT_ITEMS.get(item_id, {}).duplicate()

static func get_rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, Color.WHITE)

static func get_rarity_weight(rarity: String) -> float:
	return RARITY_WEIGHTS.get(rarity, 1.0)

static func get_all_item_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in LOOT_ITEMS.keys():
		ids.append(key)
	return ids

static func get_items_by_rarity(rarity: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in LOOT_ITEMS:
		var item: Dictionary = LOOT_ITEMS[item_id]
		if item.get("rarity", "") == rarity:
			var copy := item.duplicate()
			copy["id"] = item_id
			result.append(copy)
	return result
