class_name AmbientManager
extends RefCounted


signal secret_found(secret: Dictionary)
signal collectible_collected(collectible: String, amount: float)
signal ambient_event_triggered(event: Dictionary)
signal location_discovered(location: Dictionary)

var _event_timer := 0.0
var _event_interval := 15.0
var _found_secrets: Array[String] = []
var _collected_items: Dictionary = {}
var _discovered_locations: Array[String] = []
var _world_node: Node2D = null

func setup(world_node: Node2D) -> void:
	_world_node = world_node

func update(delta: float, player_pos: Vector2, era: String) -> void:
	_event_timer += delta
	if _event_timer >= _event_interval:
		_event_timer = 0.0
		_check_ambient_events(era)
		_check_secrets(player_pos, era)
		_check_collectibles(player_pos, era)
		_check_locations(player_pos, era)

func _check_ambient_events(era: String) -> void:
	var event: Dictionary = WorldContent.check_ambient_event(era)
	if not event.is_empty():
		ambient_event_triggered.emit(event)
		_apply_ambient_effect(event)

func _check_secrets(player_pos: Vector2, era: String) -> void:
	var secret: Dictionary = WorldContent.find_nearest_secret(player_pos, era, 24.0)
	if not secret.is_empty():
		var secret_id: String = secret.get("id", "")
		if not _found_secrets.has(secret_id):
			_found_secrets.append(secret_id)
			secret["found"] = true
			var rewards: Dictionary = secret.get("rewards", {})
			if GameManager:
				if rewards.has("currency"):
					GameManager.add_currency(rewards["currency"])
				if rewards.has("xp"):
					GameManager.add_xp(rewards["xp"])
				if rewards.has("set_flag"):
					GameManager.set_world_flag(rewards["set_flag"], true)
			secret_found.emit(secret)
			AudioLib2D.play("pickup")

func _check_collectibles(player_pos: Vector2, era: String) -> void:
	if _world_node == null:
		return
	for child in _world_node.get_children():
		if child.get_meta("is_collectible", false):
			var dist: float = player_pos.distance_to(child.global_position)
			if dist < 20.0:
				var item_id: String = child.get_meta("collectible_id", "")
				var amount: float = child.get_meta("collectible_amount", 1.0)
				if item_id != "":
					_apply_collectible(item_id, amount)
					child.queue_free()

func _check_locations(player_pos: Vector2, era: String) -> void:
	var loc: Dictionary = WorldContent.find_nearest_location(player_pos, era, 48.0)
	if not loc.is_empty():
		var loc_id: String = loc.get("id", "")
		if not _discovered_locations.has(loc_id):
			_discovered_locations.append(loc_id)
			location_discovered.emit(loc)

func _apply_ambient_effect(event: Dictionary) -> void:
	var effect: String = event.get("effect", "")
	match effect:
		"visual_glitch":
			if _world_node and _world_node.has_method("_show_floating_text"):
				_world_node._show_floating_text(
					"TEMPORAL DISTORTION", Color(0.7, 0.5, 0.9),
					Vector2(640, 200))
		"audio_echo":
			AudioLib2D.play("paradox_trigger")
		"visual_flash":
			if _world_node and _world_node.has_method("_show_floating_text"):
				_world_node._show_floating_text(
					"NEON SURGE", Color(0.3, 0.8, 1.0),
					Vector2(640, 200))
		"ambient_sound":
			AudioLib2D.play("clock_open")
		"spawn_enemy":
			pass

func _apply_collectible(item_id: String, amount: float) -> void:
	var collectible: Dictionary = WorldContent.get_collectible(item_id)
	if collectible.is_empty():
		return
	match collectible.get("type", ""):
		"consumable":
			GameManager.collect_loot(item_id, amount)
		"currency":
			GameManager.add_currency(int(collectible.get("value", 0) * amount))
		"quest_item":
			GameManager.set_world_flag("has_%s" % item_id, true)
	if not _collected_items.has(item_id):
		_collected_items[item_id] = 0
	_collected_items[item_id] += amount
	collectible_collected.emit(item_id, amount)

func spawn_collectible(pos: Vector2, item_id: String, amount: float = 1.0) -> void:
	if _world_node == null:
		return
	var collectible: Dictionary = WorldContent.get_collectible(item_id)
	if collectible.is_empty():
		return
	var node := StaticBody2D.new()
	node.position = pos
	node.set_meta("is_collectible", true)
	node.set_meta("collectible_id", item_id)
	node.set_meta("collectible_amount", amount)
	node.collision_layer = 0
	node.collision_mask = 0

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	col.shape = shape
	node.add_child(col)

	var spr := Sprite2D.new()
	spr.texture = _collectible_texture(item_id)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 3
	node.add_child(spr)

	_world_node.add_child(node)

func _collectible_texture(item_id: String) -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	var color := Color.WHITE
	match item_id:
		"health_potion":
			color = Color(0.8, 0.2, 0.2)
		"energy_potion":
			color = Color(0.2, 0.5, 0.9)
		"chrono_shard":
			color = Color(0.4, 0.8, 1.0)
		"ancient_coin":
			color = Color(0.9, 0.8, 0.2)
		"temporal_key":
			color = Color(0.6, 0.3, 0.9)
		"data_chip":
			color = Color(0.3, 0.9, 0.5)
		_:
			color = Color(0.6, 0.6, 0.6)
	img.fill(color)
	img.set_pixel(3, 3, color.lightened(0.4))
	img.set_pixel(4, 3, color.lightened(0.3))
	return ImageTexture.create_from_image(img)

func get_found_secrets() -> Array[String]:
	return _found_secrets

func get_collected_items() -> Dictionary:
	return _collected_items

func get_discovered_locations() -> Array[String]:
	return _discovered_locations


func get_save_data() -> Dictionary:
	return {
		"found_secrets": _found_secrets.duplicate(),
		"collected_items": _collected_items.duplicate(),
		"discovered_locations": _discovered_locations.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	_found_secrets = data.get("found_secrets", [])
	_collected_items = data.get("collected_items", {})
	_discovered_locations = data.get("discovered_locations", [])
