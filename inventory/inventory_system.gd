extends RefCounted
class_name InventorySystem


signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal item_used(item_id: String)
signal weapon_equipped(weapon_id: String)
signal weapon_unequipped()

var items: Dictionary = {}
var equipped_weapon: String = "combat_knife"

static var CONSUMABLES := {
	"hp_potion": {"name": "HP Potion", "description": "Restores 30 HP", "heal": 30.0, "price": 50, "rarity": "common", "icon": "res://assets/2d/items/hp_potion.png"},
	"hp_potion_large": {"name": "Large HP Potion", "description": "Restores 60 HP", "heal": 60.0, "price": 120, "rarity": "uncommon", "icon": "res://assets/2d/items/hp_potion_large.png"},
	"energy_potion": {"name": "Energy Potion", "description": "Restores 40 Energy", "energy": 40.0, "price": 40, "rarity": "common", "icon": "res://assets/2d/items/energy_potion.png"},
	"energy_potion_large": {"name": "Large Energy Potion", "description": "Restores 80 Energy", "energy": 80.0, "price": 100, "rarity": "uncommon", "icon": "res://assets/2d/items/energy_potion_large.png"},
	"revive_token": {"name": "Revive Token", "description": "Instant respawn with 50% HP", "revive": true, "price": 200, "rarity": "rare", "icon": "res://assets/2d/items/revive_token.png"},
	"elixir_strength": {"name": "Elixir of Strength", "description": "+50% damage for 15 seconds", "buff": "damage", "buff_value": 1.5, "buff_duration": 15.0, "price": 150, "rarity": "uncommon", "icon": "res://assets/2d/items/elixir_yellow.png"},
	"elixir_shield": {"name": "Elixir of Warding", "description": "Reduce damage taken by 40% for 12 seconds", "buff": "defense", "buff_value": 0.6, "buff_duration": 12.0, "price": 180, "rarity": "uncommon", "icon": "res://assets/2d/items/elixir_large.png"},
	"scroll_teleport": {"name": "Scroll of Blink", "description": "Instantly teleport to a random safe location", "teleport": true, "price": 100, "rarity": "common", "icon": "res://assets/2d/items/scroll.png"},

	# === ERA CONSUMABLES: PAST ===
	"holy_water": {"name": "Holy Water", "description": "Burns undead enemies, heals 40 HP", "heal": 40.0, "buff": "holy_damage", "buff_value": 2.0, "buff_duration": 8.0, "price": 80, "rarity": "uncommon", "icon": "res://assets/2d/items/hp_potion.png", "era": "past"},
	"kings_feast": {"name": "King's Feast", "description": "+30 Max HP for 20 seconds. A royal banquet.", "buff": "max_hp", "buff_value": 30.0, "buff_duration": 20.0, "price": 120, "rarity": "uncommon", "icon": "res://assets/2d/items/food_meat.png", "era": "past"},
	"scroll_banish": {"name": "Scroll of Banish", "description": "Pushes all enemies away and stuns them 2s", "teleport": true, "price": 150, "rarity": "rare", "icon": "res://assets/2d/items/scroll_ancient.png", "era": "past"},

	# === ERA CONSUMABLES: FUTURE ===
	"nano_medkit": {"name": "Nano Medkit", "description": "Regenerates 80 HP over 5 seconds", "heal": 80.0, "price": 160, "rarity": "uncommon", "icon": "res://assets/2d/items/hp_potion_large.png", "era": "future"},
	"combat_stim": {"name": "Combat Stim", "description": "+75% damage and +30% speed for 10 seconds", "buff": "damage", "buff_value": 1.75, "buff_duration": 10.0, "price": 200, "rarity": "rare", "icon": "res://assets/2d/items/elixir_yellow.png", "era": "future"},
	"shield_battery": {"name": "Shield Battery", "description": "Temporarily absorbs 50 damage before breaking", "buff": "defense", "buff_value": 0.3, "buff_duration": 15.0, "price": 180, "rarity": "uncommon", "icon": "res://assets/2d/items/elixir_large.png", "era": "future"},

	# === ERA CONSUMABLES: COLLAPSED ===
	"mutant_extract": {"name": "Mutant Extract", "description": "Mutagenic serum. +40% damage but -20% HP for 15s", "buff": "damage", "buff_value": 1.4, "buff_duration": 15.0, "price": 100, "rarity": "rare", "icon": "res://assets/2d/items/elixir_yellow.png", "era": "collapsed"},
	"scavenged_meds": {"name": "Scavenged Meds", "description": "Crude healing. Restores 50 HP but costs 10 energy", "heal": 50.0, "energy": -10.0, "price": 60, "rarity": "common", "icon": "res://assets/2d/items/hp_potion.png", "era": "collapsed"},
	"rad_away": {"name": "Rad-Away", "description": "Removes all debuffs and heals 30 HP", "heal": 30.0, "price": 80, "rarity": "uncommon", "icon": "res://assets/2d/items/hp_potion.png", "era": "collapsed"},
}

