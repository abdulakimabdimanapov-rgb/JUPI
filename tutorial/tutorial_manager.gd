class_name TutorialManager
extends RefCounted



enum Step {
	NONE = 0,
	MOVEMENT = 1,
	SPRINT = 2,
	ATTACK = 3,
	DODGE = 4,
	INTERACT = 5,
	BLOOD_CLOCK = 6,
	CONTRACT = 7,
	SHOP = 8,
	INVENTORY = 9,
	TIME_TRAVEL = 10,
	ERA_EXPLORATION = 11,
	BOSS_INTRO = 12,
	ADVANCED_COMBAT = 13,
	DIALOGUE = 14,
	PROGRESSION = 15,
	# New mechanics tutorials
	COMBO_SYSTEM = 20,
	DASH_ATTACK = 21,
	WEAPON_SWAP = 22,
	STATUS_EFFECTS = 23,
}

static var STEP_ORDER: Array[int] = [
	Step.MOVEMENT, Step.SPRINT, Step.ATTACK, Step.DODGE,
	Step.INTERACT, Step.BLOOD_CLOCK, Step.CONTRACT,
	Step.SHOP, Step.INVENTORY, Step.TIME_TRAVEL,
	Step.ERA_EXPLORATION, Step.DIALOGUE, Step.PROGRESSION,
	# Advanced combat tutorials (shown after first kill)
	Step.COMBO_SYSTEM, Step.DASH_ATTACK, Step.WEAPON_SWAP, Step.STATUS_EFFECTS,
]

static var STEP_DATA: Dictionary = {
	Step.MOVEMENT: {
		"title": "MOVEMENT",
		"text": "Use WASD or Arrow Keys to move around the city.",
		"trigger": "first_move",
		"duration": 3.0,
		"position": "top",
	},
	Step.SPRINT: {
		"title": "SPRINT",
		"text": "Hold SHIFT to sprint. Watch your energy bar!",
		"trigger": "first_sprint",
		"duration": 3.0,
		"position": "top",
	},
	Step.ATTACK: {
		"title": "COMBAT",
		"text": "Left Click to attack enemies. Different weapons have different speeds and damage.",
		"trigger": "first_attack",
		"duration": 4.0,
		"position": "top",
	},
	Step.DODGE: {
		"title": "DODGE",
		"text": "Press SPACE to dodge incoming attacks. Brief invincibility!",
		"trigger": "first_dodge",
		"duration": 3.0,
		"position": "top",
	},
	Step.INTERACT: {
		"title": "INTERACTION",
		"text": "Press E near NPCs and objects to interact. Look for the prompt above them.",
		"trigger": "first_interact",
		"duration": 3.5,
		"position": "top",
	},
	Step.BLOOD_CLOCK: {
		"title": "BLOOD CLOCK",
		"text": "Press Q to open the Blood Clock — your guide through time. Accept contracts and check your progress.",
		"trigger": "first_clock_open",
		"duration": 4.0,
		"position": "top",
	},
	Step.CONTRACT: {
		"title": "CONTRACTS",
		"text": "Visit the Contract Board (E) to accept missions. Complete objectives to earn XP and Credits.",
		"trigger": "first_contract",
		"duration": 4.0,
		"position": "top",
	},
	Step.SHOP: {
		"title": "SHOP",
		"text": "Visit the Trader NPC to buy upgrades, weapons, and consumables. Credits are earned from contracts.",
		"trigger": "first_shop",
		"duration": 3.5,
		"position": "top",
	},
	Step.INVENTORY: {
		"title": "INVENTORY",
		"text": "Press I to open your Inventory. Equip weapons and use consumables here.",
		"trigger": "first_inventory",
		"duration": 3.5,
		"position": "top",
	},
	Step.TIME_TRAVEL: {
		"title": "TIME TRAVEL",
		"text": "Approach the Time Machine (E) to travel between eras. Each era has unique enemies and rewards.",
		"trigger": "first_time_machine",
		"duration": 4.5,
		"position": "top",
	},
	Step.ERA_EXPLORATION: {
		"title": "NEW ERA",
		"text": "You've arrived in a new era! Explore, find NPCs, and complete era-specific contracts.",
		"trigger": "first_era_travel",
		"duration": 4.0,
		"position": "top",
	},
	Step.DIALOGUE: {
		"title": "DIALOGUE",
		"text": "Talk to NPCs to learn about the world, unlock quests, and discover secrets.",
		"trigger": "first_dialogue",
		"duration": 3.5,
		"position": "top",
	},
	Step.PROGRESSION: {
		"title": "PROGRESSION",
		"text": "Gain XP to level up and increase your stats. Find stronger weapons to defeat tougher enemies.",
		"trigger": "first_level_up",
		"duration": 4.0,
		"position": "top",
	},
	# === NEW MECHANICS TUTORIALS ===
	Step.COMBO_SYSTEM: {
		"title": "COMBO SYSTEM",
		"text": "Rapid LMB hits chain into COMBOS! Hit 1: x1.0 | Hit 2: x1.15 | Hit 3: x1.4 damage. The HUD shows your combo count!",
		"trigger": "combo_reached_2",
		"duration": 5.0,
		"position": "top",
	},
	Step.DASH_ATTACK: {
		"title": "DASH ATTACK",
		"text": "Sprint + LMB = DASH ATTACK! Deals 1.5x damage with a fast lunge. Great for closing distance!",
		"trigger": "first_dash_attack",
		"duration": 4.5,
		"position": "top",
	},
	Step.WEAPON_SWAP: {
		"title": "WEAPON SWAP",
		"text": "Press 1-4 to quick-swap weapons! No need to open inventory mid-combat.",
		"trigger": "first_weapon_swap",
		"duration": 4.0,
		"position": "top",
	},
	Step.STATUS_EFFECTS: {
		"title": "STATUS EFFECTS",
		"text": "Watch for PSN, BRN, FROZEN, BLD icons! Some weapons apply effects on combo hits. Status ticks deal bonus damage over time.",
		"trigger": "first_status_effect",
		"duration": 5.0,
		"position": "top",
	},
}


