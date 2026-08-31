extends Node

# signals
signal contract_received(contract: Dictionary)
signal era_changed(era: String)
signal timeline_changed(event: String)
signal player_died()
signal player_respawned()
signal xp_changed(xp: float, level: int)
signal level_up(new_level: int)
signal currency_changed(amount: int)
signal loot_collected(loot_type: String, amount: float)
signal game_state_changed(old_state: int, new_state: int)
signal save_completed()
signal era_travel_started(from_era: String, to_era: String)
signal era_travel_completed(era: String)
signal era_discovered(era_id: String)
signal world_flag_changed(flag: String, value: bool)

enum GameState { EXPLORING, COMBAT, SHOP, INVENTORY, CONTRACT_BOARD, DEAD, PAUSED, DIALOGUE, TIME_TRAVEL, TIMELINE, BOSS_FIGHT, PARADOX_EVENT }
var current_game_state: int = GameState.EXPLORING

var current_era: String = "present"
var current_country: String = ""
var current_city: String = ""
var current_location: String = ""

var unlocked_eras: Array = ["present"]
var world_flags: Dictionary = {}
var era_visits: Dictionary = {"present": 0, "past": 0, "future": 0, "collapsed": 0}
var player_hp: float = 100.0
var player_max_hp: float = 100.0
var player_energy: float = 100.0
var player_alive: bool = true

var player_level: int = 1
var player_xp: float = 0.0
var xp_to_next_level: float = 100.0
var player_currency: int = 0
var total_kills: int = 0

var level_hp_bonus: float = 10.0
var level_energy_bonus: float = 8.0
var level_damage_bonus: float = 3.0

var total_loot_collected: int = 0
var loot_history: Dictionary = {}

var defeated_bosses: Array = []
var active_boss_id: String = ""
var boss_defeated_signal_fired: bool = false

var timeline_events: Array = []
var world_variants: Dictionary = {}
var paradox_history: Array = []

var _is_traveling := false

var active_contract: Dictionary = {}
var completed_contracts: Array = []
var failed_contracts_count: int = 0
var contract_history: Array = []

var clock_memory: Dictionary = {
	"known_eras": ["modern"],
	"known_countries": [],
	"known_cities": [],
	"met_characters": [],
	"player_decisions": [],
	"clock_secrets": [],
	"contract_count": 0,
}

var era_equipment: Dictionary = {
	"ancient": {"weapon": "stone_blade", "armor": "leather_wrap", "tool": "torch"},
	"medieval": {"weapon": "iron_sword", "armor": "chainmail", "tool": "rope"},
	"industrial": {"weapon": "revolver", "armor": "coat", "tool": "lockpick"},
	"modern": {"weapon": "combat_knife", "armor": "tactical_vest", "tool": "grapple"},
	"near_future": {"weapon": "pulse_pistol", "armor": "nano_suit", "tool": "hacker_pad"},
	"far_future": {"weapon": "phase_blade", "armor": "energy_shield", "tool": "temporal_key"},
}
var current_equipment: Dictionary = {}

var inventory: InventorySystem
var save_system: Node
var dialogue_tutorial_completed: bool = false
var tutorial_completed: bool = false
var world_content_data: Dictionary = {}

var npc_dialogue_history: Dictionary = {}
var total_dialogues: int = 0

func _ready():
	current_equipment = era_equipment["modern"].duplicate()
	inventory = InventorySystem.new()
	_load_from_save()


func set_game_state(new_state):
	if new_state == current_game_state:
		return
	var old := current_game_state
	current_game_state = new_state
	game_state_changed.emit(old, new_state)

func is_gameplay_active():
	return current_game_state in [GameState.EXPLORING, GameState.COMBAT]

func is_ui_open():
	return current_game_state in [GameState.SHOP, GameState.INVENTORY, GameState.CONTRACT_BOARD, GameState.DIALOGUE, GameState.TIMELINE, GameState.PARADOX_EVENT]

func can_act():
	return current_game_state in [GameState.EXPLORING, GameState.COMBAT]


func save_game():
	var save_data: Dictionary = _build_save_data()
	var path := "user://savegame.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	save_completed.emit()
	return true

func load_game():
	var path := "user://savegame.json"
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return false
	var data: Dictionary = json.data
	if not data is Dictionary:
		return false
	_apply_save_data(data)
	return true