static var UPGRADES := {
	"max_hp_1": {"name": "Health Upgrade I", "description": "+20 Max HP", "stat": "max_hp", "value": 20.0, "price": 200, "rarity": "uncommon", "icon": "res://assets/2d/items/gem_ruby.png"},
	"max_hp_2": {"name": "Health Upgrade II", "description": "+30 Max HP", "stat": "max_hp", "value": 30.0, "price": 500, "rarity": "rare", "icon": "res://assets/2d/items/gem_ruby.png"},
	"max_energy_1": {"name": "Energy Upgrade I", "description": "+20 Max Energy", "stat": "max_energy", "value": 20.0, "price": 200, "rarity": "uncommon", "icon": "res://assets/2d/items/gem_sapphire.png"},
	"max_energy_2": {"name": "Energy Upgrade II", "description": "+30 Max Energy", "stat": "max_energy", "value": 30.0, "price": 500, "rarity": "rare", "icon": "res://assets/2d/items/gem_sapphire.png"},
	"damage_1": {"name": "Damage Upgrade I", "description": "+5 Damage Bonus", "stat": "damage_bonus", "value": 5.0, "price": 350, "rarity": "uncommon", "icon": "res://assets/2d/items/warhammer.png"},
	"damage_2": {"name": "Damage Upgrade II", "description": "+8 Damage Bonus", "stat": "damage_bonus", "value": 8.0, "price": 700, "rarity": "rare", "icon": "res://assets/2d/items/warhammer.png"},
	"sprint_1": {"name": "Sprint Efficiency I", "description": "-20% Sprint Drain", "stat": "sprint_efficiency", "value": 0.8, "price": 300, "rarity": "uncommon", "icon": "res://assets/2d/items/boots_speed.png"},
	"crit_1": {"name": "Critical Training I", "description": "+5% Crit Chance", "stat": "crit_chance", "value": 0.05, "price": 400, "rarity": "uncommon", "icon": "res://assets/2d/items/dagger.png"},
	"lifesteal_1": {"name": "Vampiric Bond", "description": "Heal 5% of damage dealt", "stat": "lifesteal", "value": 0.05, "price": 600, "rarity": "rare", "icon": "res://assets/2d/items/gem_ruby.png"},
	"dodge_1": {"name": "Shadow Step", "description": "10% chance to dodge attacks entirely", "stat": "dodge_chance", "value": 0.10, "price": 500, "rarity": "rare", "icon": "res://assets/2d/items/boots_speed.png"},
	"speed_1": {"name": "Swift Boots", "description": "+15% Movement Speed", "stat": "move_speed_mult", "value": 1.15, "price": 450, "rarity": "uncommon", "icon": "res://assets/2d/items/boots_speed.png"},
}

