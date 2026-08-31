extends CharacterBody2D

signal enemy_died(enemy: Node2D)
signal enemy_alerted(enemy: Node2D)

var enemy_type = "mage"
var hp = 40.0
var max_hp = 40.0
var damage = 20.0
var speed = 40.0
var chase_speed = 55.0
var detection_range = 130.0
var attack_range = 80.0
var attack_cd = 1.8
var xp_reward = 45.0
var loot_table = {"hp": 0.2, "energy": 0.4, "currency": 0.3, "rare": 0.1}

enum State { IDLE, PATROL, CASTING, TELEPORT, RETREAT, DEAD }
var state = State.IDLE
var facing = Vector2.RIGHT
var last_seen = Vector2.ZERO

var _state_timer = 0.0
var _attack_cd = 0.0
var _idle_timer = 0.0
var _patrol_index = 0
var _patrol_wait = 2.0
var _cast_time = 0.8
var _teleport_cooldown = 0.0
var _teleport_max_cd = 8.0

var patrol_points = []

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _alert_icon: Label
var _magic_circle: Sprite2D

func _ready():
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)

	_sprite = Sprite2D.new()
	var sheet_path := "res://assets/2d/enemies/%s_sheet.png" % enemy_type
	if ResourceLoader.exists(sheet_path):
		_sprite.texture = load(sheet_path)
		_sprite.hframes = 8
		_sprite.vframes = 4
		_sprite.frame = 0
	else:
		_sprite.texture = _enemy_texture()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_hp_bar_bg = ColorRect.new()
	_hp_bar_bg.color = Color(0.08, 0.08, 0.10, 0.7)
	_hp_bar_bg.position = Vector2(-8, -14)
	_hp_bar_bg.size = Vector2(16, 3)
	add_child(_hp_bar_bg)

	_hp_bar = ColorRect.new()
	_hp_bar.color = Color(0.80, 0.20, 0.20)
	_hp_bar.position = Vector2(-7, -13)
	_hp_bar.size = Vector2(14, 1)
	add_child(_hp_bar)

	_alert_icon = Label.new()
	_alert_icon.add_theme_font_size_override("font_size", 10)
	_alert_icon.position = Vector2(-4, -20)
	_alert_icon.visible = false
	add_child(_alert_icon)

	_magic_circle = Sprite2D.new()
	var circle_img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for x in range(16):
		for y in range(16):
			var d = Vector2(x - 7.5, y - 7.5).length()
			if d > 5.0 and d < 7.5:
				circle_img.set_pixel(x, y, Color(0.5, 0.2, 0.8, 0.6))
	_magic_circle.texture = ImageTexture.create_from_image(circle_img)
	_magic_circle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_magic_circle.position = Vector2(0, 4)
	_magic_circle.visible = false
	_magic_circle.z_index = 3
	add_child(_magic_circle)

func _physics_process(delta):
	if state == State.DEAD:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)
	_teleport_cooldown = maxf(0.0, _teleport_cooldown - delta)
	_process_enemy_effects(delta)
	if _enemy_effects.has("freeze"):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player = _find_player()

	match state:
		State.IDLE:
			_idle_timer -= delta
			_alert_icon.visible = false
			_magic_circle.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 300) % 4
			if _idle_timer <= 0.0 and not patrol_points.is_empty():
				state = State.PATROL
			elif player and _can_see(player):
				if global_position.distance_to(player.global_position) < attack_range * 0.5 and _teleport_cooldown <= 0.0:
					_teleport_away(player)
				else:
					_start_casting(player)

		State.PATROL:
			_alert_icon.visible = false
			_magic_circle.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 180) % 4)
			if patrol_points.is_empty():
				state = State.IDLE
				return
			var target = patrol_points[_patrol_index]
			var to = target - global_position
			if to.length() < 8.0:
				_patrol_index = (_patrol_index + 1) % patrol_points.size()
				_idle_timer = _patrol_wait
				state = State.IDLE
				velocity = Vector2.ZERO
			else:
				velocity = to.normalized() * speed
				facing = to.normalized()
				move_and_slide()
			if player and _can_see(player):
				_start_casting(player)

		State.CASTING:
			_state_timer -= delta
			_alert_icon.text = "*"
			_alert_icon.visible = true
			_alert_icon.add_theme_color_override("font_color", Color(0.6, 0.2, 0.9))
			_magic_circle.visible = true
			_magic_circle.rotation += delta * 3.0
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 120) % 4)
			if player:
				facing = (player.global_position - global_position).normalized()
				_sprite.flip_h = facing.x < 0.0
				if _state_timer <= 0.0:
					_cast_spell(player)
			else:
				state = State.RETREAT
				_state_timer = 2.0
				_magic_circle.visible = false

		State.TELEPORT:
			_state_timer -= delta
			_alert_icon.text = "~"
			_alert_icon.visible = true
			_alert_icon.add_theme_color_override("font_color", Color(0.5, 0.2, 0.8))
			_magic_circle.visible = true
			_magic_circle.rotation += delta * 6.0
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 24 + (int(Time.get_ticks_msec() / 100) % 4)
			_sprite.modulate.a = 0.3 + _state_timer * 0.7
			if _state_timer <= 0.0:
				_finish_teleport()

		State.RETREAT:
			_alert_icon.visible = false
			_magic_circle.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 200) % 4)
			_sprite.modulate.a = 1.0
			if patrol_points.is_empty():
				state = State.IDLE
				return
			var home = patrol_points[0]
			_move_towards(home, speed, delta)
			if global_position.distance_to(home) < 10.0:
				state = State.IDLE
				_idle_timer = _patrol_wait
			if player and _can_see(player):
				if _teleport_cooldown <= 0.0:
					_teleport_away(player)
				else:
					_start_casting(player)

	var hp_frac = clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = hp_frac * 14.0
	_hp_bar_bg.visible = hp < max_hp
	_hp_bar.visible = hp < max_hp