func has_save():
	return FileAccess.file_exists("user://savegame.json")

func delete_save():
	DirAccess.remove_absolute("user://savegame.json")

func _build_save_data() -> Dictionary:
	return {
		"version": 4,
		"timestamp": Time.get_datetime_string_from_system(),
		"player_level": player_level,
		"player_xp": player_xp,
		"xp_to_next_level": xp_to_next_level,
		"currency": player_currency,
		"max_hp": player_max_hp,
		"tutorial_completed": tutorial_completed,
		"dialogue_history": npc_dialogue_history.duplicate(),
		"total_dialogues": total_dialogues,
		"max_energy": 100.0,
		"damage_bonus": _get_total_damage_bonus(),
		"equipped_weapon": inventory.get_equipped_weapon(),
		"inventory": inventory.get_save_data(),
		"total_kills": total_kills,
		"total_loot": total_loot_collected,
		"completed_contracts": completed_contracts.size(),
		"failed_contracts": failed_contracts_count,
		"current_era": current_era,
		"unlocked_eras": unlocked_eras.duplicate(),
		"world_flags": world_flags.duplicate(),
		"era_visits": era_visits.duplicate(),
		"defeated_bosses": defeated_bosses.duplicate(),
		"active_boss_id": active_boss_id,
		"paradox_history": paradox_history.duplicate(true),
	}

func _apply_save_data(data):
	player_level = data.get("player_level", 1)
	player_xp = data.get("player_xp", 0.0)
	xp_to_next_level = data.get("xp_to_next_level", 100.0)
	player_currency = data.get("currency", 0)
	player_max_hp = data.get("max_hp", 100.0)
	total_kills = data.get("total_kills", 0)
	total_loot_collected = data.get("total_loot", 0)
	var inv_data: Dictionary = data.get("inventory", {})
	inventory.load_save_data(inv_data)
	var weapon_id: String = inv_data.get("equipped_weapon", "combat_knife")
	inventory.equip_weapon(weapon_id)
	current_equipment["weapon"] = weapon_id
	current_era = data.get("current_era", "present")
	unlocked_eras = data.get("unlocked_eras", ["present"])
	world_flags = data.get("world_flags", {})
	era_visits = data.get("era_visits", {})
	defeated_bosses = data.get("defeated_bosses", [])
	active_boss_id = data.get("active_boss_id", "")
	paradox_history = data.get("paradox_history", [])
	tutorial_completed = data.get("tutorial_completed", false)
	npc_dialogue_history = data.get("dialogue_history", {})
	total_dialogues = data.get("total_dialogues", 0)

func _load_from_save():
	if has_save():
		load_game()

func _get_total_damage_bonus():
	return (player_level - 1) * level_damage_bonus


func start_new_contract(contract):
	active_contract = contract
	contract_history.append(contract)
	clock_memory.contract_count += 1
	clock_memory.player_decisions.append({"type": "contract_started", "target": contract.get("target_name", "???")})
	contract_received.emit(contract)
	autosave()

func complete_contract(reward = {}):
	if active_contract.is_empty():
		return
	active_contract["status"] = "completed"
	active_contract["reward"] = reward
	completed_contracts.append(active_contract)
	clock_memory.player_decisions.append({"type": "contract_completed", "target": active_contract.get("target_name", "???")})
	var credits: int = reward.get("credits", 0)
	if credits > 0:
		add_currency(credits)
	var xp_reward: float = reward.get("xp", 50.0)
	if xp_reward > 0:
		add_xp(xp_reward)
	active_contract = {}
	autosave()

func fail_contract():
	if active_contract.is_empty():
		return
	active_contract["status"] = "failed"
	failed_contracts_count += 1
	clock_memory.player_decisions.append({"type": "contract_failed", "target": active_contract.get("target_name", "???")})
	active_contract = {}
	autosave()


func travel_to_era(era, country = "", city = ""):
	var old_era := current_era
	current_era = era
	current_country = country
	current_city = city
	if era_equipment.has(era):
		current_equipment = era_equipment[era].duplicate()
	if not clock_memory.known_eras.has(era):
		clock_memory.known_eras.append(era)
	era_visits[era] = era_visits.get(era, 0) + 1
	era_changed.emit(era)
	autosave()