func add_item(item_id: String, count: int = 1) -> void:
	if not items.has(item_id):
		items[item_id] = 0
	items[item_id] += count
	item_added.emit(item_id, count)

func remove_item(item_id: String, count: int = 1) -> bool:
	if not items.has(item_id) or items[item_id] < count:
		return false
	items[item_id] -= count
	if items[item_id] <= 0:
		items.erase(item_id)
	item_removed.emit(item_id, count)
	return true

func has_item(item_id: String, count: int = 1) -> bool:
	return items.get(item_id, 0) >= count

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func get_inventory() -> Dictionary:
	return items.duplicate()

func get_all_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in items:
		var count: int = items[item_id]
		var info := _get_item_info(item_id)
		info["id"] = item_id
		info["count"] = count
		result.append(info)
	return result

func _get_item_info(item_id: String) -> Dictionary:
	if CONSUMABLES.has(item_id):
		return CONSUMABLES[item_id].duplicate()
	if UPGRADES.has(item_id):
		return UPGRADES[item_id].duplicate()
	return {"name": item_id, "description": "Unknown item"}

func get_item_price(item_id: String) -> int:
	var info := _get_item_info(item_id)
	return info.get("price", 0)

func is_consumable(item_id: String) -> bool:
	return CONSUMABLES.has(item_id)

func is_upgrade(item_id: String) -> bool:
	return UPGRADES.has(item_id)


func use_consumable(item_id: String, player: Node = null) -> bool:
	if not has_item(item_id):
		return false
	if not CONSUMABLES.has(item_id):
		return false

	var consumable: Dictionary = CONSUMABLES[item_id]
	var used := false

	if consumable.has("heal") and player:
		var heal_amount: float = consumable["heal"]
		if "hp" in player and "max_hp" in player:
			player.hp = minf(player.max_hp, player.hp + heal_amount)
			if "hp_changed" in player:
				player.hp_changed.emit(player.hp, player.max_hp)
			used = true

	if consumable.has("energy") and player:
		var energy_amount: float = consumable["energy"]
		if "energy" in player and "max_energy" in player:
			player.energy = minf(player.max_energy, player.energy + energy_amount)
			if "energy_changed" in player:
				player.energy_changed.emit(player.energy)
			used = true

	if consumable.has("revive") and player:
		var alive_val = player.get("alive")
		if alive_val != null and not alive_val:
			player.respawn()
			used = true

	if consumable.has("buff") and player:
		var buff_type: String = consumable["buff"]
		var buff_val: float = consumable.get("buff_value", 1.0)
		var buff_dur: float = consumable.get("buff_duration", 10.0)
		if player.has_method("apply_buff"):
			player.apply_buff(buff_type, buff_val, buff_dur)
			used = true

	if consumable.has("teleport") and player:
		# Teleport to a random safe position in the world
		var safe_spots := [
			Vector2(30, 26), Vector2(48, 8), Vector2(10, 40),
			Vector2(60, 28), Vector2(20, 45), Vector2(65, 10),
			Vector2(35, 30), Vector2(50, 20), Vector2(15, 15),
		]
		var spot: Vector2 = safe_spots[randi() % safe_spots.size()] * 16.0
		player.global_position = spot
		used = true

	if used:
		remove_item(item_id, 1)
		item_used.emit(item_id)
	return used


func equip_weapon(weapon_id: String) -> void:
	equipped_weapon = weapon_id
	weapon_equipped.emit(weapon_id)

func unequip_weapon() -> void:
	equipped_weapon = "combat_knife"
	weapon_unequipped.emit()

func get_equipped_weapon() -> String:
	return equipped_weapon


func get_save_data() -> Dictionary:
	return {
		"items": items.duplicate(),
		"equipped_weapon": equipped_weapon,
	}

func load_save_data(data: Dictionary) -> void:
	items = data.get("items", {}).duplicate()
	equipped_weapon = data.get("equipped_weapon", "combat_knife")
