extends Node


const SAVE_VERSION := 1
const SAVE_PATH := "user://savegame.json"

signal save_completed()
signal load_completed()
signal save_failed(reason: String)

var _save_data: Dictionary = {}

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_PATH.get_base_dir())

func get_default_save() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"player_level": 1,
		"player_xp": 0.0,
		"xp_to_next": 100.0,
		"currency": 0,
		"max_hp": 100.0,
		"max_energy": 100.0,
		"damage_bonus": 0.0,
		"sprint_efficiency": 1.0,
		"crit_chance": 0.15,
		"crit_multiplier": 2.0,
		"equipped_weapon": "combat_knife",
		"inventory": {},
		"completed_contracts": [],
		"failed_contracts": [],
		"total_kills": 0,
		"total_loot": 0,
		"loot_by_type": {},
		"unlocked_weapons": ["combat_knife"],
		"upgrades_purchased": {},
		"settings": {
			"music_volume": 0.8,
			"sfx_volume": 1.0,
		},
		"timestamp": "",
	}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(data: Dictionary = {}) -> bool:
	if data.is_empty():
		data = _save_data
	data["version"] = SAVE_VERSION
	data["timestamp"] = Time.get_datetime_string_from_system()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		save_failed.emit("Cannot write to " + SAVE_PATH)
		return false

	var json_string := JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	_save_data = data.duplicate()
	save_completed.emit()
	return true

func load_game() -> Dictionary:
	if not has_save():
		_save_data = get_default_save()
		return _save_data

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_save_data = get_default_save()
		save_failed.emit("Cannot read save file")
		return _save_data

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		_save_data = get_default_save()
		save_failed.emit("Corrupted save file, using defaults")
		return _save_data

	var data: Dictionary = json.data
	if not data is Dictionary:
		_save_data = get_default_save()
		save_failed.emit("Invalid save format")
		return _save_data

	data = _migrate_save(data)

	var defaults := get_default_save()
	for key in defaults:
		if not data.has(key):
			data[key] = defaults[key]

	_save_data = data
	load_completed.emit()
	return _save_data

func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	return true

func _migrate_save(data: Dictionary) -> Dictionary:
	var saved_version: int = data.get("version", 0)
	if saved_version < SAVE_VERSION:
		pass
	data["version"] = SAVE_VERSION
	return data

func get_data() -> Dictionary:
	if _save_data.is_empty():
		_save_data = load_game()
	return _save_data

func set_value(key: String, value: Variant) -> void:
	_save_data[key] = value

func get_value(key: String, default: Variant = null) -> Variant:
	return _save_data.get(key, default)

func autosave() -> void:
	save_game(_save_data)