func _start_casting(player):
	last_seen = player.global_position
	state = State.CASTING
	_state_timer = _cast_time
	enemy_alerted.emit(self)
	AudioLib2D.play("detect")

func _cast_spell(player):
	state = State.IDLE
	_magic_circle.visible = false
	_attack_cd = attack_cd

	# Cast burst particles
	_spawn_cast_burst()
	_spawn_magic_bolt(player.global_position)

	AudioLib2D.play("enemy_alert")

var _enemy_effects: Dictionary = {}
var _effect_tick_timer := 0.0

func apply_status_effect(effect: String, duration: float) -> void:
	if state == State.DEAD:
		return
	_enemy_effects[effect] = duration
	match effect:
		"poison":
			_sprite.modulate = Color(0.5, 1.0, 0.4)
		"burn":
			_sprite.modulate = Color(1.0, 0.6, 0.2)
		"slow":
			pass
		"freeze":
			_sprite.modulate = Color(0.5, 0.7, 1.0)
			velocity = Vector2.ZERO

func _process_enemy_effects(delta: float) -> void:
	if _enemy_effects.is_empty() or state == State.DEAD:
		return
	_effect_tick_timer -= delta
	if _effect_tick_timer <= 0.0:
		_effect_tick_timer = 0.5
		for effect in _enemy_effects:
			var info: Dictionary = StatusEffectSystem.get_effect_info(effect)
			var dmg: float = info.get("damage_per_tick", 0.0)
			if dmg > 0.0:
				hp -= dmg
				if hp <= 0.0:
					_die()
					return
	var expired: Array = []
	for effect in _enemy_effects:
		_enemy_effects[effect] -= delta
		if _enemy_effects[effect] <= 0.0:
			expired.append(effect)
	for effect in expired:
		_enemy_effects.erase(effect)
	if _enemy_effects.is_empty():
		_sprite.modulate = Color.WHITE

func _spawn_magic_bolt(target_pos):
	var proj = Sprite2D.new()
	var img = Image.create(6, 6, false, Image.FORMAT_RGBA8)
	for y in range(6):
		for x in range(6):
			var d = Vector2(x - 2.5, y - 2.5).length()
			if d <= 2.5:
				img.set_pixel(x, y, Color(0.6, 0.2, 0.9, clampf(1.0 - d / 2.5, 0.3, 1.0)))
	proj.texture = ImageTexture.create_from_image(img)
	proj.position = global_position
	proj.z_index = 6
	get_parent().add_child(proj)

	# Trail particles
	var trail := CPUParticles2D.new()
	trail.one_shot = true
	trail.emitting = true
	trail.amount = 8
	trail.lifetime = 0.4
	trail.explosiveness = 0.6
	trail.direction = Vector2.ZERO
	trail.spread = 30.0
	trail.initial_velocity_min = 5.0
	trail.initial_velocity_max = 15.0
	trail.gravity = Vector2.ZERO
	trail.scale_amount_min = 0.3
	trail.scale_amount_max = 0.7
	trail.color = Color(0.5, 0.15, 0.8, 0.8)
	trail.position = global_position
	trail.z_index = 5
	get_parent().add_child(trail)
	get_tree().create_timer(0.5).timeout.connect(trail.queue_free)

	var dir = (target_pos - global_position).normalized()
	var tw = create_tween()
	tw.tween_property(proj, "position", proj.position + dir * attack_range, 0.3)
	tw.tween_callback(proj.free)

	await get_tree().create_timer(0.3).timeout
	var p = _find_player()
	if p and global_position.distance_to(p.global_position) <= attack_range + 20.0:
		if p.has_method("take_damage"):
			p.take_damage(damage, dir)
			_spawn_hit_burst(p.global_position)
			# 30% chance to apply poison
			if randf() < 0.3 and p.has_method("apply_status_effect"):
				p.apply_status_effect("poison", 4.0)

