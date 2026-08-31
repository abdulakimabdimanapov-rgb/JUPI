extends RefCounted
class_name ContractGenerator


static var TEMPLATES := {
	"KILL": [
		"Eliminate %s in %s",
		"Hunt down %s",
		"Clear the area of %s",
	],
	"RECOVER": [
		"Recover %s from %s",
		"Retrieve the lost %s",
		"Find and secure %s",
	],
	"PROTECT": [
		"Protect %s for %d seconds",
		"Defend %s from attackers",
		"Guard %s against hostiles",
	],
	"HUNT": [
		"Hunt the %s",
		"Track and eliminate the %s",
		"Pursue the %s target",
	],
	"TRAVEL": [
		"Reach %s",
		"Navigate to %s",
		"Travel to %s and return",
	],
	"BOSS_KILL": [
		"Defeat the %s",
		"Eliminate the %s boss",
		"Confront and destroy the %s",
	],
}

static var ERA_TARGETS := {
	"present": {
		"enemies": ["Corporate Guard", "Armed Thug", "Security Drone"],
		"locations": ["East District", "North Block", "Main Road", "Hotel Area"],
		"items": ["Security Keycard", "Stolen Data", "Weapons Cache"],
		"npcs": ["Informant", "Civilian", "Merchant"],
	},
	"past": {
		"enemies": ["Soldier", "Mercenary", "Bandit"],
		"locations": ["Village", "Castle", "Market", "Forest Path"],
		"items": ["Ancient Scroll", "Iron Sword", "Royal Seal"],
		"npcs": ["Guard Captain", "Elder", "Blacksmith"],
	},
	"future": {
		"enemies": ["Rogue Drone", "Android Guard", "Plasma Sentry"],
		"locations": ["Tech Lab", "Data Center", "Sky Bridge", "Neon Alley"],
		"items": ["Quantum Chip", "Energy Core", "Holographic Map"],
		"npcs": ["Engineer", "Scientist", "Informant"],
	},
	"collapsed": {
		"enemies": ["Mutant", "Rogue Machine", "Scavenger Gang"],
		"locations": ["Ruins", "Underground", "Wasteland", "Collapsed Tower"],
		"items": ["Salvaged Tech", "Rare Mineral", "Survival Kit"],
		"npcs": ["Survivor", "Scavenger", "Wanderer"],
	},
}

static var REWARD_TIERS := {
	"easy": {"credits": [50, 150], "xp": [30, 80], "difficulty": "LOW"},
	"medium": {"credits": [150, 400], "xp": [80, 200], "difficulty": "MEDIUM"},
	"hard": {"credits": [400, 800], "xp": [200, 400], "difficulty": "HIGH"},
	"boss": {"credits": [500, 1500], "xp": [300, 800], "difficulty": "EXTREME"},
}

static var CONTRACT_CHAINS := [
	{
		"id": "village_chain",
		"name": "Village Protection Chain",
		"era": "past",
		"contracts": [
			{"id": "chain_1_1", "type": "RECOVER", "target": "Village Elder", "desc": "Find the Village Elder's missing supplies", "reward_tier": "easy"},
			{"id": "chain_1_2", "type": "PROTECT", "target": "Village", "desc": "Protect the village from raiders", "reward_tier": "medium"},
			{"id": "chain_1_3", "type": "BOSS_KILL", "target": "Warlord", "desc": "Defeat the Warlord threatening the village", "reward_tier": "boss"},
		],
		"final_flag": "past_village_saved",
		"unlocks": ["present_village_intact"],
	},
	{
		"id": "tech_chain",
		"name": "Technology Preservation Chain",
		"era": "future",
		"contracts": [
			{"id": "chain_2_1", "type": "TRAVEL", "target": "Data Center", "desc": "Reach the Data Center", "reward_tier": "easy"},
			{"id": "chain_2_2", "type": "RECOVER", "target": "Quantum Chip", "desc": "Recover the Quantum Chip from hostiles", "reward_tier": "medium"},
			{"id": "chain_2_3", "type": "BOSS_KILL", "target": "Cyber Guardian", "desc": "Defeat the Cyber Guardian protecting the core", "reward_tier": "boss"},
		],
		"final_flag": "technology_preserved",
		"unlocks": ["future_advanced_weapons"],
	},
]

