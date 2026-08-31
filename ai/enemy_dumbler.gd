extends CharacterBody2D

signal enemy_died(enemy: Node2D)
signal enemy_alerted(enemy: Node2D)

var enemy_type = "dumbler"
var hp = 150.0
var max_hp = 150.0
var damage = 25.0
var speed = 25.0
var chase_speed = 35.0
var detection_range = 80.0
var attack_range = 20.0
var attack_cd = 2.0
var xp_reward = 50.0
var loot_table = {"hp": 0.4, "energy": 0.2, "currency": 0.3, "rare": 0.1}

enum State { IDLE, PATROL, CHARGE, ATTACK, RETREAT, DEAD }
var state = State.IDLE
var facing = Vector2.RIGHT
var last_seen = Vector2.ZERO

var _state_timer = 0.0
var _attack_cd = 0.0
var _idle_timer = 0.0
var _patrol_index = 0
var _patrol_wait = 2.0
var _charge_speed = 200.0

var patrol_points = []

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _alert_icon: Label
var _charge_indicator: Label

func _ready():
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 7.0
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
	_hp_bar_bg.position = Vector2(-10, -18)
	_hp_bar_bg.size = Vector2(20, 3)
	add_child(_hp_bar_bg)

	_hp_bar = ColorRect.new()
	_hp_bar.color = Color(0.80, 0.20, 0.20)
	_hp_bar.position = Vector2(-9, -17)
	_hp_bar.size = Vector2(18, 1)
	add_child(_hp_bar)

	_alert_icon = Label.new()
	_alert_icon.add_theme_font_size_override("font_size", 12)
	_alert_icon.position = Vector2(-5, -24)
	_alert_icon.visible = false
	add_child(_alert_icon)

	_charge_indicator = Label.new()
	_charge_indicator.text = "!"
	_charge_indicator.add_theme_font_size_override("font_size", 16)
	_charge_indicator.position = Vector2(-6, -30)
	_charge_indicator.visible = false
	add_child(_charge_indicator)

func _physics_process(delta):
	if state == State.DEAD:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)

	var player = _find_player()

	match state:
		State.IDLE:
			_idle_timer -= delta
			_alert_icon.visible = false
			_charge_indicator.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 300) % 4
			if _idle_timer <= 0.0 and not patrol_points.is_empty():
				state = State.PATROL
			elif player and _can_see(player):
				_start_charge(player)

		State.PATROL:
			_alert_icon.visible = false
			_charge_indicator.visible = false
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
				_start_charge(player)

		State.CHARGE:
			_charge_indicator.visible = true
			_charge_indicator.modulate.a = 0.5 + sin(_state_timer * 10.0) * 0.5
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 80) % 4)
			_state_timer -= delta
			if player:
				facing = (player.global_position - global_position).normalized()
			velocity = facing * _charge_speed
			move_and_slide()
			_sprite.flip_h = facing.x < 0.0
			for e in get_tree().get_nodes_in_group("player"):
				if global_position.distance_to(e.global_position) <= attack_range + 10.0:
					if e.has_method("take_damage"):
						e.take_damage(damage, facing)
						AudioLib2D.play("hurt")
					state = State.RETREAT
					_state_timer = 1.5
					_charge_indicator.visible = false
					return
			if _state_timer <= 0.0:
				state = State.RETREAT
				_state_timer = 1.0
				_charge_indicator.visible = false

		State.RETREAT:
			_alert_icon.visible = false
			_charge_indicator.visible = false
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
				_start_charge(player)

	var hp_frac = clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = hp_frac * 18.0
	_hp_bar_bg.visible = hp < max_hp
	_hp_bar.visible = hp < max_hp

func _start_charge(player):
	last_seen = player.global_position
	facing = (player.global_position - global_position).normalized()
	state = State.CHARGE
	_state_timer = 1.0
	enemy_alerted.emit(self)
	AudioLib2D.play("enemy_alert")

func take_damage(amount, from_dir = Vector2.ZERO):
	if state == State.DEAD:
		return

	hp -= amount

	_sprite.modulate = Color(1.5, 0.5, 0.5)
	var tw = create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	_spawn_damage_number(amount)

	velocity = from_dir.normalized() * 60.0

	if state in [State.IDLE, State.PATROL, State.RETREAT]:
		state = State.CHARGE
		_state_timer = 1.0
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
	_charge_indicator.visible = false
	enemy_died.emit(self)

	_spawn_death_particles()
	_spawn_loot()

	var tw = create_tween()
	tw.tween_property(_sprite, "modulate:a", 0.0, 1.5)
	tw.tween_property(_sprite, "position:y", _sprite.position.y + 8.0, 1.5)
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
	p.amount = 15
	p.lifetime = 0.8
	p.explosiveness = 0.8
	p.direction = Vector2.UP
	p.spread = 120.0
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 50.0
	p.gravity = Vector2(0, 80)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.2
	p.color = Color(0.5, 0.4, 0.3, 0.8)
	p.position = Vector2(0, -4)
	p.z_index = 6
	add_child(p)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _spawn_loot():
	GameManager.add_xp(xp_reward)
	var loot_types = ["hp", "energy", "currency", "rare"]
	var loot_chances = [loot_table.get("hp", 0.4), loot_table.get("energy", 0.2),
						loot_table.get("currency", 0.3), loot_table.get("rare", 0.1)]
	var roll = randf()
	var cumulative = 0.0
	var chosen_type = "currency"
	for i in range(loot_types.size()):
		cumulative += loot_chances[i]
		if roll < cumulative:
			chosen_type = loot_types[i]
			break
	var loot = Sprite2D.new()
	var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	var loot_color = Color(0.3, 0.8, 0.5)
	match chosen_type:
		"hp": loot_color = Color(0.9, 0.2, 0.2)
		"energy": loot_color = Color(0.2, 0.5, 0.9)
		"currency": loot_color = Color(0.9, 0.8, 0.2)
		"rare": loot_color = Color(0.8, 0.3, 0.9)
	for y in range(8):
		for x in range(8):
			var d = Vector2(x - 3.5, y - 3.5).length()
			if d <= 3.5:
				var c = loot_color * Color(1, 1, 1, clampf(1.0 - d / 3.5, 0.3, 1.0))
				img.set_pixel(x, y, c)
	loot.texture = ImageTexture.create_from_image(img)
	loot.position = Vector2(randf_range(-8, 8), randf_range(-4, 4))
	loot.z_index = 4
	add_child(loot)
	var tw = create_tween().set_loops(3)
	tw.tween_property(loot, "scale", Vector2(1.3, 1.3), 0.3).set_trans(Tween.TRANS_SINE)
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
	var img = Image.create(14, 16, false, Image.FORMAT_RGBA8)
	var body_color = Color(0.45, 0.35, 0.25)
	for x in range(3, 11): for y in range(0, 4): img.set_pixel(x, y, body_color.lightened(0.1))
	for x in range(2, 12): for y in range(4, 12): img.set_pixel(x, y, body_color)
	for x in range(3, 6): for y in range(12, 16): img.set_pixel(x, y, body_color.darkened(0.2))
	for x in range(8, 11): for y in range(12, 16): img.set_pixel(x, y, body_color.darkened(0.2))
	img.set_pixel(5, 1, Color(0.9, 0.2, 0.1))
	img.set_pixel(8, 1, Color(0.9, 0.2, 0.1))
	return ImageTexture.create_from_image(img)
