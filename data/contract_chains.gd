class_name ContractChains
extends RefCounted



static var CHAINS: Array[Dictionary] = [
	{
		"id": "village_salvation",
		"name": "Village Salvation",
		"era": "past",
		"description": "Save the medieval village from the Warlord's forces.",
		"difficulty": "MEDIUM",
		"steps": [
			{
				"step": 0,
				"type": "RECOVER",
				"target": "Village Elder's Supplies",
				"description": "Recover the stolen supplies from the bandit camp.",
				"reward_tier": "easy",
				"objectives": ["Find the bandit camp in the forest", "Eliminate the bandits", "Recover the supplies"],
			},
			{
				"step": 1,
				"type": "PROTECT",
				"target": "Village",
				"description": "Defend the village from the Warlord's raiders.",
				"reward_tier": "medium",
				"objectives": ["Survive for 60 seconds", "Defeat at least 5 raiders"],
				"timeout": 60.0,
			},
			{
				"step": 2,
				"type": "BOSS_KILL",
				"target": "The Warlord",
				"description": "Defeat the Warlord to permanently save the village.",
				"reward_tier": "boss",
				"objectives": ["Find the Warlord's Fortress", "Defeat the Warlord"],
			},
		],
		"final_flag": "past_village_saved",
		"consequences": {
			"present": {
				"village_exists": true,
				"extra_npcs": true,
				"extra_contracts": true,
				"description": "The village exists in the present. Grateful NPCs offer help.",
			},
			"past": {
				"enemy_reduction": 3,
				"safe_zone": true,
				"description": "The village is safe. You have a place to rest.",
			},
		},
		"unlocks": ["present_village_intact"],
	},
	{
		"id": "ancient_knowledge",
		"name": "Ancient Knowledge",
		"era": "past",
		"description": "Discover the secrets of the ancient civilization.",
		"difficulty": "HARD",
		"steps": [
			{
				"step": 0,
				"type": "TRAVEL",
				"target": "Ancient Ruins",
				"description": "Navigate to the Ancient Ruins in the northern forest.",
				"reward_tier": "easy",
				"objectives": ["Reach the ruins without being detected"],
			},
			{
				"step": 1,
				"type": "RECOVER",
				"target": "Ancient Scroll",
				"description": "Recover the Ancient Scroll from the ruins.",
				"reward_tier": "medium",
				"objectives": ["Explore the ruins", "Find the scroll chamber", "Retrieve the scroll"],
			},
			{
				"step": 2,
				"type": "KILL",
				"target": "Ruins Guardian",
				"description": "Defeat the ancient guardian protecting the knowledge.",
				"reward_tier": "hard",
				"objectives": ["Defeat the Ruins Guardian"],
			},
		],
		"final_flag": "ancient_knowledge_found",
		"consequences": {
			"future": {
				"tech_level_bonus": 1,
				"new_weapons": true,
				"description": "Ancient knowledge accelerated technological development.",
			},
		},
		"unlocks": ["future_ancient_weapons"],
	},

	{
		"id": "corporate_conspiracy",
		"name": "Corporate Conspiracy",
		"era": "present",
		"description": "Uncover and stop the corporate conspiracy.",
		"difficulty": "MEDIUM",
		"steps": [
			{
				"step": 0,
				"type": "HUNT",
				"target": "Corporate Informant",
				"description": "Track down the corporate informant in the city.",
				"reward_tier": "easy",
				"objectives": ["Follow the trail", "Find the informant"],
			},
			{
				"step": 1,
				"type": "RECOVER",
				"target": "Classified Documents",
				"description": "Recover the classified documents from the corporate office.",
				"reward_tier": "medium",
				"objectives": ["Infiltrate the office", "Find the documents", "Escape"],
			},
			{
				"step": 2,
				"type": "BOSS_KILL",
				"target": "Corporate Enforcer",
				"description": "Defeat the Corporate Enforcer to expose the conspiracy.",
				"reward_tier": "boss",
				"objectives": ["Confront the Enforcer", "Defeat him"],
			},
		],
		"final_flag": "corporate_conspiracy_exposed",
		"consequences": {
			"present": {
				"corporate_weakness": true,
				"new_allies": true,
				"description": "The corporation is weakened. New allies emerge.",
			},
			"future": {
				"corporate_dominance_reduced": true,
				"description": "The corporation never achieved total dominance.",
			},
		},
		"unlocks": ["present_corporate_weakened"],
	},
	{
		"id": "street_sweeper",
		"name": "Street Sweeper",
		"era": "present",
		"description": "Clear the streets of all criminal elements.",
		"difficulty": "EASY",
		"steps": [
			{
				"step": 0,
				"type": "KILL",
				"target": "Street Thugs",
				"description": "Eliminate 5 street thugs terrorizing the area.",
				"reward_tier": "easy",
				"kill_target": 5,
				"objectives": ["Defeat 5 thugs"],
			},
			{
				"step": 1,
				"type": "KILL",
				"target": "Armed Gang",
				"description": "Eliminate the armed gang in the alley.",
				"reward_tier": "medium",
				"kill_target": 8,
				"objectives": ["Defeat 8 gang members"],
			},
		],
		"final_flag": "streets_cleared",
		"consequences": {
			"present": {
				"enemy_reduction": 2,
				"safe_zone": true,
				"description": "The streets are safer. Civilians are grateful.",
			},
		},
		"unlocks": [],
	},

	{
		"id": "technology_preservation",
		"name": "Technology Preservation",
		"era": "future",
		"description": "Preserve critical technology from the Cyber Guardian.",
		"difficulty": "HARD",
		"steps": [
			{
				"step": 0,
				"type": "TRAVEL",
				"target": "Data Center",
				"description": "Reach the Data Center through the security grid.",
				"reward_tier": "easy",
				"objectives": ["Navigate the security grid", "Reach the Data Center"],
			},
			{
				"step": 1,
				"type": "RECOVER",
				"target": "Quantum Chip",
				"description": "Recover the Quantum Chip from the guardian drones.",
				"reward_tier": "medium",
				"objectives": ["Defeat the guardian drones", "Retrieve the Quantum Chip"],
			},
			{
				"step": 2,
				"type": "BOSS_KILL",
				"target": "Cyber Guardian",
				"description": "Defeat the Cyber Guardian to secure the technology.",
				"reward_tier": "boss",
				"objectives": ["Find the Guardian's core", "Defeat the Cyber Guardian"],
			},
		],
		"final_flag": "technology_preserved",
		"consequences": {
			"future": {
				"advanced_weapons": true,
				"tech_level_bonus": 2,
				"description": "Advanced technology is preserved. New weapons available.",
			},
			"collapsed": {
				"less_destruction": true,
				"description": "The future collapse is less severe.",
			},
		},
		"unlocks": ["future_advanced_weapons"],
	},
	{
		"id": "android_liberation",
		"name": "Android Liberation",
		"era": "future",
		"description": "Free the androids from the Cyber Guardian's control.",
		"difficulty": "MEDIUM",
		"steps": [
			{
				"step": 0,
				"type": "HUNT",
				"target": "Control Node",
				"description": "Find and disable the first control node.",
				"reward_tier": "easy",
				"objectives": ["Locate the control node", "Disable it"],
			},
			{
				"step": 1,
				"type": "KILL",
				"target": "Guardian Drones",
				"description": "Defeat the guardian drones protecting the nodes.",
				"reward_tier": "medium",
				"kill_target": 6,
				"objectives": ["Defeat 6 guardian drones"],
			},
			{
				"step": 2,
				"type": "RECOVER",
				"target": "Liberation Code",
				"description": "Recover the liberation code from the central server.",
				"reward_tier": "hard",
				"objectives": ["Infiltrate the server", "Download the code"],
			},
		],
		"final_flag": "androids_liberated",
		"consequences": {
			"future": {
				"android_allies": true,
				"enemy_reduction": 3,
				"description": "Liberated androids become allies.",
			},
		},
		"unlocks": ["future_android_allies"],
	},

	{
		"id": "timeline_restoration",
		"name": "Timeline Restoration",
		"era": "collapsed",
		"description": "Restore the broken timeline by collecting temporal fragments.",
		"difficulty": "EXTREME",
		"steps": [
			{
				"step": 0,
				"type": "RECOVER",
				"target": "Temporal Fragment",
				"description": "Collect the first temporal fragment from the ruins.",
				"reward_tier": "medium",
				"objectives": ["Search the ruins", "Find the fragment"],
			},
			{
				"step": 1,
				"type": "RECOVER",
				"target": "Temporal Fragment",
				"description": "Collect the second temporal fragment from the wasteland.",
				"reward_tier": "hard",
				"objectives": ["Navigate the wasteland", "Defeat the guardians", "Find the fragment"],
			},
			{
				"step": 2,
				"type": "RECOVER",
				"target": "Temporal Fragment",
				"description": "Collect the final temporal fragment from the Time Devourer's lair.",
				"reward_tier": "hard",
				"objectives": ["Reach the Devourer's lair", "Collect the fragment"],
			},
			{
				"step": 3,
				"type": "BOSS_KILL",
				"target": "Time Devourer",
				"description": "Defeat the Time Devourer to restore the timeline.",
				"reward_tier": "boss",
				"objectives": ["Confront the Time Devourer", "Defeat it and restore the timeline"],
			},
		],
		"final_flag": "timeline_restored",
		"consequences": {
			"collapsed": {
				"reality_restored": true,
				"enemy_reduction": 5,
				"description": "Reality begins to mend. The worst dangers fade.",
			},
			"all_eras": {
				"temporal_stability": true,
				"description": "Time itself is more stable across all eras.",
			},
		},
		"unlocks": ["collapsed_timeline_restored"],
	},
	{
		"id": "scavenger_hunt",
		"name": "Scavenger's Bounty",
		"era": "collapsed",
		"description": "Help the scavengers recover essential supplies.",
		"difficulty": "MEDIUM",
		"steps": [
			{
				"step": 0,
				"type": "RECOVER",
				"target": "Medical Supplies",
				"description": "Recover medical supplies from the hospital ruins.",
				"reward_tier": "easy",
				"objectives": ["Find the hospital ruins", "Recover the supplies"],
			},
			{
				"step": 1,
				"type": "RECOVER",
				"target": "Power Cells",
				"description": "Recover power cells from the old power station.",
				"reward_tier": "medium",
				"objectives": ["Navigate to the power station", "Defeat the mutants", "Recover the cells"],
			},
		],
		"final_flag": "scavengers_helped",
		"consequences": {
			"collapsed": {
				"safe_zone": true,
				"extra_npcs": true,
				"description": "The scavengers set up a safe haven.",
			},
		},
		"unlocks": ["collapsed_safe_haven"],
	},
]