static func generate_contract(era_id: String, player_level: int, world_flags: Dictionary, completed_count: int) -> Dictionary:

	var targets: Dictionary = ERA_TARGETS.get(era_id, ERA_TARGETS["present"])

	var tier := "easy"
	if player_level >= 8:
		tier = "hard"
	elif player_level >= 4:
		tier = "medium"

	var chain := _get_available_chain(era_id, world_flags, completed_count)
	if not chain.is_empty():
		var chain_contract := _generate_chain_contract(chain, era_id, targets)
		return chain_contract

	var contract_type: String = ["KILL", "RECOVER", "PROTECT", "HUNT", "TRAVEL"][randi() % 5]
	var template: String = TEMPLATES[contract_type][randi() % TEMPLATES[contract_type].size()]

	var target_name: String = ""
	var location: String = ""
	match contract_type:
		"KILL", "HUNT":
			target_name = targets["enemies"][randi() % targets["enemies"].size()]
			location = targets["locations"][randi() % targets["locations"].size()]
		"RECOVER":
			target_name = targets["items"][randi() % targets["items"].size()]
			location = targets["locations"][randi() % targets["locations"].size()]
		"PROTECT":
			target_name = targets["npcs"][randi() % targets["npcs"].size()]
			location = targets["locations"][randi() % targets["locations"].size()]
		"TRAVEL":
			location = targets["locations"][randi() % targets["locations"].size()]
			target_name = location

	var reward_tier: Dictionary = REWARD_TIERS[tier]
	var credits := randi_range(reward_tier["credits"][0], reward_tier["credits"][1])
	var xp := randf_range(reward_tier["xp"][0], reward_tier["xp"][1])

	return {
		"id": "generated_%d_%s" % [completed_count, era_id],
		"type": contract_type,
		"target_name": target_name,
		"target_desc": template % [target_name, location] if template.count("%s") == 2 else template % target_name,
		"era": era_id,
		"location": location,
		"threat": reward_tier["difficulty"],
		"reward": {"credits": credits, "xp": xp},
		"objectives": [_get_objective_text(contract_type, target_name, location)],
		"status": "available",
	}

static func _get_available_chain(era_id: String, world_flags: Dictionary, completed_count: int) -> Dictionary:

	for chain in CONTRACT_CHAINS:
		if chain["era"] != era_id:
			continue
		var chain_id: String = chain["id"]
		if world_flags.get("chain_%s_started" % chain_id, false):
			continue
		if completed_count >= 2:
			return chain
	return {}

static func _generate_chain_contract(chain: Dictionary, era_id: String, targets: Dictionary) -> Dictionary:

	var first: Dictionary = chain["contracts"][0]
	var tier: Dictionary = REWARD_TIERS.get(first.get("reward_tier", "easy"), REWARD_TIERS["easy"])
	var credits := randi_range(tier["credits"][0], tier["credits"][1])
	var xp := randf_range(tier["xp"][0], tier["xp"][1])

	return {
		"id": first["id"],
		"type": first["type"],
		"target_name": first.get("target", "Target"),
		"target_desc": first.get("desc", "Complete the objective"),
		"era": era_id,
		"location": targets["locations"][0] if not targets["locations"].is_empty() else "Unknown",
		"threat": tier["difficulty"],
		"reward": {"credits": credits, "xp": xp},
		"objectives": [first.get("desc", "Complete the objective")],
		"status": "available",
		"chain_id": chain["id"],
		"chain_step": 0,
	}

static func _get_objective_text(contract_type: String, target: String, location: String) -> String:
	match contract_type:
		"KILL": return "Eliminate %s in %s" % [target, location]
		"RECOVER": return "Recover %s from %s" % [target, location]
		"PROTECT": return "Protect %s in %s" % [target, location]
		"HUNT": return "Hunt the %s" % target
		"TRAVEL": return "Reach %s" % location
		"BOSS_KILL": return "Defeat the %s" % target
	return "Complete the objective"

static func advance_chain(chain_id: String, current_step: int, world_flags: Dictionary) -> Dictionary:

	var chain := {}
	for c in CONTRACT_CHAINS:
		if c["id"] == chain_id:
			chain = c
			break
	if chain.is_empty():
		return {}

	var next_step := current_step + 1
	var contracts: Array = chain.get("contracts", [])
	if next_step >= contracts.size():
		world_flags["chain_%s_complete" % chain_id] = true
		world_flags[chain.get("final_flag", "")] = true
		return {"complete": true, "flag": chain.get("final_flag", "")}

	var next: Dictionary = contracts[next_step]
	return {
		"complete": false,
		"next_contract": next,
		"step": next_step,
	}

static func get_chains_for_era(era_id: String) -> Array[Dictionary]:

	var result: Array[Dictionary] = []
	for chain in CONTRACT_CHAINS:
		if chain["era"] == era_id:
			result.append(chain)
	return result
