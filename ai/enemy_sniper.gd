extends CharacterBody2D

signal enemy_died(enemy: Node2D)
signal enemy_alerted(enemy: Node2D)

var enemy_type = "sniper"
var hp = 30.0
var max_hp = 30.0
var damage = 35.0
var speed = 35.0
var chase_speed = 50.0
var detection_range = 150.0
var attack_range = 120.0
var attack_cd = 2.5
var xp_reward = 40.0
var loot_table = {"hp": 0.2, "energy": 0.3, "currency": 0.4, "rare": 0.1}

enum State { IDLE, PATROL, AIMING, SHOOTING, RETREAT, DEAD }
var state = State.IDLE
var facing = Vector2.RIGHT
var last_seen = Vector2.ZERO

var _state_timer = 0.0
var _attack_cd = 0.0
var _idle_timer = 0.0
var _patrol_index = 0
var _patrol_wait = 2.5
var _aim_time = 1.0

var patrol_points = []

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _alert_icon: Label
var _laser_line: Line2D

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

	_laser_line = Line2D.new()
	_laser_line.width = 1.0
	_laser_line.default_color = Color(1.0, 0.2, 0.2, 0.6)
	_laser_line.visible = false
	_laser_line.z_index = 5
	add_child(_laser_line)

func _physics_process(delta):
	if state == State.DEAD:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)

	var player = _find_player()

	match state:
		State.IDLE:
			_idle_timer -= delta
			_alert_icon.visible = false
			_laser_line.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 300) % 4
			if _idle_timer <= 0.0 and not patrol_points.is_empty():
				state = State.PATROL
			elif player and _can_see(player):
				_start_aiming(player)

		State.PATROL:
			_alert_icon.visible = false
			_laser_line.visible = false
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
				_start_aiming(player)

		State.AIMING:
			_state_timer -= delta
			_alert_icon.text = "X"
			_alert_icon.visible = true
			_alert_icon.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 150) % 4)
			if player:
				facing = (player.global_position - global_position).normalized()
				_laser_line.visible = true
				_laser_line.clear_points()
				_laser_line.add_point(Vector2.ZERO)
				_laser_line.add_point(facing * attack_range)
				_laser_line.modulate.a = 0.3 + (1.0 - _state_timer / _aim_time) * 0.7
				_sprite.flip_h = facing.x < 0.0
				if _state_timer <= 0.0:
					_shoot(player)
			else:
				state = State.RETREAT
				_state_timer = 2.0
				_laser_line.visible = false

		State.SHOOTING:
			_state_timer -= delta
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 24 + (int(Time.get_ticks_msec() / 80) % 4)
			if _state_timer <= 0.0:
				state = State.RETREAT
				_state_timer = 1.5
				_laser_line.visible = false

		State.RETREAT:
			_alert_icon.visible = false
			_laser_line.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 200) % 4)
			if patrol_points.is_empty():
				state = State.IDLE
				return
			var home = patrol_points[0]
			_move_towards(home, speed, delta)
			if global_position.distance_to(home) < 10.0:
				state = State.IDLE
				_idle_timer = _patrol_wait
			if player and _can_see(player):
				_start_aiming(player)

	var hp_frac = clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = hp_frac * 14.0
	_hp_bar_bg.visible = hp < max_hp
	_hp_bar.visible = hp < max_hp

func _start_aiming(player):
	last_seen = player.global_position
	state = State.AIMING
	_state_timer = _aim_time
	enemy_alerted.emit(self)
	AudioLib2D.play("detect")

func _shoot(player):
	state = State.SHOOTING
	_state_timer = 0.3
	_laser_line.visible = false

	# Muzzle flash
	_spawn_muzzle_flash()
	_spawn_bullet(player.global_position)

	AudioLib2D.play("attack_swing")

func _spawn_bullet(target_pos):
	var proj = Sprite2D.new()
	var img = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	for y in range(4):
		for x in range(4):
			if Vector2(x - 1.5, y - 1.5).length() <= 1.5:
				img.set_pixel(x, y, Color(1.0, 0.3, 0.2, 0.9))
	proj.texture = ImageTexture.create_from_image(img)
	proj.position = global_position
	proj.z_index = 6
	get_parent().add_child(proj)

	# Bullet trail particles
	var trail := CPUParticles2D.new()
	trail.one_shot = true
	trail.emitting = true
	trail.amount = 6
	trail.lifetime = 0.3
	trail.explosiveness = 0.7
	trail.direction = Vector2.ZERO
	trail.spread = 20.0
	trail.initial_velocity_min = 5.0
	trail.initial_velocity_max = 15.0
	trail.gravity = Vector2.ZERO
	trail.scale_amount_min = 0.2
	trail.scale_amount_max = 0.5
	trail.color = Color(1.0, 0.4, 0.2, 0.7)
	trail.position = global_position
	trail.z_index = 5
	get_parent().add_child(trail)
	get_tree().create_timer(0.4).timeout.connect(trail.queue_free)

	var dir = facing
	var tw = create_tween()
	tw.tween_property(proj, "position", proj.position + dir * attack_range, 0.2)
	tw.tween_callback(proj.free)

	await get_tree().create_timer(0.2).timeout
	var p = _find_player()
	if p and global_position.distance_to(p.global_position) <= attack_range:
		if p.has_method("take_damage"):
			p.take_damage(damage, dir)
			_spawn_impact_burst(p.global_position)

