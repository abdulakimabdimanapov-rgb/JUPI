extends RefCounted
class_name StatusEffectSystem

# Status effect definitions — balanced for 100 HP base player
# Damage ticks happen every 0.5s via _process_status_effects
# Poison/bleed also block HP regen (tick resets regen delay)
const EFFECTS: Dictionary = {
	"poison": {
		"name": "Poison",
		"description": "2 dmg/tick, blocks regen. Cannot kill below 1 HP.",
		"damage_per_tick": 2.0,
		"max_duration": 5.0,
		"color": Color(0.3, 0.8, 0.2),
		"stacks": false,
		"prevents_kill": true,
	},
	"burn": {
		"name": "Burn",
		"description": "4 dmg/tick. Pure damage, does not block regen.",
		"damage_per_tick": 4.0,
		"max_duration": 3.0,
		"color": Color(1.0, 0.4, 0.1),
		"stacks": false,
		"prevents_kill": false,
	},
	"freeze": {
		"name": "Freeze",
		"description": "Slows movement by 50% for duration.",
		"damage_per_tick": 0.0,
		"max_duration": 3.0,
		"color": Color(0.3, 0.6, 1.0),
		"stacks": false,
		"prevents_kill": false,
	},
	"bleed": {
		"name": "Bleed",
		"description": "2 dmg/tick, blocks regen. Stacks up to 2x.",
		"damage_per_tick": 2.0,
		"max_duration": 5.0,
		"color": Color(0.9, 0.1, 0.1),
		"stacks": true,
		"max_stacks": 2,
		"prevents_kill": true,
	},
	"slow": {
		"name": "Slow",
		"description": "Reduces movement speed by 30% for duration.",
		"damage_per_tick": 0.0,
		"max_duration": 4.0,
		"color": Color(0.5, 0.5, 0.7),
		"stacks": false,
		"prevents_kill": false,
	},
}

static func get_effect_info(effect_id: String) -> Dictionary:
	return EFFECTS.get(effect_id, {})

static func apply_to_player(effect_id: String, duration: float) -> void:
	var player: Node = Engine.get_main_loop().get_first_node_in_group("player")
	if player == null:
		return
	if not player.has_method("apply_status_effect"):
		return
	var effect_info: Dictionary = EFFECTS.get(effect_id, {})
	var max_dur: float = effect_info.get("max_duration", 5.0)
	duration = minf(duration, max_dur)
	player.apply_status_effect(effect_id, duration)

static func can_apply(effect_id: String) -> bool:
	return EFFECTS.has(effect_id)

static func get_all_effects() -> Dictionary:
	return EFFECTS.duplicate(true)
