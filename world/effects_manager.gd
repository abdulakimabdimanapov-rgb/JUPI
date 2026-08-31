class_name EffectsManager
extends RefCounted


var _world_node: Node2D = null
var _hud_layer: CanvasLayer = null
var _active_effects: Array[Dictionary] = []

func setup(world_node: Node2D, hud_layer: CanvasLayer = null) -> void:
	_world_node = world_node
	_hud_layer = hud_layer


func spawn_hit_effect(pos: Vector2, color: Color = Color(1.0, 0.3, 0.2)) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.4
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 80.0
	particles.gravity = Vector2(0, 120)
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 1.5
	particles.color = color
	particles.z_index = 15
	_world_node.add_child(particles)
	_register_effect(particles, 1.0)

func spawn_crit_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var flash := Sprite2D.new()
	flash.position = pos
	flash.z_index = 16
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.9, 0.2, 0.8))
	flash.texture = ImageTexture.create_from_image(img)
	flash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world_node.add_child(flash)
	_register_effect(flash, 0.15)
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.5
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 100.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.2
	particles.color = Color(1.0, 0.85, 0.2)
	particles.z_index = 16
	_world_node.add_child(particles)
	_register_effect(particles, 0.8)

func spawn_knockback_effect(pos: Vector2, direction: Vector2) -> void:

	if _world_node == null:
		return
	var lines := Line2D.new()
	lines.position = pos
	lines.width = 2.0
	lines.default_color = Color(0.8, 0.8, 0.8, 0.6)
	lines.z_index = 14
	for i in range(3):
		var offset := direction.normalized() * (i * 4.0)
		lines.add_point(offset)
		lines.add_point(offset + direction.normalized() * 8.0)
	_world_node.add_child(lines)
	_register_effect(lines, 0.2)

func spawn_death_effect(pos: Vector2, color: Color = Color(0.6, 0.2, 0.2)) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.8
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2(0, 100)
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.5
	particles.color = color
	particles.z_index = 15
	_world_node.add_child(particles)
	_register_effect(particles, 1.2)

func spawn_loot_effect(pos: Vector2, item_color: Color) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 10
	particles.lifetime = 0.6
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2(0, -30)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	particles.color = item_color
	particles.z_index = 16
	_world_node.add_child(particles)
	_register_effect(particles, 1.0)


func spawn_xp_orb(pos: Vector2, amount: float) -> void:

	if _world_node == null:
		return
	var orb := Sprite2D.new()
	orb.position = pos
	orb.z_index = 15
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.7, 0.9))
	img.set_pixel(2, 2, Color(0.5, 0.9, 1.0))
	img.set_pixel(3, 2, Color(0.5, 0.9, 1.0))
	orb.texture = ImageTexture.create_from_image(img)
	orb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world_node.add_child(orb)

	var tw := _world_node.create_tween()
	if tw:
		tw.tween_property(orb, "position:y", pos.y - 20.0, 0.5)
		tw.parallel().tween_property(orb, "modulate:a", 0.0, 0.5)
		tw.tween_callback(orb.free)

func spawn_level_up_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 120.0
	particles.gravity = Vector2(0, -20)
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	particles.color = Color(0.2, 0.9, 0.4)
	particles.z_index = 17
	_world_node.add_child(particles)
	_register_effect(particles, 1.5)

	var flash := ColorRect.new()
	flash.color = Color(0.2, 0.9, 0.4, 0.3)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.z_index = 18
	if _hud_layer:
		_hud_layer.add_child(flash)
		_register_effect(flash, 0.3, true)


func spawn_time_travel_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 40
	particles.lifetime = 1.5
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 40.0
	particles.gravity = Vector2(0, -10)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 1.0
	particles.color = Color(0.4, 0.6, 1.0)
	particles.z_index = 100
	_world_node.add_child(particles)
	_register_effect(particles, 2.0)

func spawn_paradox_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 25
	particles.lifetime = 1.2
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 1.2
	particles.color = Color(0.9, 0.5, 0.2)
	particles.z_index = 100
	_world_node.add_child(particles)
	_register_effect(particles, 1.5)