static var DYNAMIC_TEMPLATES: Array[Dictionary] = [
	{
		"pattern": "kill_progressive",
		"types": ["KILL"],
		"escalation": true,
		"base_count": 3,
		"step_increment": 2,
		"max_steps": 4,
	},
	{
		"pattern": "hunt_track",
		"types": ["HUNT", "KILL"],
		"escalation": true,
		"base_count": 1,
		"step_increment": 1,
		"max_steps": 3,
	},
	{
		"pattern": "recover_multi",
		"types": ["RECOVER"],
		"escalation": false,
		"base_count": 1,
		"step_increment": 1,
		"max_steps": 3,
	},
	{
		"pattern": "defend_assault",
		"types": ["PROTECT", "KILL"],
		"escalation": true,
		"base_count": 5,
		"step_increment": 3,
		"max_steps": 3,
	},
]


static func get_chains_for_era(era_id: String) -> Array[Dictionary]:

	var result: Array[Dictionary] = []
	for chain in CHAINS:
		if chain.get("era", "") == era_id:
			result.append(chain)
	return result

static func get_available_chains(era_id: String, world_flags: Dictionary, completed_chains: Array) -> Array[Dictionary]:

	var result: Array[Dictionary] = []
	for chain in CHAINS:
		if chain.get("era", "") != era_id:
			continue
		var chain_id: String = chain.get("id", "")
		if completed_chains.has(chain_id):
			continue
		if world_flags.get("chain_%s_started" % chain_id, false):
			continue
		result.append(chain)
	return result

