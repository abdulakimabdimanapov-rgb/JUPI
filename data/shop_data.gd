extends RefCounted
class_name ShopData


signal item_purchased(item_id: String)
signal purchase_failed(reason: String)

enum ShopCategory { UPGRADES, WEAPONS, CONSUMABLES }

static func get_shop_items(category: ShopCategory) -> Array[Dictionary]:
	match category:
		ShopCategory.UPGRADES:
			return _get_upgrade_items()
		ShopCategory.WEAPONS:
			return _get_weapon_items()
		ShopCategory.CONSUMABLES:
			return _get_consumable_items()
	return []

static func _get_upgrade_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for id in InventorySystem.UPGRADES:
		var item: Dictionary = InventorySystem.UPGRADES[id].duplicate()
		item["id"] = id
		item["category"] = "upgrade"
		items.append(item)
	return items

static func _get_weapon_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for id in WeaponData.WEAPONS:
		var item: Dictionary = WeaponData.WEAPONS[id].duplicate()
		item["category"] = "weapon"
		items.append(item)
	return items

static func _get_consumable_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for id in InventorySystem.CONSUMABLES:
		var item: Dictionary = InventorySystem.CONSUMABLES[id].duplicate()
		item["id"] = id
		item["category"] = "consumable"
		items.append(item)
	return items

static func can_afford(item_id: String, currency: int) -> bool:
	var price := get_item_price(item_id)
	return currency >= price

static func get_item_price(item_id: String) -> int:
	if InventorySystem.UPGRADES.has(item_id):
		return InventorySystem.UPGRADES[item_id].get("price", 0)
	if WeaponData.WEAPONS.has(item_id):
		return WeaponData.WEAPONS[item_id].get("price", 0)
	if InventorySystem.CONSUMABLES.has(item_id):
		return InventorySystem.CONSUMABLES[item_id].get("price", 0)
	return 0

static func get_item_info(item_id: String) -> Dictionary:
	if InventorySystem.UPGRADES.has(item_id):
		var info: Dictionary = InventorySystem.UPGRADES[item_id].duplicate()
		info["id"] = item_id
		info["category"] = "upgrade"
		return info
	if WeaponData.WEAPONS.has(item_id):
		var info: Dictionary = WeaponData.WEAPONS[item_id].duplicate()
		info["category"] = "weapon"
		return info
	if InventorySystem.CONSUMABLES.has(item_id):
		var info: Dictionary = InventorySystem.CONSUMABLES[item_id].duplicate()
		info["id"] = item_id
		info["category"] = "consumable"
		return info
	return {}