func start_time_travel(to_era):
	if _is_traveling:
		return
	if not unlocked_eras.has(to_era):
		return
	_is_traveling = true
	set_game_state(GameState.TIME_TRAVEL)
	var from_era := current_era
	era_travel_started.emit(from_era, to_era)

func complete_time_travel(era):
	travel_to_era(era)
	_is_traveling = false
	era_travel_completed.emit(era)
	set_game_state(GameState.EXPLORING)
	autosave()

func try_unlock_era(era_id):
	if unlocked_eras.has(era_id):
		return false
	var total_completed := completed_contracts.size()
	if EraData.can_unlock(era_id, player_level, total_completed, world_flags):
		unlocked_eras.append(era_id)
		era_discovered.emit(era_id)
		autosave()
		return true
	return false

func check_era_unlocks():
	for era_id in ["present", "past", "future", "collapsed"]:
		try_unlock_era(era_id)

func is_era_unlocked(era_id):
	return unlocked_eras.has(era_id)


func start_boss_fight(boss_id):
	active_boss_id = boss_id
	set_game_state(GameState.BOSS_FIGHT)
	autosave()

func defeat_boss(boss_id):
	if not defeated_bosses.has(boss_id):
		defeated_bosses.append(boss_id)
	set_world_flag("boss_%s_defeated" % boss_id, true)
	_check_paradox_triggers("defeat_boss_%s" % boss_id)
	active_boss_id = ""
	set_game_state(GameState.EXPLORING)
	boss_defeated_signal_fired = true
	autosave()

func is_boss_defeated(boss_id):
	return defeated_bosses.has(boss_id)

func get_boss_reward(boss_id):
	var boss := BossData.get_boss(boss_id)
	if boss.is_empty():
		return {}
	return boss.get("loot", {})


func _check_paradox_triggers(trigger):
	var events := ParadoxData.check_trigger(trigger, world_flags)
	for event in events:
		_trigger_paradox(event)

func _trigger_paradox(event):
	var flag: String = event.get("world_flag", "")
	if flag != "":
		set_world_flag(flag, true)
	var consequences: Dictionary = event.get("consequences", {})
	paradox_history.append({
		"event_id": event.get("id", ""),
		"flag": flag,
		"consequences": consequences,
		"time": Time.get_datetime_string_from_system(),
	})
	timeline_changed.emit(event.get("id", ""))
	AudioLib2D.play("paradox_trigger")
	_show_paradox_notification(event)

func _show_paradox_notification(event):
	var tree := get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group("game_world"):
		if node.has_method("_show_floating_text"):
			node._show_floating_text("PARADOX: %s" % event.get("name", "???"), Color(0.9, 0.6, 0.2), Vector2(512, 200))
			break

func get_paradox_events_for_era(era_id):
	var result: Array[Dictionary] = []
	for event in ParadoxData.get_paradox_events():
		if event.get("target_era", "") == era_id or event.get("target_era", "") == "all":
			result.append(event)
	return result

func check_contract_paradox(contract_id):
	_check_paradox_triggers("complete_contract_%s" % contract_id)


func set_world_flag(flag, value):
	world_flags[flag] = value
	world_flag_changed.emit(flag, value)
	autosave()

func get_world_flag(flag):
	return world_flags.get(flag, false)

func has_world_flag(flag):
	return world_flags.has(flag)


func apply_consequence(consequence):
	if consequence.has("world_flag"):
		set_world_flag(consequence["world_flag"], true)
	if consequence.has("unlock_era"):
		try_unlock_era(consequence["unlock_era"])
	if consequence.has("event"):
		record_timeline_event(current_era, consequence["event"], consequence)

func record_timeline_event(era, event, consequence = {}):
	timeline_events.append({"era": era, "event": event, "consequence": consequence, "time": Time.get_datetime_string_from_system()})
	if consequence.has("world_change"):
		world_variants[consequence.world_change] = consequence
	timeline_changed.emit(event)

func add_clock_memory(category, data):
	if clock_memory.has(category):
		var arr: Array = clock_memory[category]
		if not arr.has(data):
			arr.append(data)