static func start_chain(chain_id: String, world_flags: Dictionary) -> Dictionary:

	for chain in CHAINS:
		if chain.get("id", "") == chain_id:
			world_flags["chain_%s_started" % chain_id] = true
			world_flags["chain_%s_step" % chain_id] = 0
			var steps: Array = chain.get("steps", [])
			if steps.is_empty():
				return {}
			return steps[0]
	return {}

static func advance_chain(chain_id: String, current_step: int, world_flags: Dictionary) -> Dictionary:

	for chain in CHAINS:
		if chain.get("id", "") == chain_id:
			var steps: Array = chain.get("steps", [])
			var next_step := current_step + 1
			if next_step >= steps.size():
				world_flags["chain_%s_complete" % chain_id] = true
				world_flags["chain_%s_step" % chain_id] = next_step
				var final_flag: String = chain.get("final_flag", "")
				if final_flag != "":
					world_flags[final_flag] = true
				return {
					"complete": true,
					"chain_id": chain_id,
					"final_flag": final_flag,
					"consequences": chain.get("consequences", {}),
					"unlocks": chain.get("unlocks", []),
				}
			world_flags["chain_%s_step" % chain_id] = next_step
			return {
				"complete": false,
				"next_step": steps[next_step],
				"step": next_step,
			}
	return {}