func take_damage(amount, from_dir = Vector2.ZERO):
	if state == State.DEAD:
		return

	hp -= amount

	_sprite.modulate = Color(1.5, 0.5, 0.5)
	var tw = create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	_spawn_damage_number(amount)

	velocity = from_dir.normalized() * 80.0

	if state in [State.IDLE, State.PATROL, State.RETREAT]:
		state = State.AIMING
		_state_timer = _aim_time * 0.5
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
	_laser_line.visible = false
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
	p.amount = 10
	p.lifetime = 0.6
	p.explosiveness = 0.9
	p.direction = Vector2.UP
	p.spread = 160.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 80.0
	p.gravity = Vector2(0, 60)
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.8
	p.color = Color(0.8, 0.3, 0.2, 0.8)
	p.position = Vector2(0, -4)
	p.z_index = 6
	add_child(p)
	get_tree().create_timer(0.7).timeout.connect(p.queue_free)

func _spawn_loot():
	GameManager.add_xp(xp_reward)
	var loot = Sprite2D.new()
	var img = Image.create(6, 6, false, Image.FORMAT_RGBA8)
	var loot_color = Color(0.8, 0.3, 0.2)
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
	var body_color = Color(0.3, 0.35, 0.4)
	for x in range(4, 8): for y in range(0, 3): img.set_pixel(x, y, body_color.lightened(0.1))
	for x in range(3, 9): for y in range(3, 10): img.set_pixel(x, y, body_color)
	for x in range(4, 6): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	for x in range(6, 8): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	img.set_pixel(5, 1, Color(0.2, 0.6, 0.9))
	img.set_pixel(6, 1, Color(0.2, 0.6, 0.9))
	return ImageTexture.create_from_image(img)


func _spawn_muzzle_flash() -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 10
	p.lifetime = 0.15
	p.explosiveness = 1.0
	p.direction = facing
	p.spread = 40.0
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 120.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.8
	p.color = Color(1.0, 0.5, 0.2, 0.9)
	p.position = facing * 8.0
	p.z_index = 7
	add_child(p)
	get_tree().create_timer(0.2).timeout.connect(p.queue_free)

	# Bright flash
	var flash := CPUParticles2D.new()
	flash.one_shot = true
	flash.emitting = true
	flash.amount = 4
	flash.lifetime = 0.1
	flash.explosiveness = 1.0
	flash.direction = Vector2.ZERO
	flash.spread = 180.0
	flash.initial_velocity_min = 5.0
	flash.initial_velocity_max = 15.0
	flash.gravity = Vector2.ZERO
	flash.scale_amount_min = 0.5
	flash.scale_amount_max = 1.2
	flash.color = Color(1.0, 0.9, 0.6, 1.0)
	flash.position = facing * 6.0
	flash.z_index = 8
	add_child(flash)
	get_tree().create_timer(0.15).timeout.connect(flash.queue_free)


func _spawn_impact_burst(pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 12
	p.lifetime = 0.3
	p.explosiveness = 0.9
	p.direction = -facing
	p.spread = 120.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.gravity = Vector2(0, 40)
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.8
	p.color = Color(1.0, 0.3, 0.1, 0.9)
	p.position = pos
	p.z_index = 6
	get_parent().add_child(p)
	get_tree().create_timer(0.4).timeout.connect(p.queue_free)

	# Sparks
	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.emitting = true
	sparks.amount = 8
	sparks.lifetime = 0.4
	sparks.explosiveness = 0.8
	sparks.direction = Vector2.UP
	sparks.spread = 140.0
	sparks.initial_velocity_min = 40.0
	sparks.initial_velocity_max = 90.0
	sparks.gravity = Vector2(0, 100)
	sparks.scale_amount_min = 0.2
	sparks.scale_amount_max = 0.5
	sparks.color = Color(1.0, 0.8, 0.3, 0.8)
	sparks.position = pos
	sparks.z_index = 6
	get_parent().add_child(sparks)
	get_tree().create_timer(0.5).timeout.connect(sparks.queue_free)
