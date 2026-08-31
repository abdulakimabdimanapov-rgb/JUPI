extends CharacterBody2D

signal enemy_died(enemy: Node2D)
signal enemy_alerted(enemy: Node2D)

var enemy_type = "guard"

var hp: float = 50.0
var max_hp: float = 50.0
var damage: float = 12.0
var speed: float = 45.0
var chase_speed: float = 75.0
var detection_range: float = 90.0
var attack_range: float = 18.0
var attack_cd: float = 1.0
var xp_reward: float = 25.0
var loot_table: Dictionary = {"hp": 0.3, "energy": 0.2, "currency": 0.4, "rare": 0.05}

enum State { IDLE, PATROL, SUSPICIOUS, ALERT, SEARCH, CHASE, ATTACK, RETREAT, DEAD }
var state: int = State.IDLE
var facing := Vector2.RIGHT
var last_seen := Vector2.ZERO

var _state_timer := 0.0
var _attack_cd := 0.0
var _idle_timer := 0.0
var _patrol_index := 0
var _patrol_wait := 1.5
var _reaction_delay := 0.0
var _wall_avoidance_timer := 0.0

var patrol_points: Array = []

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _alert_icon: Label

var _alert_sprite: Sprite2D

func _ready():
	# setup collision
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)

	_sprite = Sprite2D.new()
	_setup_sprite_texture()
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

	_alert_sprite = Sprite2D.new()
	_alert_sprite.position = Vector2(0, -18)
	_alert_sprite.scale = Vector2(0.7, 0.7)
	_alert_sprite.visible = false
	_alert_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_alert_sprite)

	_alert_icon = Label.new()
	_alert_icon.add_theme_font_size_override("font_size", 10)
	_alert_icon.position = Vector2(-4, -20)
	_alert_icon.visible = false
	add_child(_alert_icon)

func _setup_sprite_texture():
	var sheet_path := "res://assets/2d/enemies/%s_sheet.png" % enemy_type
	if ResourceLoader.exists(sheet_path):
		_sprite.texture = load(sheet_path)
		_sprite.hframes = 8
		_sprite.vframes = 4
		_sprite.frame = 0
	else:
		_sprite.texture = _enemy_texture()

func _physics_process(delta):
	if state == State.DEAD:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)
	_process_enemy_effects(delta)

	# freeze effect: enemy can't act
	if _enemy_effects.has("freeze"):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# slow effect: reduce movement speed
	var speed_mult := 1.0
	if _enemy_effects.has("slow"):
		speed_mult = 0.6

	var player: Node2D = _find_player()

	match state:
		State.IDLE:
			_idle_timer -= delta
			_hide_emote()
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 300) % 4
			if _idle_timer <= 0.0 and not patrol_points.is_empty():
				state = State.PATROL
			elif player and _can_see(player):
				_alert(player)

		State.PATROL:
			_hide_emote()
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 180) % 4)
			if patrol_points.is_empty():
				state = State.IDLE
				return
			var target: Vector2 = patrol_points[_patrol_index]
			var to: Vector2 = target - global_position
			if to.length() < 8.0:
				_patrol_index = (_patrol_index + 1) % patrol_points.size()
				_idle_timer = _patrol_wait
				state = State.IDLE
				velocity = Vector2.ZERO
			else:
				velocity = to.normalized() * speed * speed_mult
				facing = to.normalized()
				move_and_slide()
			if player and _can_see(player):
				_alert(player)

		State.SUSPICIOUS:
			_state_timer -= delta
			_show_emote("dots", "?", Color(0.95, 0.80, 0.25))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 250) % 4
			if player:
				face_point(player.global_position)
				if _can_see(player):
					if _state_timer <= 0.0:
						state = State.ALERT
						enemy_alerted.emit(self)
						AudioLib2D.play("detect")
				else:
					state = State.SEARCH
					_state_timer = 2.5
					AudioLib2D.play("lost")

		State.ALERT:
			_state_timer -= delta
			_show_emote("alert", "!!", Color(1.0, 0.3, 0.2))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 120) % 4)
			if player and _can_see(player):
				last_seen = player.global_position
				_state_timer = 1.5
				if global_position.distance_to(player.global_position) <= attack_range:
					state = State.ATTACK
				else:
					velocity = (player.global_position - global_position).normalized() * chase_speed * speed_mult
					facing = velocity.normalized()
					move_and_slide()
			elif _state_timer <= 0.0:
				state = State.SEARCH
				_state_timer = 3.0

		State.SEARCH:
			_state_timer -= delta
			_show_emote("question", "?", Color(0.8, 0.7, 0.3))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 200) % 4)
			_move_towards(last_seen, speed * 0.7, delta)
			if player and _can_see(player):
				state = State.ALERT
				_state_timer = 1.5
			elif _state_timer <= 0.0 or global_position.distance_to(last_seen) < 12.0:
				state = State.RETREAT

		State.CHASE:
			_show_emote("anger", "!", Color(1.0, 0.3, 0.2))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 120) % 4)
			if player and _can_see(player):
				last_seen = player.global_position
				var dist := global_position.distance_to(player.global_position)
				if dist <= attack_range:
					state = State.ATTACK
				else:
					velocity = (player.global_position - global_position).normalized() * chase_speed * speed_mult
					facing = velocity.normalized()
					move_and_slide()
			else:
				state = State.SEARCH
				_state_timer = 2.5

		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
			_show_emote("anger", "!", Color(1.0, 0.2, 0.15))
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 100) % 4)
			if _attack_cd <= 0.0:
				if player and global_position.distance_to(player.global_position) <= attack_range + 6.0:
					if player.has_method("take_damage"):
						player.take_damage(damage, (player.global_position - global_position).normalized())
						# status effect chance based on enemy type
						if player.has_method("apply_status_effect"):
							match enemy_type:
								"heavy":
									if randf() < 0.20:
										player.apply_status_effect("burn", 3.0)
								"fast":
									if randf() < 0.25:
										player.apply_status_effect("bleed", 5.0)
								"guard":
									if randf() < 0.15:
										player.apply_status_effect("slow", 4.0)
					AudioLib2D.play("hurt")
					_shake_on_attack()
				_attack_cd = attack_cd
			if not player or global_position.distance_to(player.global_position) > attack_range + 10.0:
				state = State.CHASE

		State.RETREAT:
			_hide_emote()
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 180) % 4)
			if patrol_points.is_empty():
				state = State.IDLE
				return
			var home: Vector2 = patrol_points[0]
			_move_towards(home, speed, delta)
			if global_position.distance_to(home) < 10.0:
				state = State.IDLE
				_idle_timer = _patrol_wait
			if player and _can_see(player):
				_alert(player)

	_update_hp_bar()