static func get_chain_progress(chain_id: String, world_flags: Dictionary) -> Dictionary:

	var started: bool = world_flags.get("chain_%s_started" % chain_id, false)
	var completed: bool = world_flags.get("chain_%s_complete" % chain_id, false)
	var step: int = world_flags.get("chain_%s_step" % chain_id, 0)
	return {
		"started": started,
		"completed": completed,
		"current_step": step,
	}

static func generate_dynamic_chain(era_id: String, player_level: int) -> Dictionary:

	var template: Dictionary = DYNAMIC_TEMPLATES[randi() % DYNAMIC_TEMPLATES.size()]
	var pattern: String = template.get("pattern", "kill_progressive")
	var types: Array = template.get("types", ["KILL"])
	var base_count: int = template.get("base_count", 3)
	var step_inc: int = template.get("step_increment", 2)
	var max_steps: int = template.get("max_steps", 3)

	var steps: Array[Dictionary] = []
	var current_count := base_count

	for i in range(max_steps):
		var ctype: String = types[i % types.size()]
		var step: Dictionary = {
			"step": i,
			"type": ctype,
			"target": "Target",
			"description": "",
			"reward_tier": "easy" if i == 0 else ("medium" if i < max_steps - 1 else "hard"),
			"objectives": [],
		}
		match ctype:
			"KILL":
				step["kill_target"] = current_count + (player_level - 1)
				step["target"] = "Hostile Forces"
				step["description"] = "Eliminate %d hostile forces." % step["kill_target"]
				step["objectives"] = ["Defeat %d enemies" % step["kill_target"]]
			"HUNT":
				step["target"] = "High-Value Target"
				step["description"] = "Track and eliminate the high-value target."
				step["objectives"] = ["Find the target", "Eliminate them"]
			"RECOVER":
				step["target"] = "Objective Item"
				step["description"] = "Recover the objective item."
				step["objectives"] = ["Locate the item", "Retrieve it"]
			"PROTECT":
				step["target"] = "Defend Point"
				step["description"] = "Defend the location for 45 seconds."
				step["timeout"] = 45.0
				step["objectives"] = ["Survive for 45 seconds"]
			"TRAVEL":
				step["target"] = "Destination"
				step["description"] = "Reach the destination safely."
				step["objectives"] = ["Navigate to the location"]
		steps.append(step)
		current_count += step_inc

	var chain_id := "dynamic_%s_%d" % [era_id, randi()]
	return {
		"id": chain_id,
		"name": "Dynamic Operation",
		"era": era_id,
		"description": "A generated operation for %s." % era_id,
		"difficulty": "MEDIUM",
		"steps": steps,
		"final_flag": "",
		"consequences": {},
		"unlocks": [],
		"dynamic": true,
	}

static func get_all_chain_ids() -> Array[String]:
	var ids: Array[String] = []
	for chain in CHAINS:
		ids.append(chain.get("id", ""))
	return ids

static func get_chain(chain_id: String) -> Dictionary:
	for chain in CHAINS:
		if chain.get("id", "") == chain_id:
			return chain
	return {}