func _spawn_area_effect(pos):
	var circle = Sprite2D.new()
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	for x in range(12):
		for y in range(12):
			var d = Vector2(x - 5.5, y - 5.5).length()
			if d < 5.0:
				img.set_pixel(x, y, Color(0.5, 0.1, 0.7, clampf(1.0 - d / 5.0, 0.1, 0.4)))
	circle.texture = ImageTexture.create_from_image(img)
	circle.position = pos
	circle.z_index = 5
	get_parent().add_child(circle)

	var tw = create_tween()
	tw.tween_property(circle, "scale", Vector2(2, 2), 0.3)
	tw.parallel().tween_property(circle, "modulate:a", 0.0, 0.3)
	tw.tween_callback(circle.free)

func _teleport_away(player):
	state = State.TELEPORT
	_state_timer = 0.5
	_teleport_cooldown = _teleport_max_cd

	# Teleport particles at departure point
	_spawn_teleport_burst()

	var away_dir = (global_position - player.global_position).normalized()
	if away_dir.length() < 0.1:
		away_dir = Vector2.RIGHT
	var teleport_dist = randf_range(60.0, 100.0)
	global_position += away_dir * teleport_dist
	global_position = global_position.clamp(Vector2(16, 16), Vector2(80 * 16 - 16, 60 * 16 - 16))

func _finish_teleport():
	state = State.RETREAT
	_state_timer = 1.0
	_magic_circle.visible = false
	_sprite.modulate.a = 1.0
	AudioLib2D.play("time_travel")

func take_damage(amount, from_dir = Vector2.ZERO):
	if state == State.DEAD:
		return

	hp -= amount

	_sprite.modulate = Color(1.5, 0.5, 0.5)
	var tw = create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	_spawn_damage_number(amount)

	velocity = from_dir.normalized() * 100.0

	if state in [State.IDLE, State.PATROL, State.RETREAT]:
		if _teleport_cooldown <= 0.0 and randf() < 0.3:
			_teleport_away(_find_player())
		else:
			state = State.CASTING
			_state_timer = _cast_time * 0.5
			enemy_alerted.emit(self)

	if hp <= 0.0:
		_die()

func _die():
	state = State.DEAD
	velocity = Vector2.ZERO
	_sprite.modulate = Color(0.4, 0.4, 0.5, 0.5)
	_hp_bar.visible = false
	_hp_bar_bg.visible = false
	_alert_icon.visible = false
	_magic_circle.visible = false
	enemy_died.emit(self)

	_spawn_death_particles()
	_spawn_loot()

	var tw = create_tween()
	tw.tween_property(_sprite, "modulate:a", 0.0, 1.0)
	tw.tween_property(_sprite, "position:y", _sprite.position.y + 6.0, 1.0)
	await tw.finished
	free()

func _can_see(player):
	if not player.get("alive"):
		return false
	var dist = global_position.distance_to(player.global_position)
	if dist > detection_range:
		return false
	var q = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
	var result = get_world_2d().direct_space_state.intersect_ray(q)
	if result.is_empty():
		return true
	return global_position.distance_to(result.position) > dist - 5.0

func _find_player():
	return get_tree().get_first_node_in_group("player")

func _move_towards(target, spd, delta):
	var to = target - global_position
	if to.length() < 5.0:
		velocity = Vector2.ZERO
	else:
		velocity = to.normalized() * spd
		facing = to.normalized()
	move_and_slide()
	_sprite.flip_h = facing.x < 0.0

func _spawn_damage_number(amount):
	var lbl = Label.new()
	lbl.text = "-" + str(int(amount))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl.position = Vector2(-8, -18)
	lbl.z_index = 10
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 16.0, 0.4)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.tween_callback(lbl.free)

