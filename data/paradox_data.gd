extends RefCounted
class_name ParadoxData


signal paradox_triggered(event_id: String)
signal world_state_changed(location: String, new_state: String)

static var PARADOX_EVENTS: Array[Dictionary] = [
	{
		"id": "save_village",
		"name": "Save the Village",
		"source_era": "past",
		"target_era": "present",
		"trigger": "complete_contract_protect_village",
		"world_flag": "past_village_saved",
		"consequences": {
			"present": {
				"village_location": "SAVED",
				"extra_npc": true,
				"extra_contracts": true,
				"description": "The village exists in the present. grateful NPCs offer help.",
			},
			"past": {
				"village_location": "PROTECTED",
				"enemy_reduction": 2,
				"description": "The village is safe. The Warlord's forces are weakened.",
			},
		},
	},
	{
		"id": "destroy_factory",
		"name": "Destroy the Factory",
		"source_era": "past",
		"target_era": "future",
		"trigger": "defeat_boss_warlord",
		"world_flag": "past_factory_destroyed",
		"consequences": {
			"future": {
				"factory_location": "ABANDONED",
				"new_enemy_spawn": true,
				"technology_unlocked": false,
				"description": "The factory was never built. Technology development stalled.",
			},
			"past": {
				"factory_location": "DESTROYED",
				"warlord_weakened": true,
				"description": "The factory is in ruins. The Warlord loses his weapon source.",
			},
		},
	},
	{
		"id": "kill_inventor",
		"name": "Kill the Inventor",
		"source_era": "past",
		"target_era": "future",
		"trigger": "complete_contract_kill_inventor",
		"world_flag": "inventor_killed",
		"consequences": {
			"future": {
				"technology_level": -1,
				"weapons_changed": true,
				"new_boss": false,
				"description": "Key technology was never invented. The future is less advanced.",
			},
		},
	},
	{
		"id": "save_technology",
		"name": "Preserve the Technology",
		"source_era": "past",
		"target_era": "future",
		"trigger": "complete_contract_preserve_tech",
		"world_flag": "technology_preserved",
		"consequences": {
			"future": {
				"technology_level": 1,
				"new_weapons": true,
				"description": "Ancient technology survived. The future has advanced weapons.",
			},
		},
	},
	{
		"id": "fail_city_defense",
		"name": "City Falls",
		"source_era": "present",
		"target_era": "collapsed",
		"trigger": "fail_contract_defend_city",
		"world_flag": "city_fell",
		"consequences": {
			"collapsed": {
				"city_condition": "DESTROYED",
				"extra_enemies": 3,
				"description": "The city was not defended. It fell to the collapse.",
			},
		},
	},
	{
		"id": "defeat_time_devourer",
		"name": "Defeat the Time Devourer",
		"source_era": "collapsed",
		"target_era": "all",
		"trigger": "defeat_boss_time_devourer",
		"world_flag": "time_devourer_defeated",
		"consequences": {
			"present": {"timeline_stabilized": true, "description": "Time flows normally again."},
			"past": {"timeline_stabilized": true, "description": "The past is no longer corrupted."},
			"future": {"timeline_stabilized": true, "description": "The future is restored."},
		},
	},
	{
		"id": "save_scientist",
		"name": "Save the Scientist",
		"source_era": "future",
		"target_era": "collapsed",
		"trigger": "complete_contract_save_scientist",
		"world_flag": "scientist_saved",
		"consequences": {
			"collapsed": {
				"research_available": true,
				"new_crafting": true,
				"description": "The scientist's research survived. New technology is available.",
			},
		},
	},
]

static var LOCATIONS := {
	"village": {"normal": "Standing", "saved": "Thriving", "destroyed": "Ruins"},
	"factory": {"normal": "Operational", "destroyed": "Abandoned", "saved": "Upgraded"},
	"city": {"normal": "Normal", "defended": "Fortified", "fell": "Destroyed"},
	"lab": {"normal": "Sealed", "unlocked": "Accessible", "destroyed": "Wrecked"},
	"tower": {"normal": "Standing", "stabilized": "Repaired", "collapsed": "Ruins"},
}

static func get_paradox_events() -> Array[Dictionary]:
	return PARADOX_EVENTS.duplicate(true)

static func get_event_by_id(event_id: String) -> Dictionary:
	for event in PARADOX_EVENTS:
		if event["id"] == event_id:
			return event.duplicate(true)
	return {}

static func get_events_for_trigger(trigger: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in PARADOX_EVENTS:
		if event.get("trigger", "") == trigger:
			result.append(event)
	return result

static func check_trigger(trigger: String, world_flags: Dictionary) -> Array[Dictionary]:

	var result: Array[Dictionary] = []
	for event in PARADOX_EVENTS:
		if event.get("trigger", "") == trigger:
			if not world_flags.get(event["world_flag"], false):
				result.append(event)
	return result

static func apply_paradox(event_id: String, world_flags: Dictionary) -> Dictionary:

	var event := get_event_by_id(event_id)
	if event.is_empty():
		return {}
	var flag: String = event.get("world_flag", "")
	var consequences: Dictionary = event.get("consequences", {})
	return {"flag": flag, "consequences": consequences}

static func get_location_state(location: String, world_flags: Dictionary) -> String:

	var loc_data: Dictionary = LOCATIONS.get(location, {})
	if loc_data.is_empty():
		return "unknown"

	if world_flags.get("past_%s_saved" % location, false):
		return loc_data.get("saved", "saved")
	elif world_flags.get("%s_destroyed" % location, false) or world_flags.get("%s_fell" % location, false):
		return loc_data.get("destroyed", "destroyed")
	elif world_flags.get("%s_unlocked" % location, false):
		return loc_data.get("unlocked", "unlocked")

	return loc_data.get("normal", "normal")

static func get_all_location_states(world_flags: Dictionary) -> Dictionary:

	var result := {}
	for location in LOCATIONS:
		result[location] = get_location_state(location, world_flags)
	return result
