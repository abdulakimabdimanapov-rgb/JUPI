extends RefCounted
class_name TimeTravel


signal travel_started(from_era: String, to_era: String)
signal travel_completed(era: String)
signal world_state_changed(change: String)

var eras := {
	"ancient": {
		"name": "The Ancient Age",
		"year_range": [-3000, -500],
		"tech_level": 0,
		"music": "ancient",
		"ambience": "wilderness",
		"lighting": "warm",
		"weather_chances": {"clear": 0.6, "rain": 0.2, "fog": 0.2},
	},
	"medieval": {
		"name": "The Iron Century",
		"year_range": [500, 1400],
		"tech_level": 1,
		"music": "medieval",
		"ambience": "village",
		"lighting": "candlelight",
		"weather_chances": {"clear": 0.4, "rain": 0.3, "fog": 0.2, "snow": 0.1},
	},
	"industrial": {
		"name": "The Smoke Era",
		"year_range": [1700, 1920],
		"tech_level": 2,
		"music": "industrial",
		"ambience": "factory",
		"lighting": "gaslight",
		"weather_chances": {"clear": 0.3, "rain": 0.4, "fog": 0.2, "smog": 0.1},
	},
	"modern": {
		"name": "The Present Day",
		"year_range": [1990, 2030],
		"tech_level": 3,
		"music": "modern",
		"ambience": "city",
		"lighting": "electric",
		"weather_chances": {"clear": 0.5, "rain": 0.3, "cloudy": 0.2},
	},
	"near_future": {
		"name": "The Bleeding Edge",
		"year_range": [2040, 2100],
		"tech_level": 4,
		"music": "synth",
		"ambience": "cybercity",
		"lighting": "neon",
		"weather_chances": {"clear": 0.4, "acid_rain": 0.3, "smog": 0.3},
	},
	"far_future": {
		"name": "The Last Dawn",
		"year_range": [2200, 3000],
		"tech_level": 5,
		"music": "ambient",
		"ambience": "space",
		"lighting": "quantum",
		"weather_chances": {"clear": 0.6, "energy_storm": 0.2, "void": 0.2},
	},
}

var world_state := {
	"industrial_valdoria_peace": false,
	"far_future_nexus_shift": false,
	"medieval_king_alive": true,
	"ancient_temple_intact": true,
}

func can_travel_to(era: String) -> bool:
	return eras.has(era)

func get_era_info(era: String) -> Dictionary:
	return eras.get(era, {})

func apply_consequence(consequence: Dictionary) -> void:
	if consequence.has("world_change"):
		var key: String = consequence.world_change
		world_state[key] = true
		world_state_changed.emit(key)

func is_world_changed(change: String) -> bool:
	return world_state.get(change, false)

func get_changed_locations() -> Array[String]:
	var changed: Array[String] = []
	for key in world_state:
		if world_state[key] and key.contains("_"):
			changed.append(key)
	return changed

func get_era_theme(era: String) -> Dictionary:
	var info := get_era_info(era)
	return {
		"lighting": info.get("lighting", "electric"),
		"ambience": info.get("ambience", "city"),
		"music": info.get("music", "modern"),
	}
                                 