func _show_emote(emote_name: String, fallback_text: String, color: Color) -> void:
	var path := "res://assets/2d/hud/emotes/%s.png" % emote_name
	if ResourceLoader.exists(path):
		_alert_sprite.texture = load(path)
		_alert_sprite.visible = true
		_alert_icon.visible = false
	else:
		_alert_sprite.visible = false
		_alert_icon.text = fallback_text
		_alert_icon.visible = true
		_alert_icon.add_theme_color_override("font_color", color)

func _hide_emote() -> void:
	if _alert_sprite:
		_alert_sprite.visible = false
	if _alert_icon:
		_alert_icon.visible = false

func _update_hp_bar() -> void:
	var hp_frac := clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = hp_frac * 14.0
	_hp_bar_bg.visible = hp < max_hp
	_hp_bar.visible = hp < max_hp

func _alert(player):
	last_seen = player.global_position
	state = State.SUSPICIOUS
	_state_timer = 0.8
	face_point(player.global_position)

func take_damage(amount, from_dir = Vector2.ZERO):
	if state == State.DEAD:
		return

	hp -= amount

	_sprite.modulate = Color(1.5, 0.5, 0.5)
	var tw := create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	_spawn_damage_number(amount)

	_knockback(from_dir)

	if state in [State.IDLE, State.PATROL, State.RETREAT]:
		state = State.ALERT
		_state_timer = 1.5
		enemy_alerted.emit(self)
	elif state in [State.SUSPICIOUS, State.SEARCH]:
		state = State.CHASE

	if hp <= 0.0:
		_die()

func _die():
	state = State.DEAD
	velocity = Vector2.ZERO
	_sprite.modulate = Color(0.4, 0.4, 0.5, 0.5)
	_hp_bar.visible = false
	_hp_bar_bg.visible = false
	_alert_icon.visible = false
	enemy_died.emit(self)

	_spawn_death_particles()

	_spawn_loot()

	var tw := create_tween()
	tw.tween_property(_sprite, "modulate:a", 0.0, 1.5)
	tw.tween_property(_sprite, "position:y", _sprite.position.y + 8.0, 1.5)
	await tw.finished
	free()

func _knockback(dir):
	velocity = dir.normalized() * 100.0

var _enemy_effects: Dictionary = {}

func apply_status_effect(effect: String, duration: float) -> void:
	if state == State.DEAD:
		return
	_enemy_effects[effect] = duration
	# visual + audio feedback on enemy
	match effect:
		"poison":
			_sprite.modulate = Color(0.5, 1.0, 0.4)
			_spawn_effect_label("PSN", Color(0.3, 0.8, 0.2))
			AudioLib2D.play("status_poison")
		"burn":
			_sprite.modulate = Color(1.0, 0.6, 0.2)
			_spawn_effect_label("BRN", Color(1.0, 0.4, 0.1))
			AudioLib2D.play("status_burn")
		"slow":
			_spawn_effect_label("SLOW", Color(0.4, 0.5, 0.9))
			AudioLib2D.play("status_slow")
		"freeze":
			_sprite.modulate = Color(0.5, 0.7, 1.0)
			_spawn_effect_label("FROZEN", Color(0.3, 0.6, 1.0))
			AudioLib2D.play("status_freeze")
			velocity = Vector2.ZERO
		"bleed":
			_spawn_effect_label("BLD", Color(0.9, 0.1, 0.1))
			AudioLib2D.play("status_bleed")