func get_clock_dialogue_context() -> Dictionary:
	return {
		"era": current_era,
		"country": current_country,
		"city": current_city,
		"contract": active_contract,
		"memory": clock_memory,
		"hp": player_hp,
		"equipment": current_equipment,
		"level": player_level,
		"currency": player_currency,
	}


func add_xp(amount):
	player_xp += amount
	xp_changed.emit(player_xp, player_level)
	while player_xp >= xp_to_next_level:
		_level_up()

func _level_up():
	player_xp -= xp_to_next_level
	player_level += 1
	xp_to_next_level = _calc_xp_for_level(player_level)
	player_max_hp += level_hp_bonus
	player_hp = player_max_hp
	level_up.emit(player_level)
	xp_changed.emit(player_xp, player_level)
	autosave()

func _calc_xp_for_level(lvl):
	return 100.0 + (lvl - 1) * 50.0

func get_level_damage_bonus():
	return (player_level - 1) * level_damage_bonus

func get_difficulty_scale():
	return 1.0 + (player_level - 1) * 0.1


func add_currency(amount):
	player_currency += amount
	currency_changed.emit(player_currency)

func spend_currency(amount):
	if player_currency >= amount:
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	return false


func collect_loot(loot_type, amount):
	total_loot_collected += 1
	if not loot_history.has(loot_type):
		loot_history[loot_type] = 0
	loot_history[loot_type] += 1
	loot_collected.emit(loot_type, amount)

func get_loot_stats():
	return {"total": total_loot_collected, "by_type": loot_history.duplicate()}


func buy_item(item_id):
	var price := ShopData.get_item_price(item_id)
	if price <= 0:
		return false
	if not spend_currency(price):
		return false
	if inventory.is_upgrade(item_id):
		_apply_upgrade(item_id)
		inventory.add_item(item_id, 1)
	elif inventory.is_consumable(item_id):
		inventory.add_item(item_id, 1)
	elif WeaponData.WEAPONS.has(item_id):
		if not inventory.has_item(item_id):
			inventory.add_item(item_id, 1)
			inventory.equip_weapon(item_id)
			current_equipment["weapon"] = item_id
	else:
		add_currency(price)
		return false
	autosave()
	return true

func _apply_upgrade(upgrade_id):
	if not InventorySystem.UPGRADES.has(upgrade_id):
		return
	var upgrade: Dictionary = InventorySystem.UPGRADES[upgrade_id]
	var stat: String = upgrade.get("stat", "")
	var value: float = upgrade.get("value", 0.0)
	match stat:
		"max_hp":
			player_max_hp += value
			player_hp = player_max_hp
		"max_energy":
			pass
		"damage_bonus":
			level_damage_bonus += value
		"sprint_efficiency":
			pass
		"crit_chance":
			pass


func update_player_stats(hp, max_hp, energy):
	player_hp = hp
	player_max_hp = max_hp
	player_energy = energy

func apply_level_bonuses_to_player(player):
	if player.has_method("apply_level_bonuses"):
		player.apply_level_bonuses(level_hp_bonus, level_energy_bonus, level_damage_bonus)


func autosave():
	save_game()


func get_statistics():
	return {
		"level": player_level,
		"xp": player_xp,
		"xp_to_next": xp_to_next_level,
		"currency": player_currency,
		"max_hp": player_max_hp,
		"damage_bonus": _get_total_damage_bonus(),
		"weapon": inventory.get_equipped_weapon(),
		"total_kills": total_kills,
		"contracts_completed": completed_contracts.size(),
		"contracts_failed": failed_contracts_count,
		"loot_collected": total_loot_collected,
		"total_dialogues": total_dialogues,
	}


func record_dialogue(npc_name, node_id = ""):
	npc_dialogue_history[npc_name] = node_id
	total_dialogues += 1
	autosave()

func has_talked_to(npc_name):
	return npc_dialogue_history.has(npc_name)

func get_npc_dialogue_state(npc_name):
	return npc_dialogue_history.get(npc_name, "")

func get_total_dialogues():
	return total_dialogues


func get_world_description(era_id):
	return WorldContent.get_era_description(era_id)

func get_nearby_location(pos, era_id):
	return WorldContent.find_nearest_location(pos, era_id, 48.0)

func get_nearby_secret(pos, era_id):
	return WorldContent.find_nearest_secret(pos, era_id, 32.0)
				
					 
