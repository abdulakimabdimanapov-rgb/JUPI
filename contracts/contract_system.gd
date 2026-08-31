extends RefCounted
class_name ContractSystem



static var CONTRACTS := [
	{
		"id": "contract_001",
		"type": "KILL_TARGET",
		"target_name": "Viktor Harlan",
		"target_desc": "Former military engineer. Selling temporal disruption tech to warlords.",
		"era": "industrial",
		"country": "Valdoria",
		"city": "Ironhaven",
		"location": "Harlan Workshop, East District",
		"threat": "medium",
		"objectives": [
			"Infiltrate Ironhaven during the Smoke Era",
			"Locate Harlan's workshop",
			"Observe his daily schedule",
			"Eliminate or neutralize Harlan",
		],
		"optional_objectives": [
			"Retrieve Harlan's research notes",
			"Complete without killing guards",
		],
		"reward": {
			"credits": 500,
			"xp": 150.0,
			"equipment": "industrial_lockpick",
			"clock_memory": "harlan_connection",
		},
		"consequences": [
			{
				"event": "harlan_neutralized",
				"world_change": "industrial_valdoria_peace",
				"description": "Without Harlan's weapons, the Valdorian civil war ends 20 years early.",
			},
		],
		"target_schedule": [
			{"time": "06:00", "location": "Residence", "activity": "sleeping"},
			{"time": "08:00", "location": "Workshop", "activity": "working"},
			{"time": "12:00", "location": "East Market", "activity": "eating"},
			{"time": "18:00", "location": "Residence", "activity": "dinner"},
		],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_002",
		"type": "KILL_TARGET",
		"target_name": "The Clockmaker",
		"target_desc": "Mysterious figure who created time-manipulation artifacts. Origin unknown.",
		"era": "far_future",
		"country": "The Nexus",
		"city": "Chronos Prime",
		"location": "The Clocktower, Central Spire",
		"threat": "extreme",
		"objectives": [
			"Reach Chronos Prime in the Last Dawn era",
			"Find the Clocktower",
			"Confront the Clockmaker",
			"Learn the truth about your clock",
		],
		"optional_objectives": [
			"Survive the confrontation",
			"Preserve the timeline",
		],
		"reward": {
			"credits": 2000,
			"xp": 500.0,
			"equipment": "temporal_crown",
			"clock_memory": "clockmaker_revelation",
		},
		"consequences": [
			{
				"event": "clockmaker_encountered",
				"world_change": "far_future_nexus_shift",
				"description": "The Nexus timeline fractures. New possibilities emerge.",
			},
		],
		"target_schedule": [
			{"time": "00:00", "location": "The Clocktower", "activity": "always present"},
		],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_003",
		"type": "KILL_N",
		"target_name": "Clear the Streets",
		"target_desc": "The city district is overrun with hostiles. Eliminate 5 guards to secure the area.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "City District",
		"threat": "low",
		"objectives": ["Eliminate 5 guards in the city district"],
		"optional_objectives": ["Complete without taking damage"],
		"reward": {"credits": 200, "xp": 80.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 5,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_004",
		"type": "SURVIVE",
		"target_name": "Hold the Line",
		"target_desc": "A swarm is approaching. Survive for 60 seconds.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "City District — Main Road",
		"threat": "high",
		"objectives": ["Survive for 60 seconds against incoming hostiles"],
		"optional_objectives": ["Kill at least 3 enemies during survival"],
		"reward": {"credits": 350, "xp": 120.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 60.0,
		"kill_target": 0,
		"survive_seconds": 60.0,
	},
	{
		"id": "contract_005",
		"type": "REACH",
		"target_name": "Rendezvous Point",
		"target_desc": "A contact is waiting at the clock tower. Reach the marked location.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "Clock Tower, Center-North",
		"threat": "low",
		"objectives": ["Reach the clock tower location"],
		"optional_objectives": ["Reach without alerting any guards"],
		"reward": {"credits": 150, "xp": 60.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
	# === NEW CONTRACTS ===
	{
		"id": "contract_006",
		"type": "KILL_N",
		"target_name": "Mage Hunt",
		"target_desc": "Dark mages are channeling forbidden temporal magic. Eliminate 3 mages to stop the ritual.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "City District — Arcane Quarter",
		"threat": "high",
		"objectives": ["Eliminate 3 mages in the city"],
		"optional_objectives": ["Complete without taking magic damage"],
		"reward": {"credits": 400, "xp": 150.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 3,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_007",
		"type": "KILL_N",
		"target_name": "Sniper Elimination",
		"target_desc": "Enemy snipers have set up positions across the city. Take them out before they pick off civilians.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "City District — Rooftops",
		"threat": "high",
		"objectives": ["Eliminate 2 snipers"],
		"optional_objectives": ["Complete without being shot"],
		"reward": {"credits": 350, "xp": 130.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 2,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_008",
		"type": "SURVIVE",
		"target_name": "Wave Survival",
		"target_desc": "A massive hostile wave is incoming. Survive for 90 seconds against escalating enemies.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "Central Plaza",
		"threat": "extreme",
		"objectives": ["Survive for 90 seconds"],
		"optional_objectives": ["Kill at least 8 enemies during survival"],
		"reward": {"credits": 600, "xp": 250.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 90.0,
		"kill_target": 0,
		"survive_seconds": 90.0,
	},
	{
		"id": "contract_009",
		"type": "REACH",
		"target_name": "Secret Lab Discovery",
		"target_desc": "Intel suggests a hidden laboratory exists in the east. Find it.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "East District — Hidden Lab",
		"threat": "medium",
		"objectives": ["Reach the hidden laboratory"],
		"optional_objectives": ["Discover without alerting guards"],
		"reward": {"credits": 300, "xp": 100.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_010",
		"type": "KILL_N",
		"target_name": "Guard Sweeping",
		"target_desc": "The old district is crawling with guards. Clear them out — eliminate 8 guards.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "Old District",
		"threat": "medium",
		"objectives": ["Eliminate 8 guards"],
		"optional_objectives": ["Complete under 60 seconds"],
		"reward": {"credits": 300, "xp": 120.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 8,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_011",
		"type": "KILL_TARGET",
		"target_name": "The Enforcer",
		"target_desc": "Corporate muscle known as 'The Enforcer' runs protection rackets. Time to shut him down.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "Industrial Zone",
		"threat": "high",
		"objectives": ["Locate The Enforcer", "Eliminate The Enforcer"],
		"optional_objectives": ["Defeat without using abilities"],
		"reward": {"credits": 500, "xp": 200.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
	{
		"id": "contract_012",
		"type": "REACH",
		"target_name": "Clock Tower Ascent",
		"target_desc": "The clock tower holds secrets. Reach the top floor to uncover them.",
		"era": "modern",
		"country": "",
		"city": "",
		"location": "Clock Tower — Top Floor",
		"threat": "extreme",
		"objectives": ["Reach the top of the clock tower"],
		"optional_objectives": ["Collect all hidden secrets along the way"],
		"reward": {"credits": 750, "xp": 300.0},
		"consequences": [],
		"target_schedule": [],
		"status": "available",
		"timer_seconds": 0.0,
		"kill_target": 0,
		"survive_seconds": 0.0,
	},
]

static func get_available_contracts() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c in CONTRACTS:
		if c.status == "available":
			result.append(c)
	return result

static func get_contract_by_id(contract_id: String) -> Dictionary:
	for c in CONTRACTS:
		if c.id == contract_id:
			return c
	return {}

static func accept_contract(contract_id: String) -> Dictionary:
	var contract := get_contract_by_id(contract_id)
	if contract.is_empty():
		return {}
	contract.status = "active"
	return contract

static func complete_contract(contract_id: String) -> Dictionary:
	var contract := get_contract_by_id(contract_id)
	if contract.is_empty():
		return {}
	contract.status = "completed"
	return contract.get("reward", {})

static func fail_contract(contract_id: String) -> void:
	var contract := get_contract_by_id(contract_id)
	if not contract.is_empty():
		contract.status = "failed"

static func get_contracts_by_type(type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c in CONTRACTS:
		if c.get("type", "") == type and c.status == "available":
			result.append(c)
	return result

static func get_random_available_contract() -> Dictionary:
	var available := get_available_contracts()
	if available.is_empty():
		return {}
	return available[randi() % available.size()]

static func reset_all() -> void:
		for c in CONTRACTS:
			if c.status != "available":
				c.status = "available"

static func reset_completed() -> void:
	for c in CONTRACTS:
		if c.status == "completed":
			c.status = "available"
