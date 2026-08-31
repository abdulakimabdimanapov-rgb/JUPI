extends RefCounted
class_name WeaponDataNew

static var NEW_WEAPONS = {
	"plasma_rifle": {
		"id": "plasma_rifle",
		"name": "Plasma Rifle",
		"description": "High-tech energy weapon. Slow but powerful.",
		"damage": 35.0,
		"attack_speed": 0.6,
		"range": 100.0,
		"crit_chance": 0.1,
		"crit_multiplier": 2.5,
		"knock_force": 120.0,
		"price": 800,
		"rarity": "rare",
	},
	"shadow_dagger": {
		"id": "shadow_dagger",
		"name": "Shadow Dagger",
		"description": "Fast, dark blade. High crit chance.",
		"damage": 12.0,
		"attack_speed": 1.5,
		"range": 16.0,
		"crit_chance": 0.3,
		"crit_multiplier": 3.0,
		"knock_force": 40.0,
		"price": 500,
		"rarity": "uncommon",
	},
	"rocket_launcher": {
		"id": "rocket_launcher",
		"name": "Rocket Launcher",
		"description": "Explosive damage. Slow reload.",
		"damage": 60.0,
		"attack_speed": 0.3,
		"range": 150.0,
		"crit_chance": 0.05,
		"crit_multiplier": 2.0,
		"knock_force": 200.0,
		"price": 1200,
		"rarity": "epic",
	},
	"energy_whip": {
		"id": "energy_whip",
		"name": "Energy Whip",
		"description": "Long range melee. Hits multiple enemies.",
		"damage": 22.0,
		"attack_speed": 0.8,
		"range": 40.0,
		"crit_chance": 0.15,
		"crit_multiplier": 2.0,
		"knock_force": 100.0,
		"price": 600,
		"rarity": "uncommon",
	},
	"ancient_sword": {
		"id": "ancient_sword",
		"name": "Ancient Sword",
		"description": "Relic from the past. Balanced stats.",
		"damage": 25.0,
		"attack_speed": 1.0,
		"range": 24.0,
		"crit_chance": 0.2,
		"crit_multiplier": 2.5,
		"knock_force": 90.0,
		"price": 700,
		"rarity": "rare",
	},
	"crystal_staff": {
		"id": "crystal_staff",
		"name": "Crystal Staff",
		"description": "Magic weapon. Heals on critical hit.",
		"damage": 18.0,
		"attack_speed": 0.9,
		"range": 60.0,
		"crit_chance": 0.25,
		"crit_multiplier": 2.0,
		"knock_force": 60.0,
		"price": 900,
		"rarity": "rare",
	},
	"vampire_blade": {
		"id": "vampire_blade",
		"name": "Vampire Blade",
		"description": "Steals life from enemies.",
		"damage": 20.0,
		"attack_speed": 1.2,
		"range": 20.0,
		"crit_chance": 0.15,
		"crit_multiplier": 2.0,
		"knock_force": 70.0,
		"price": 1000,
		"rarity": "epic",
	},
	"thunder_hammer": {
		"id": "thunder_hammer",
		"name": "Thunder Hammer",
		"description": "Stuns enemies on hit.",
		"damage": 40.0,
		"attack_speed": 0.5,
		"range": 22.0,
		"crit_chance": 0.1,
		"crit_multiplier": 2.0,
		"knock_force": 150.0,
		"price": 1100,
		"rarity": "epic",
	},
}

static var NEW_ARMOR = {
	"nano_suit_mk2": {
		"id": "nano_suit_mk2",
		"name": "Nano Suit MK2",
		"description": "Advanced armor. 40% damage reduction.",
		"reduction": 0.40,
		"price": 900,
		"rarity": "rare",
	},
	"phoenix_plate": {
		"id": "phoenix_plate",
		"name": "Phoenix Plate",
		"description": "Revives once per fight with 50% HP.",
		"reduction": 0.25,
		"revive": true,
		"price": 1500,
		"rarity": "epic",
	},
	"shadow_cloak": {
		"id": "shadow_cloak",
		"name": "Shadow Cloak",
		"description": "Increases dodge chance.",
		"reduction": 0.15,
		"dodge_bonus": 0.2,
		"price": 600,
		"rarity": "uncommon",
	},
	"titan_armor": {
		"id": "titan_armor",
		"name": "Titan Armor",
		"description": "Heavy armor. 50% reduction but slower.",
		"reduction": 0.50,
		"speed_penalty": 0.8,
		"price": 1200,
		"rarity": "epic",
	},
	"chrono_shield": {
		"id": "chrono_shield",
		"name": "Chrono Shield",
		"description": "Time-based defense. Absorbs damage over time.",
		"reduction": 0.30,
		"shield_regen": 2.0,
		"price": 1000,
		"rarity": "rare",
	},
}

static func get_weapon(id):
	return NEW_WEAPONS.get(id, {})

static func get_armor(id):
	return NEW_ARMOR.get(id, {})

static func get_all_weapons():
	return NEW_WEAPONS.duplicate()

static func get_all_armor():
	return NEW_ARMOR.duplicate()

static func get_weapons_by_rarity(rarity):
	var result = []
	for id in NEW_WEAPONS:
		if NEW_WEAPONS[id].get("rarity") == rarity:
			result.append(NEW_WEAPONS[id])
	return result

static func get_armor_by_rarity(rarity):
	var result = []
	for id in NEW_ARMOR:
		if NEW_ARMOR[id].get("rarity") == rarity:
			result.append(NEW_ARMOR[id])
	return result