var _effect_tick_timer := 0.0

func _process_enemy_effects(delta: float) -> void:
	if _enemy_effects.is_empty() or state == State.DEAD:
		return
	# tick damage every 0.5s
	_effect_tick_timer -= delta
	if _effect_tick_timer <= 0.0:
		_effect_tick_timer = 0.5
		for effect in _enemy_effects:
			var info: Dictionary = StatusEffectSystem.get_effect_info(effect)
			var dmg: float = info.get("damage_per_tick", 0.0)
			if dmg > 0.0:
				hp -= dmg
				_spawn_damage_number(dmg)
				AudioLib2D.play("status_tick", -16.0)
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

func _spawn_effect_label(text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = position + Vector2(-8, -20)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 14.0, 0.7)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.7)
	tw.tween_callback(lbl.free)

func _can_see(player):
	if not player.get("alive"):
		return false
	var dist := global_position.distance_to(player.global_position)
	if dist > detection_range:
		return false
	var q := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
	var result := get_world_2d().direct_space_state.intersect_ray(q)
	if result.is_empty():
		return true
	return global_position.distance_to(result.position) > dist - 5.0

func _find_player():
	return get_tree().get_first_node_in_group("player")

func _move_towards(target, spd, delta):
	var to: Vector2 = target - global_position
	if to.length() < 5.0:
		velocity = Vector2.ZERO
	else:
		var desired: Vector2 = to.normalized() * spd
		_wall_avoidance_timer = maxf(0.0, _wall_avoidance_timer - delta)
		if velocity.length() < spd * 0.3 and desired.length() > 0 and _wall_avoidance_timer <= 0.0:
			var perp1: Vector2 = desired.orthogonal().normalized()
			var perp2: Vector2 = -perp1
			var test_pos1: Vector2 = global_position + perp1 * 12.0
			var test_pos2: Vector2 = global_position + perp2 * 12.0
			var q1 := PhysicsRayQueryParameters2D.create(global_position, test_pos1, 1)
			var q2 := PhysicsRayQueryParameters2D.create(global_position, test_pos2, 1)
			var r1 := get_world_2d().direct_space_state.intersect_ray(q1)
			var r2 := get_world_2d().direct_space_state.intersect_ray(q2)
			if r1.is_empty() and not r2.is_empty():
				desired = perp1 * spd
			elif not r1.is_empty() and r2.is_empty():
				desired = perp2 * spd
			elif r1.is_empty() and r2.is_empty():
				desired = perp1 * spd
			facing = desired.normalized()
			_wall_avoidance_timer = 0.3
		else:
			facing = desired.normalized()
		velocity = desired
		facing = desired.normalized()
	move_and_slide()
	_sprite.flip_h = facing.x < 0.0

func face_point(p):
	var d: Vector2 = p - global_position
	if d.length() > 1.0:
		facing = d.normalized()

func _shake_on_attack():
	var player: Node2D = _find_player()
	if player and player.has_method("shake"):
		player.shake(1.5)

func _spawn_damage_number(amount):
	var lbl := Label.new()
	lbl.text = "-" + str(int(amount))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl.position = Vector2(-8, -18)
	lbl.z_index = 10
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 16.0, 0.4)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.tween_callback(lbl.free)

func _spawn_death_particles():
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 12
	p.lifetime = 0.6
	p.explosiveness = 0.8
	p.direction = Vector2.UP
	p.spread = 140.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 60.0
	p.gravity = Vector2(0, 80)
	p.scale_amount_min = 0.4
	p.scale_amount_max = 1.0
	match enemy_type:
		"guard": p.color = Color(0.6, 0.5, 0.4, 0.8)
		"fast": p.color = Color(0.4, 0.7, 0.4, 0.8)
		"heavy": p.color = Color(0.6, 0.55, 0.5, 0.8)
		_: p.color = Color(0.6, 0.6, 0.6, 0.8)
	p.position = Vector2(0, -4)
	p.z_index = 6
	add_child(p)
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)

