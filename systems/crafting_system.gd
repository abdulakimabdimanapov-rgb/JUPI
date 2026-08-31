extends RefCounted
class_name CraftingSystem

signal item_crafted(recipe_id: String)
signal recipe_discovered(recipe_id: String)

var recipes = {}
var discovered_recipes = []
var crafting_materials = {}

func _init():
	_init_recipes()
	_init_materials()

func _init_recipes():
	recipes = {
		"iron_sword": {
			"id": "iron_sword",
			"name": "Iron Sword",
			"description": "Basic iron sword. Reliable.",
			"type": "weapon",
			"result_id": "iron_sword",
			"materials": {"iron": 3, "wood": 1},
			"xp_reward": 25,
			"discovered": true,
		},
		"steel_blade": {
			"id": "steel_blade",
			"name": "Steel Blade",
			"description": "Stronger than iron.",
			"type": "weapon",
			"result_id": "steel_blade",
			"materials": {"iron": 5, "coal": 2},
			"xp_reward": 50,
			"discovered": true,
		},
		"shadow_dagger": {
			"id": "shadow_dagger",
			"name": "Shadow Dagger",
			"description": "Dark blade with high crit.",
			"type": "weapon",
			"result_id": "shadow_dagger",
			"materials": {"dark_essence": 2, "iron": 2, "shadow_shard": 1},
			"xp_reward": 75,
			"discovered": false,
		},
		"leather_armor": {
			"id": "leather_armor",
			"name": "Leather Armor",
			"description": "Light protection.",
			"type": "armor",
			"result_id": "leather_armor",
			"materials": {"leather": 4, "thread": 2},
			"xp_reward": 25,
			"discovered": true,
		},
		"chainmail": {
			"id": "chainmail",
			"name": "Chainmail",
			"description": "Medium protection.",
			"type": "armor",
			"result_id": "chainmail",
			"materials": {"iron": 6, "leather": 2},
			"xp_reward": 50,
			"discovered": true,
		},
		"nano_suit_mk2": {
			"id": "nano_suit_mk2",
			"name": "Nano Suit MK2",
			"description": "Advanced armor.",
			"type": "armor",
			"result_id": "nano_suit_mk2",
			"materials": {"nano_fiber": 3, "circuit": 2, "energy_cell": 1},
			"xp_reward": 100,
			"discovered": false,
		},
		"hp_potion": {
			"id": "hp_potion",
			"name": "HP Potion",
			"description": "Restores 30 HP.",
			"type": "consumable",
			"result_id": "hp_potion",
			"materials": {"herb": 2, "vial": 1},
			"xp_reward": 10,
			"discovered": true,
		},
		"hp_potion_large": {
			"id": "hp_potion_large",
			"name": "Large HP Potion",
			"description": "Restores 60 HP.",
			"type": "consumable",
			"result_id": "hp_potion_large",
			"materials": {"herb": 5, "vial": 1, "crystal": 1},
			"xp_reward": 25,
			"discovered": false,
		},
		"energy_potion": {
			"id": "energy_potion",
			"name": "Energy Potion",
			"description": "Restores 40 Energy.",
			"type": "consumable",
			"result_id": "energy_potion",
			"materials": {"crystal": 2, "vial": 1},
			"xp_reward": 10,
			"discovered": true,
		},
		"bomb": {
			"id": "bomb",
			"name": "Bomb",
			"description": "Area damage.",
			"type": "consumable",
			"result_id": "bomb",
			"materials": {"gunpowder": 3, "iron": 1},
			"xp_reward": 20,
			"discovered": false,
		},
		"torch": {
			"id": "torch",
			"name": "Torch",
			"description": "Lights dark areas.",
			"type": "tool",
			"result_id": "torch",
			"materials": {"wood": 2, "cloth": 1},
			"xp_reward": 5,
			"discovered": true,
		},
		"lockpick": {
			"id": "lockpick",
			"name": "Lockpick",
			"description": "Opens locked doors.",
			"type": "tool",
			"result_id": "lockpick",
			"materials": {"iron": 2, "wire": 1},
			"xp_reward": 15,
			"discovered": true,
		},
	}

func _init_materials():
	crafting_materials = {
		"iron": {"name": "Iron", "description": "Common metal.", "stackable": true},
		"wood": {"name": "Wood", "description": "Basic material.", "stackable": true},
		"leather": {"name": "Leather", "description": "Animal hide.", "stackable": true},
		"coal": {"name": "Coal", "description": "Fuel for smelting.", "stackable": true},
		"herb": {"name": "Herb", "description": "Medicinal plant.", "stackable": true},
		"crystal": {"name": "Crystal", "description": "Magical material.", "stackable": true},
		"vial": {"name": "Vial", "description": "Container for potions.", "stackable": true},
		"thread": {"name": "Thread", "description": "For sewing.", "stackable": true},
		"dark_essence": {"name": "Dark Essence", "description": "Dark magic.", "stackable": true},
		"shadow_shard": {"name": "Shadow Shard", "description": "Fragment of darkness.", "stackable": true},
		"nano_fiber": {"name": "Nano Fiber", "description": "Advanced material.", "stackable": true},
		"circuit": {"name": "Circuit", "description": "Electronic component.", "stackable": true},
		"energy_cell": {"name": "Energy Cell", "description": "Power source.", "stackable": true},
		"gunpowder": {"name": "Gunpowder", "description": "Explosive.", "stackable": true},
		"wire": {"name": "Wire", "description": "Thin metal.", "stackable": true},
		"cloth": {"name": "Cloth", "description": "Fabric.", "stackable": true},
	}

func can_craft(recipe_id, inventory):
	if not recipes.has(recipe_id):
		return false

	var recipe = recipes[recipe_id]
	var materials = recipe.get("materials", {})

	for material_id in materials:
		var required = materials[material_id]
		var have = inventory.get_item_count(material_id)
		if have < required:
			return false

	return true

func craft(recipe_id, inventory):
	if not can_craft(recipe_id, inventory):
		return false

	var recipe = recipes[recipe_id]
	var materials = recipe.get("materials", {})

	for material_id in materials:
		var required = materials[material_id]
		inventory.remove_item(material_id, required)

	var result_id = recipe.get("result_id", "")
	if result_id != "":
		inventory.add_item(result_id, 1)

	if GameManager:
		GameManager.add_xp(recipe.get("xp_reward", 0))

	item_crafted.emit(recipe_id)
	return true

func discover_recipe(recipe_id):
	if not recipes.has(recipe_id):
		return false
	if discovered_recipes.has(recipe_id):
		return false

	discovered_recipes.append(recipe_id)
	recipes[recipe_id]["discovered"] = true
	recipe_discovered.emit(recipe_id)
	return true

func get_recipes():
	return recipes.duplicate()

func get_discovered_recipes():
	var result = []
	for recipe_id in discovered_recipes:
		if recipes.has(recipe_id):
			result.append(recipes[recipe_id])
	return result

func get_undiscovered_recipes():
	var result = []
	for recipe_id in recipes:
		if not discovered_recipes.has(recipe_id):
			result.append(recipes[recipe_id])
	return result

func get_recipe(recipe_id):
	return recipes.get(recipe_id, {})

func get_materials():
	return crafting_materials.duplicate()

func get_save_data():
	return {
		"discovered_recipes": discovered_recipes.duplicate(),
	}

func load_save_data(data):
	discovered_recipes = data.get("discovered_recipes", [])
	for recipe_id in discovered_recipes:
		if recipes.has(recipe_id):
			recipes[recipe_id]["discovered"] = true
