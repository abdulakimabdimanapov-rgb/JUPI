class_name WorldContent
extends RefCounted



static var LOCATIONS: Dictionary = {
	"clock_tower": {
		"name": "Clock Tower",
		"description": "The ancient tower that houses the temporal anomaly.",
		"era": "present",
		"position": Vector2(32, 3) * 16,
		"type": "landmark",
		"interactable": true,
		"dialogue_id": "time_machine_intro",
	},
	"hotel": {
		"name": "Hotel",
		"description": "A rundown hotel. Rumors say it exists in all eras.",
		"era": "present",
		"position": Vector2(12, 10) * 16,
		"type": "building",
		"interactable": false,
	},
	"workshop": {
		"name": "Workshop",
		"description": "The Engineer's hidden workshop. Filled with temporal tech.",
		"era": "present",
		"position": Vector2(50, 10) * 16,
		"type": "building",
		"interactable": true,
		"dialogue_id": "workshop_engineer",
	},
	"bar": {
		"name": "The Red Hour",
		"description": "A dimly lit bar. Information flows freely here.",
		"era": "present",
		"position": Vector2(55, 42) * 16,
		"type": "building",
		"interactable": false,
	},
	"apartments": {
		"name": "Apartments",
		"description": "Residential block. Some windows still glow.",
		"era": "present",
		"position": Vector2(11, 43) * 16,
		"type": "building",
		"interactable": false,
	},
	"park": {
		"name": "Time Park",
		"description": "A small park with strange temporal distortions.",
		"era": "present",
		"position": Vector2(60, 15) * 16,
		"type": "landmark",
		"interactable": true,
	},
	"fortress": {
		"name": "Warlord's Fortress",
		"description": "A medieval fortress. The Warlord rules from here.",
		"era": "past",
		"position": Vector2(40, 20) * 16,
		"type": "landmark",
		"interactable": false,
	},
	"village": {
		"name": "Village",
		"description": "A small village that could be saved — or lost.",
		"era": "past",
		"position": Vector2(20, 40) * 16,
		"type": "landmark",
		"interactable": true,
	},
	"central_nexus": {
		"name": "Central Nexus",
		"description": "The heart of the future city's power grid.",
		"era": "future",
		"position": Vector2(40, 30) * 16,
		"type": "landmark",
		"interactable": false,
	},
	"ruins": {
		"name": "Time Ruins",
		"description": "What remains after the Collapse. Broken reality.",
		"era": "collapsed",
		"position": Vector2(35, 35) * 16,
		"type": "landmark",
		"interactable": false,
	},
}


static var SECRETS: Dictionary = {
	"hidden_cache_1": {
		"name": "Hidden Cache",
		"description": "A small cache of supplies hidden in the alley.",
		"era": "present",
		"position": Vector2(8, 20) * 16,
		"requires": "",
		"rewards": {"currency": 50, "xp": 25.0},
		"found": false,
	},
	"hidden_cache_2": {
		"name": "Temporal Stash",
		"description": "A stash from a previous time traveler.",
		"era": "present",
		"position": Vector2(70, 40) * 16,
		"requires": "",
		"rewards": {"currency": 100, "xp": 50.0},
		"found": false,
	},
	"secret_passage": {
		"name": "Secret Passage",
		"description": "A hidden passage beneath the manhole.",
		"era": "present",
		"position": Vector2(30, 45) * 16,
		"requires": "has_lockpick",
		"rewards": {"xp": 100.0},
		"found": false,
	},
	"past_altar": {
		"name": "Ancient Altar",
		"description": "An altar with temporal energy. Offers a blessing.",
		"era": "past",
		"position": Vector2(55, 10) * 16,
		"requires": "",
		"rewards": {"xp": 75.0, "set_flag": "altar_blessed"},
		"found": false,
	},
	"future_terminal": {
		"name": "Data Terminal",
		"description": "A functioning terminal with classified data.",
		"era": "future",
		"position": Vector2(20, 25) * 16,
		"requires": "",
		"rewards": {"currency": 200, "xp": 80.0},
		"found": false,
	},
	"collapsed_bunker": {
		"name": "Emergency Bunker",
		"description": "A reinforced bunker. Still has supplies.",
		"era": "collapsed",
		"position": Vector2(50, 50) * 16,
		"requires": "",
		"rewards": {"currency": 300, "xp": 150.0},
		"found": false,
	},
}


static var COLLECTIBLES: Dictionary = {
	"chrono_shard": {
		"name": "Chrono Shard",
		"description": "A fragment of crystallized time.",
		"type": "quest_item",
		"value": 0,
	},
	"health_potion": {
		"name": "Health Potion",
		"description": "Restores 50 HP.",
		"type": "consumable",
		"effect": "heal",
		"value": 50.0,
	},
	"energy_potion": {
		"name": "Energy Potion",
		"description": "Restores 50 Energy.",
		"type": "consumable",
		"effect": "energy",
		"value": 50.0,
	},
	"temporal_key": {
		"name": "Temporal Key",
		"description": "Opens sealed time portals.",
		"type": "quest_item",
		"value": 0,
	},
	"ancient_coin": {
		"name": "Ancient Coin",
		"description": "A coin from a forgotten era. Worth something?",
		"type": "currency",
		"value": 25,
	},
	"data_chip": {
		"name": "Data Chip",
		"description": "Contains encrypted information.",
		"type": "quest_item",
		"value": 0,
	},
}