func spawn_era_arrival_effect(pos: Vector2, era_color: Color) -> void:

	if _world_node == null:
		return
	var ring := Sprite2D.new()
	ring.position = pos
	ring.z_index = 50
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for x in range(32):
		for y in range(32):
			var dist := Vector2(x - 16, y - 16).length()
			if dist > 12 and dist < 16:
				img.set_pixel(x, y, era_color)
	ring.texture = ImageTexture.create_from_image(img)
	ring.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world_node.add_child(ring)
	var tw := _world_node.create_tween()
	if tw:
		tw.tween_property(ring, "scale", Vector2(4, 4), 0.8)
		tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.8)
		tw.tween_callback(ring.free)


func spawn_secret_discovery_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 15
	particles.lifetime = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 90.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2(0, -20)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	particles.color = Color(1.0, 0.85, 0.2)
	particles.z_index = 16
	_world_node.add_child(particles)
	_register_effect(particles, 1.2)

func spawn_location_discovered_effect(pos: Vector2) -> void:

	if _world_node == null:
		return
	var pin := Sprite2D.new()
	pin.position = pos + Vector2(0, -16)
	pin.z_index = 16
	var img := Image.create(8, 12, false, Image.FORMAT_RGBA8)
	for x in range(3, 5):
		for y in range(0, 6):
			img.set_pixel(x, y, Color(0.3, 0.8, 0.5))
	for x in range(2, 6):
		for y in range(6, 10):
			img.set_pixel(x, y, Color(0.3, 0.8, 0.5))
	img.set_pixel(3, 10, Color(0.3, 0.8, 0.5))
	img.set_pixel(4, 10, Color(0.3, 0.8, 0.5))
	img.set_pixel(3, 11, Color(0.3, 0.8, 0.5))
	img.set_pixel(4, 11, Color(0.3, 0.8, 0.5))
	pin.texture = ImageTexture.create_from_image(img)
	pin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world_node.add_child(pin)
	var tw := _world_node.create_tween()
	if tw:
		tw.tween_property(pin, "position:y", pin.position.y - 8.0, 0.3)
		tw.tween_property(pin, "position:y", pin.position.y, 0.2)
		tw.tween_interval(1.0)
		tw.tween_property(pin, "modulate:a", 0.0, 0.3)
		tw.tween_callback(pin.free)


func spawn_temporal_flicker(pos: Vector2) -> void:

	if _world_node == null:
		return
	var distortion := ColorRect.new()
	distortion.color = Color(0.5, 0.3, 0.8, 0.15)
	distortion.position = pos - Vector2(32, 32)
	distortion.size = Vector2(64, 64)
	distortion.z_index = 18
	_world_node.add_child(distortion)
	_register_effect(distortion, 0.2)

func spawn_neon_surge(pos: Vector2) -> void:

	if _world_node == null:
		return
	var flash := ColorRect.new()
	flash.color = Color(0.3, 0.8, 1.0, 0.2)
	flash.position = pos - Vector2(24, 24)
	flash.size = Vector2(48, 48)
	flash.z_index = 18
	_world_node.add_child(flash)
	_register_effect(flash, 0.15)


func flash_screen(color: Color, duration: float = 0.2) -> void:

	if _hud_layer == null:
		return
	var flash := ColorRect.new()
	flash.color = Color(color.r, color.g, color.b, 0.3)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.z_index = 200
	_hud_layer.add_child(flash)
	_register_effect(flash, duration, true)

func screen_shake(intensity: float = 2.0, duration: float = 0.15) -> void:

	flash_screen(Color(0.8, 0.2, 0.1), duration)


func _register_effect(node: Node, duration: float, is_hud: bool = false) -> void:
	_active_effects.append({
		"node": node,
		"duration": duration,
		"elapsed": 0.0,
		"is_hud": is_hud,
	})

func update(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(_active_effects.size()):
		var effect: Dictionary = _active_effects[i]
		effect["elapsed"] = effect.get("elapsed", 0.0) + delta
		if effect["elapsed"] >= effect.get("duration", 1.0):
			var node: Node = effect.get("node")
			if is_instance_valid(node):
				node.free()
			to_remove.append(i)
	to_remove.reverse()
	for i in to_remove:
		_active_effects.remove_at(i)

func clear_all() -> void:	for effect in _active_effects:
	var node: Node = effect.get("node")
	if is_instance_valid(node):
		node.free()
	_active_effects.clear()

func get_active_count() -> int:
	return _active_effects.size()