var completed_steps: Array[int] = []
var current_step: int = Step.NONE
var _step_timer := 0.0
var _tutorial_active := false
var _waiting_for_trigger: String = ""


func start() -> void:
	_tutorial_active = true
	completed_steps.clear()
	_start_next_step()

func stop() -> void:
	_tutorial_active = false
	current_step = Step.NONE
	_waiting_for_trigger = ""

func is_active() -> bool:
	return _tutorial_active

func is_step_completed(step: int) -> bool:
	return completed_steps.has(step)

func get_current_step() -> int:
	return current_step

func get_progress() -> float:
	return float(completed_steps.size()) / float(STEP_ORDER.size())

func get_remaining_steps() -> int:
	return STEP_ORDER.size() - completed_steps.size()

func trigger(trigger_name: String) -> Dictionary:

	if not _tutorial_active:
		return {}
	if current_step == Step.NONE:
		return {}
	var step_data: Dictionary = STEP_DATA.get(current_step, {})
	var expected_trigger: String = step_data.get("trigger", "")
	if trigger_name == expected_trigger:
		_complete_step()
		return step_data
	return {}

func _complete_step() -> void:
	if current_step != Step.NONE and not completed_steps.has(current_step):
		completed_steps.append(current_step)
	current_step = Step.NONE
	_waiting_for_trigger = ""
	_start_next_step()

func _start_next_step() -> void:
	for step in STEP_ORDER:
		if not completed_steps.has(step):
			current_step = step
			var data: Dictionary = STEP_DATA.get(step, {})
			_waiting_for_trigger = data.get("trigger", "")
			return
	current_step = Step.NONE
	_tutorial_active = false

func get_step_data(step: int) -> Dictionary:
	return STEP_DATA.get(step, {})

func get_all_step_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for step in STEP_ORDER:
		result.append(STEP_DATA.get(step, {}))
	return result


func get_save_data() -> Dictionary:
	return {
		"completed_steps": completed_steps.duplicate(),
		"tutorial_active": _tutorial_active,
	}

func load_save_data(data: Dictionary) -> void:
	completed_steps = data.get("completed_steps", [])
	_tutorial_active = data.get("tutorial_active", false)
	if _tutorial_active:
		_start_next_step()