func _spawn_loot():
	GameManager.add_xp(xp_reward)
	var loot_types = ["hp", "energy", "currency", "rare"]
	var loot_chances = [loot_table.get("hp", 0.3), loot_table.get("energy", 0.2),
						loot_table.get("currency", 0.4), loot_table.get("rare", 0.05)]
	var roll := randf()
	var cumulative := 0.0
	var chosen_type := "currency"
	for i in range(loot_types.size()):
		cumulative += loot_chances[i]
		if roll < cumulative:
			chosen_type = loot_types[i]
			break

	var loot := Sprite2D.new()
	var item_path := "res://assets/2d/items/%s.png" % chosen_type
	if ResourceLoader.exists(item_path):
		loot.texture = load(item_path)
		loot.scale = Vector2(0.8, 0.8)
	else:
		var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
		var loot_color := Color(0.3, 0.8, 0.5)
		match chosen_type:
			"hp": loot_color = Color(0.9, 0.2, 0.2)
			"energy": loot_color = Color(0.2, 0.5, 0.9)
			"currency": loot_color = Color(0.9, 0.8, 0.2)
			"rare": loot_color = Color(0.8, 0.3, 0.9)
		for y in range(6):
			for x in range(6):
				var d := Vector2(x - 2.5, y - 2.5).length()
				if d <= 2.5:
					var c := loot_color * Color(1, 1, 1, clampf(1.0 - d / 2.5, 0.3, 1.0))
					img.set_pixel(x, y, c)
		loot.texture = ImageTexture.create_from_image(img)

	loot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	loot.position = Vector2(randf_range(-6, 6), randf_range(-4, 4))
	loot.z_index = 4
	loot.set_meta("loot_type", chosen_type)
	add_child(loot)

	var tw := create_tween().set_loops(3)
	tw.tween_property(loot, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_SINE)
	tw.tween_property(loot, "scale", Vector2(0.7, 0.7), 0.3).set_trans(Tween.TRANS_SINE)
	await tw.finished
	var player: Node2D = _find_player()
	if player:
		var absorb := create_tween()
		absorb.tween_property(loot, "global_position", player.global_position, 0.3)
		absorb.parallel().tween_property(loot, "modulate:a", 0.0, 0.3)
		absorb.tween_callback(func():
			_apply_loot_effect(chosen_type, player)
			GameManager.collect_loot(chosen_type, 1.0)
			loot.queue_free()
		)
	else:
		loot.queue_free()

func _apply_loot_effect(loot_type, player):
	match loot_type:
		"hp":
			if player.has_method("take_damage"):
				var heal_amount := 15.0
				if "hp" in player:
					player.hp = minf(player.max_hp, player.hp + heal_amount)
					if "hp_changed" in player:
						player.hp_changed.emit(player.hp, player.max_hp)
		"energy":
			if "energy" in player:
				player.energy = minf(player.max_energy, player.energy + 25.0)
				if "energy_changed" in player:
					player.energy_changed.emit(player.energy)
		"currency":
			GameManager.add_currency(randi_range(5, 20))
		"rare":
			GameManager.add_currency(randi_range(50, 100))
			GameManager.add_xp(50.0)
	var lbl := Label.new()
	match loot_type:
		"hp": lbl.text = "+HP"; lbl.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		"energy": lbl.text = "+EN"; lbl.add_theme_color_override("font_color", Color(0.3, 0.6, 0.9))
		"currency": lbl.text = "+$"; lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
		"rare": lbl.text = "RARE! +$$"; lbl.add_theme_color_override("font_color", Color(0.8, 0.3, 0.9))
		_: lbl.text = "+?"
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.z_index = 10
	lbl.position = Vector2(-8, -16)
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 14.0, 0.4)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.tween_callback(lbl.free)

func _enemy_texture():
	match enemy_type:
		"fast":
			if ResourceLoader.exists("res://assets/2d/enemies/fast.png"):
				return load("res://assets/2d/enemies/fast.png")
		"heavy":
			if ResourceLoader.exists("res://assets/2d/enemies/heavy.png"):
				return load("res://assets/2d/enemies/heavy.png")
		_:
			if ResourceLoader.exists("res://assets/2d/enemies/guard.png"):
				return load("res://assets/2d/enemies/guard.png")

	var img := Image.create(12, 14, false, Image.FORMAT_RGBA8)
	var body_color := Color(0.5, 0.35, 0.3)
	match enemy_type:
		"fast": body_color = Color(0.3, 0.45, 0.3)
		"heavy": body_color = Color(0.45, 0.40, 0.35)
	for x in range(4, 8): for y in range(0, 3): img.set_pixel(x, y, body_color.lightened(0.1))
	for x in range(3, 9): for y in range(3, 10): img.set_pixel(x, y, body_color)
	for x in range(4, 6): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	for x in range(6, 8): for y in range(10, 14): img.set_pixel(x, y, body_color.darkened(0.15))
	img.set_pixel(5, 1, Color(0.9, 0.2, 0.1))
	img.set_pixel(6, 1, Color(0.9, 0.2, 0.1))
	return ImageTexture.create_from_image(img)