static var AMBIENT_EVENTS: Array = [
	{
		"id": "temporal_flicker",
		"name": "Temporal Flicker",
		"description": "A brief distortion in reality.",
		"era": "present",
		"probability": 0.02,
		"effect": "visual_glitch",
	},
	{
		"id": "ghostly_echo",
		"name": "Ghostly Echo",
		"description": "A faint whisper from another time.",
		"era": "present",
		"probability": 0.015,
		"effect": "audio_echo",
	},
	{
		"id": "time_rift",
		"name": "Time Rift",
		"description": "A small rift in space-time.",
		"era": "collapsed",
		"probability": 0.03,
		"effect": "spawn_enemy",
	},
	{
		"id": "neon_surge",
		"name": "Neon Surge",
		"description": "The neon signs flicker violently.",
		"era": "future",
		"probability": 0.025,
		"effect": "visual_flash",
	},
	{
		"id": "ancient_wind",
		"name": "Ancient Wind",
		"description": "A gust of wind carries the scent of old wood and iron.",
		"era": "past",
		"probability": 0.02,
		"effect": "ambient_sound",
	},
]


static var ERA_DESCRIPTIONS: Dictionary = {
	"present": {
		"name": "Present Day",
		"description": "A rain-soaked city of neon and shadows. The streets are alive with danger.",
		"mood": "Noir, dangerous, atmospheric",
		"lighting": "Dark blue-purple with warm neon accents",
		"ambient": "Rain, distant sirens, neon hum",
	},
	"past": {
		"name": "Medieval Past",
		"description": "Stone walls, torchlight, and the smell of woodsmoke. A world on the brink of war.",
		"mood": "Dark fantasy, grim, tense",
		"lighting": "Warm orange torchlight against cold stone",
		"ambient": "Wind, distant hammering, crackling fire",
	},
	"future": {
		"name": "Near Future",
		"description": "Sterile corridors, holographic displays, and the hum of machinery.",
		"mood": "Cold, technological, sterile",
		"lighting": "Cool blue-white with occasional neon accents",
		"ambient": "Machinery hum, electronic beeps, sterile ventilation",
	},
	"collapsed": {
		"name": "Collapsed Future",
		"description": "What remains when time breaks. Ruins of every era twisted together.",
		"mood": "Desolate, broken, haunting",
		"lighting": "Sickly green-grey with occasional temporal flashes",
		"ambient": "Silence broken by distant echoes, cracking reality",
	},
}


static func get_location(location_id: String) -> Dictionary:
	return LOCATIONS.get(location_id, {})

static func get_locations_for_era(era_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for loc_id in LOCATIONS:
		var loc: Dictionary = LOCATIONS[loc_id]
		if loc.get("era", "") == era_id:
			result.append(loc)
	return result

static func get_secret(secret_id: String) -> Dictionary:
	return SECRETS.get(secret_id, {})

static func get_secrets_for_era(era_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for sec_id in SECRETS:
		var sec: Dictionary = SECRETS[sec_id]
		if sec.get("era", "") == era_id:
			result.append(sec)
	return result

static func get_collectible(collectible_id: String) -> Dictionary:
	return COLLECTIBLES.get(collectible_id, {})

static func get_ambient_events_for_era(era_id: String) -> Array:
	var result: Array = []
	for event in AMBIENT_EVENTS:
		if event.get("era", "") == era_id:
			result.append(event)
	return result

static func get_era_description(era_id: String) -> Dictionary:
	return ERA_DESCRIPTIONS.get(era_id, {})

static func check_ambient_event(era_id: String) -> Dictionary:
	var events := get_ambient_events_for_era(era_id)
	for event in events:
		if randf() < event.get("probability", 0.0):
			return event
	return {}

static func find_nearest_secret(pos: Vector2, era_id: String, max_distance: float = 32.0) -> Dictionary:
	var nearest := {}
	var min_dist := max_distance
	for sec_id in SECRETS:
		var sec: Dictionary = SECRETS[sec_id]
		if sec.get("era", "") != era_id:
			continue
		if sec.get("found", false):
			continue
		var sec_pos: Vector2 = sec.get("position", Vector2.ZERO)
		var dist: float = pos.distance_to(sec_pos)
		if dist < min_dist:
			min_dist = dist
			nearest = sec
			nearest["id"] = sec_id
	return nearest

static func find_nearest_location(pos: Vector2, era_id: String, max_distance: float = 48.0) -> Dictionary:
	var nearest := {}
	var min_dist := max_distance
	for loc_id in LOCATIONS:
		var loc: Dictionary = LOCATIONS[loc_id]
		if loc.get("era", "") != era_id:
			continue
		var loc_pos: Vector2 = loc.get("position", Vector2.ZERO)
		var dist: float = pos.distance_to(loc_pos)
		if dist < min_dist:
			min_dist = dist
			nearest = loc
			nearest["id"] = loc_id
	return nearest