func _spawn_death_particles():
	var p = CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 20
	p.lifetime = 0.8
	p.explosiveness = 0.9
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.gravity = Vector2(0, 40)
	p.scale_amount_min = 0.3
	p.scale_amount_max = 1.0
	p.color = Color(0.5, 0.2, 0.8, 0.8)
	p.position = Vector2(0, -4)
	p.z_index = 6
	add_child(p)
	get_tree().create_timer(0.9).timeout.connect(p.queue_free)

func _spawn_loot():
	GameManager.add_xp(xp_reward)
	var loot = Sprite2D.new()
	var img = Image.create(6, 6, false, Image.FORMAT_RGBA8)
	var loot_color = Color(0.5, 0.2, 0.8)
	for y in range(6):
		for x in range(6):
			var d = Vector2(x - 2.5, y - 2.5).length()
			if d <= 2.5:
				var c = loot_color * Color(1, 1, 1, clampf(1.0 - d / 2.5, 0.3, 1.0))
				img.set_pixel(x, y, c)
	loot.texture = ImageTexture.create_from_image(img)
	loot.position = Vector2(randf_range(-6, 6), randf_range(-4, 4))
	loot.z_index = 4
	add_child(loot)
	var tw = create_tween().set_loops(3)
	tw.tween_property(loot, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_SINE)
	tw.tween_property(loot, "scale", Vector2(0.8, 0.8), 0.3).set_trans(Tween.TRANS_SINE)
	await tw.finished
	var player = _find_player()
	if player:
		var absorb = create_tween()
		absorb.tween_property(loot, "global_position", player.global_position, 0.3)
		absorb.parallel().tween_property(loot, "modulate:a", 0.0, 0.3)
		absorb.tween_callback(loot.queue_free)
	else:
		loot.queue_free()

func _enemy_texture():
	var img = Image.create(12, 14, false, Image.FORMAT_RGBA8)
	var body_color = Color(0.4, 0.2, 0.5)
	for x in range(4, 8): for y in range(0, 3): img.set_pixel(x, y, body_color.lightened(0.15))
	for x in range(3, 9): for y in range(3, 10): img.set_pixel(x, y, body_color)
	for x in range(4, 6): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	for x in range(6, 8): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	img.set_pixel(5, 1, Color(0.8, 0.3, 1.0))
	img.set_pixel(6, 1, Color(0.8, 0.3, 1.0))
	return ImageTexture.create_from_image(img)


func _spawn_cast_burst() -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 12
	p.lifetime = 0.3
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 60.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.8
	p.color = Color(0.6, 0.2, 0.9, 0.9)
	p.position = Vector2(0, -4)
	p.z_index = 7
	add_child(p)
	get_tree().create_timer(0.4).timeout.connect(p.queue_free)


func _spawn_hit_burst(pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 16
	p.lifetime = 0.4
	p.explosiveness = 0.9
	p.direction = Vector2.UP
	p.spread = 160.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 80.0
	p.gravity = Vector2(0, 50)
	p.scale_amount_min = 0.3
	p.scale_amount_max = 1.0
	p.color = Color(0.5, 0.1, 0.8, 0.9)
	p.position = pos
	p.z_index = 6
	get_parent().add_child(p)
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)

	# Poison cloud particles (purple-green)
	var cloud := CPUParticles2D.new()
	cloud.one_shot = true
	cloud.emitting = true
	cloud.amount = 8
	cloud.lifetime = 0.8
	cloud.explosiveness = 0.5
	cloud.direction = Vector2.UP
	cloud.spread = 120.0
	cloud.initial_velocity_min = 10.0
	cloud.initial_velocity_max = 25.0
	cloud.gravity = Vector2(0, -20)
	cloud.scale_amount_min = 0.5
	cloud.scale_amount_max = 1.5
	cloud.color = Color(0.3, 0.8, 0.2, 0.6)
	cloud.position = pos
	cloud.z_index = 5
	get_parent().add_child(cloud)
	get_tree().create_timer(1.0).timeout.connect(cloud.queue_free)


func _spawn_teleport_burst() -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 20
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 50.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.2
	p.scale_amount_max = 0.6
	p.color = Color(0.4, 0.1, 0.7, 0.8)
	p.position = Vector2.ZERO
	p.z_index = 7
	add_child(p)
	get_tree().create_timer(0.6).timeout.connect(p.queue_free)
