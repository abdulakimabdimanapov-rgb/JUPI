extends CharacterBody2D


signal boss_died(boss_id: String)
signal boss_phase_changed(phase_name: String)
signal boss_attack_warning(attack_type: String)

var boss_id: String = ""
var display_name: String = ""
var era: String = "present"
var hp: float = 500.0
var max_hp: float = 500.0
var damage: float = 25.0
var movement_speed: float = 40.0
var attack_range: float = 24.0
var attack_cooldown: float = 1.5
var detection_range: float = 200.0
var xp_reward: float = 200.0
var currency_reward: int = 500
var phases: Array[Dictionary] = []
var attack_types: Array[String] = []
var loot_table: Dictionary = {}

enum State { IDLE, CHASE, ATTACK_WINDUP, ATTACK, COOLDOWN, SPECIAL, DEAD }
var state: int = State.IDLE
var current_phase: int = 0
var facing := Vector2.RIGHT

var _attack_cd := 0.0
var _windup_timer := 0.0
var _state_timer := 0.0
var _current_attack := ""

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _name_label: Label
var _phase_label: Label
var _warning_icon: Label

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 1

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	add_child(col)

	_sprite = Sprite2D.new()
	_sprite.texture = _boss_texture()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(1.5, 1.5)
	add_child(_sprite)

	_hp_bar_bg = ColorRect.new()
	_hp_bar_bg.color = Color(0.15, 0.08, 0.08, 0.8)
	_hp_bar_bg.position = Vector2(-16, -28)
	_hp_bar_bg.size = Vector2(32, 4)
	add_child(_hp_bar_bg)

	_hp_bar = ColorRect.new()
	_hp_bar.color = Color(0.8, 0.15, 0.1)
	_hp_bar.position = Vector2(-15, -27)
	_hp_bar.size = Vector2(30, 2)
	add_child(_hp_bar)

	_name_label = Label.new()
	_name_label.text = display_name
	_name_label.add_theme_font_size_override("font_size", 10)
	_name_label.position = Vector2(-20, -36)
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.2))
	add_child(_name_label)

	_phase_label = Label.new()
	_phase_label.add_theme_font_size_override("font_size", 8)
	_phase_label.position = Vector2(-20, -44)
	_phase_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(_phase_label)

	_warning_icon = Label.new()
	_warning_icon.text = "⚠"
	_warning_icon.add_theme_font_size_override("font_size", 16)
	_warning_icon.position = Vector2(-6, -50)
	_warning_icon.visible = false
	add_child(_warning_icon)

	_update_phase()

func setup(data: Dictionary) -> void:
	boss_id = data.get("id", "")
	display_name = data.get("name", "Boss")
	era = data.get("era", "present")
	hp = data.get("max_hp", 500.0)
	max_hp = data.get("max_hp", 500.0)
	damage = data.get("damage", 25.0)
	movement_speed = data.get("movement_speed", 40.0)
	attack_range = data.get("attack_range", 24.0)
	attack_cooldown = data.get("attack_cooldown", 1.5)
	detection_range = data.get("detection_range", 200.0)
	xp_reward = data.get("xp_reward", 200.0)
	currency_reward = data.get("currency_reward", 500)
	phases = data.get("phases", [])
	attack_types = data.get("attack_types", ["melee"])
	loot_table = data.get("loot", {})

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)
	var player := _find_player()

	match state:
		State.IDLE:
			_warning_icon.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 300) % 4
			if player and global_position.distance_to(player.global_position) < detection_range:
				state = State.CHASE

		State.CHASE:
			_warning_icon.visible = false
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 8 + (int(Time.get_ticks_msec() / 120) % 4)
			if player:
				var dist := global_position.distance_to(player.global_position)
				if dist <= attack_range and _attack_cd <= 0.0:
					_start_attack()
				else:
					var dir := (player.global_position - global_position).normalized()
					velocity = dir * movement_speed * _get_phase_stat("speed_mult")
					facing = dir
					move_and_slide()
					_sprite.flip_h = facing.x < 0.0

		State.ATTACK_WINDUP:
			_state_timer -= delta
			_warning_icon.visible = true
			_warning_icon.modulate.a = 0.5 + sin(_state_timer * 15.0) * 0.5
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 100) % 4)
			if player:
				facing = (player.global_position - global_position).normalized()
				_sprite.flip_h = facing.x < 0.0
			if _state_timer <= 0.0:
				state = State.ATTACK
				_execute_attack()

		State.ATTACK:
			_state_timer -= delta
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 24 + (int(Time.get_ticks_msec() / 80) % 4)
			if _state_timer <= 0.0:
				state = State.COOLDOWN
				_state_timer = attack_cooldown
				_attack_cd = attack_cooldown

		State.COOLDOWN:
			_warning_icon.visible = false
			_state_timer -= delta
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = int(Time.get_ticks_msec() / 250) % 4
			if _state_timer <= 0.0:
				state = State.CHASE

		State.SPECIAL:
			_state_timer -= delta
			if _sprite and _sprite.hframes >= 8:
				_sprite.frame = 16 + (int(Time.get_ticks_msec() / 90) % 4)
			if _state_timer <= 0.0:
				state = State.COOLDOWN
				_state_timer = attack_cooldown * 1.5

	var hp_frac := clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = hp_frac * 30.0

func _start_attack() -> void:
	var phase := _get_current_phase()
	var available: Array = phase.get("attacks", attack_types)
	_current_attack = available[randi() % available.size()]

	_warning_icon.visible = true
	_warning_icon.text = _get_attack_warning(_current_attack)
	boss_attack_warning.emit(_current_attack)
	AudioLib2D.play("enemy_alert")

	state = State.ATTACK_WINDUP
	_state_timer = 0.6

func _execute_attack() -> void:
	var player := _find_player()
	if not player:
		return

	var phase := _get_current_phase()
	var dmg: float = damage * _get_phase_stat("damage_mult")

	match _current_attack:
		"melee":
			_spawn_melee_slash()
			if global_position.distance_to(player.global_position) <= attack_range + 10.0:
				if player.has_method("take_damage"):
					player.take_damage(dmg, facing)
					AudioLib2D.play("attack_swing")
		"ranged":
			_spawn_cast_burst(Color(0.9, 0.3, 0.2), 10)
			_spawn_ranged_attack(player.global_position, dmg)
		"area":
			_spawn_area_burst()
			if global_position.distance_to(player.global_position) <= attack_range * 2.0:
				if player.has_method("take_damage"):
					player.take_damage(dmg * 0.8, facing)
					AudioLib2D.play("hurt")
		"dash":
			_spawn_dash_trail()
			velocity = facing * movement_speed * 3.0
			move_and_slide()
			if global_position.distance_to(player.global_position) <= attack_range + 15.0:
				if player.has_method("take_damage"):
					player.take_damage(dmg * 1.2, facing)
		"summon":
			_spawn_summon_burst()
			AudioLib2D.play("detect")
		"special":
			_spawn_special_burst()
			if global_position.distance_to(player.global_position) <= attack_range * 2.5:
				if player.has_method("take_damage"):
					player.take_damage(dmg * 1.5, facing)
					AudioLib2D.play("hurt")
	_state_timer = 0.3

func _spawn_ranged_attack(target_pos: Vector2, dmg: float) -> void:
	var proj := Sprite2D.new()
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	for y in range(4):
		for x in range(4):
			if Vector2(x - 1.5, y - 1.5).length() <= 1.5:
				img.set_pixel(x, y, Color(0.9, 0.3, 0.2, 0.9))
	proj.texture = ImageTexture.create_from_image(img)
	proj.position = global_position
	proj.z_index = 6
	get_parent().add_child(proj)

	var dir := (target_pos - global_position).normalized()
	var tw := create_tween()
	tw.tween_property(proj, "position", proj.position + dir * 80.0, 0.3)
	tw.tween_callback(proj.free)

	await get_tree().create_timer(0.3).timeout
	var player := _find_player()
	if player and global_position.distance_to(player.global_position) <= attack_range * 1.5:
		if player.has_method("take_damage"):
			player.take_damage(dmg, dir)

func take_damage(amount: float, from_dir: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return

	hp -= amount
	_sprite.modulate = Color(1.5, 0.4, 0.4)
	var tw := create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	velocity = from_dir.normalized() * 80.0

	var old_phase := current_phase
	_update_phase()
	if current_phase != old_phase:
		_on_phase_change()

	if state in [State.IDLE, State.CHASE]:
		state = State.CHASE

	if hp <= 0.0:
		_die()

func _update_phase() -> void:
	var hp_percent := hp / max_hp
	for i in range(phases.size()):
		if hp_percent > phases[i].get("hp_threshold", 0.0):
			current_phase = i
			break
	current_phase = mini(current_phase, phases.size() - 1)
	if not phases.is_empty():
		_phase_label.text = phases[current_phase].get("name", "Phase %d" % (current_phase + 1))

func _get_current_phase() -> Dictionary:
	if current_phase < phases.size():
		return phases[current_phase]
	return {}

func _get_phase_stat(stat: String) -> float:
	var phase := _get_current_phase()
	return phase.get(stat, 1.0)

func _on_phase_change() -> void:
	var phase_name: String = _get_current_phase().get("name", "???")
	boss_phase_changed.emit(phase_name)
	AudioLib2D.play("enemy_alert")
	_flash_screen(Color(0.8, 0.2, 0.1, 0.3))

func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	_sprite.modulate = Color(0.5, 0.3, 0.3, 0.5)
	_hp_bar.visible = false
	_hp_bar_bg.visible = false
	_name_label.visible = false
	_phase_label.visible = false
	_warning_icon.visible = false

	GameManager.add_xp(xp_reward)
	GameManager.add_currency(currency_reward)
	GameManager.set_world_flag("boss_%s_defeated" % boss_id, true)

	_spawn_death_burst()
	_flash_screen(Color(0.8, 0.2, 0.1, 0.4))

	if loot_table.has("unique_item"):
		_spawn_unique_loot(loot_table["unique_item"])

	boss_died.emit(boss_id)
	AudioLib2D.play("death")

	var tw := create_tween()
	tw.tween_property(_sprite, "modulate:a", 0.0, 2.0)
	tw.tween_property(_sprite, "position:y", _sprite.position.y + 12.0, 2.0)
	await tw.finished
	free()

func _spawn_unique_loot(item_id: String) -> void:
	var loot := Sprite2D.new()
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in range(8):
		for x in range(8):
			var d := Vector2(x - 3.5, y - 3.5).length()
			if d <= 3.5:
				img.set_pixel(x, y, Color(0.9, 0.7, 0.2, clampf(1.0 - d / 3.5, 0.3, 1.0)))
	loot.texture = ImageTexture.create_from_image(img)
	loot.position = Vector2(randf_range(-8, 8), randf_range(-4, 4))
	loot.z_index = 4
	get_parent().add_child(loot)

	var lbl := Label.new()
	lbl.text = item_id.replace("_", " ").to_upper()
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	lbl.z_index = 10
	loot.add_child(lbl)

	await get_tree().create_timer(1.5).timeout
	var player := _find_player()
	if player:
		var absorb := create_tween()
		absorb.tween_property(loot, "global_position", player.global_position, 0.4)
		absorb.parallel().tween_property(loot, "modulate:a", 0.0, 0.4)
		absorb.tween_callback(func():
			GameManager.collect_loot("boss_drop", 1.0)
			AudioLib2D.play("pickup")
			loot.queue_free()
		)
	else:
		loot.queue_free()

func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")

func _get_attack_warning(attack_type: String) -> String:
	match attack_type:
		"melee": return "⚔"
		"ranged": return "🎯"
		"area": return "💥"
		"dash": return "⚡"
		"summon": return "👤"
		"special": return "⭐"
	return "⚠"

func _spawn_melee_slash() -> void:
	var particles := GPUParticles2D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = 14
	particles.lifetime = 0.35
	particles.explosiveness = 0.9
	particles.direction = Vector2(facing.x, -1.0)
	particles.spread = 60.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 140.0
	particles.gravity = Vector2(0, 60)
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	mat.emission_ring_axis = Vector3(facing.x, 0, 0)
	mat.emission_ring_height = 0.5
	mat.emission_ring_inner_radius = 4.0
	mat.emission_ring_radius = 6.0
	mat.scale_min = 1.0
	mat.scale_max = 1.8
	mat.color = Color(0.95, 0.4, 0.15)
	particles.process_material = mat
	particles.position = Vector2(6 * facing.x, -4)
	add_child(particles)
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func _spawn_cast_burst(color: Color, count: int) -> void:
	var particles := GPUParticles2D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = count
	particles.lifetime = 0.4
	particles.explosiveness = 0.85
	particles.spread = 180.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 70.0
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 6.0
	mat.scale_min = 0.8
	mat.scale_max = 1.5
	mat.color = color
	particles.process_material = mat
	particles.position = Vector2(0, -8)
	add_child(particles)
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func _spawn_area_burst() -> void:
	for i in range(8):
		var angle := i * TAU / 8.0
		var particles := GPUParticles2D.new()
		particles.one_shot = true
		particles.emitting = true
		particles.amount = 6
		particles.lifetime = 0.5
		particles.explosiveness = 0.9
		particles.direction = Vector2(cos(angle), sin(angle))
		particles.spread = 15.0
		particles.initial_velocity_min = 60.0
		particles.initial_velocity_max = 100.0
		particles.gravity = Vector2(0, 40)
		var mat := ParticleProcessMaterial.new()
		mat.scale_min = 1.0
		mat.scale_max = 2.0
		mat.color = Color(1.0, 0.5, 0.1)
		particles.process_material = mat
		particles.position = Vector2(cos(angle) * 8, sin(angle) * 8)
		add_child(particles)
		await get_tree().create_timer(particles.lifetime + 0.1).timeout
		particles.queue_free()

func _spawn_dash_trail() -> void:
	var trails: Array[GPUParticles2D] = []
	for i in range(6):
		var trail := GPUParticles2D.new()
		trail.one_shot = true
		trail.emitting = true
		trail.amount = 4
		trail.lifetime = 0.4
		trail.explosiveness = 0.95
		trail.spread = 40.0
		trail.initial_velocity_min = 10.0
		trail.initial_velocity_max = 30.0
		var mat := ParticleProcessMaterial.new()
		mat.scale_min = 0.6
		mat.scale_max = 1.2
		mat.color = Color(0.9, 0.6, 0.2)
		trail.process_material = mat
		trail.position = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		add_child(trail)
		trails.append(trail)
		await get_tree().create_timer(0.08).timeout
	await get_tree().create_timer(0.5).timeout
	for t in trails:
		if is_instance_valid(t):
			t.queue_free()

func _spawn_summon_burst() -> void:
	for i in range(4):
		var angle := i * TAU / 4.0
		var particles := GPUParticles2D.new()
		particles.one_shot = true
		particles.emitting = true
		particles.amount = 8
		particles.lifetime = 0.6
		particles.explosiveness = 0.8
		particles.direction = Vector2(cos(angle), sin(angle))
		particles.spread = 25.0
		particles.initial_velocity_min = 20.0
		particles.initial_velocity_max = 50.0
		particles.gravity = Vector2(0, -30)
		var mat := ParticleProcessMaterial.new()
		mat.scale_min = 0.8
		mat.scale_max = 1.6
		mat.color = Color(0.4, 0.2, 0.6)
		particles.process_material = mat
		particles.position = Vector2(cos(angle) * 12, sin(angle) * 12)
		add_child(particles)
		await get_tree().create_timer(particles.lifetime + 0.1).timeout
		particles.queue_free()

func _spawn_special_burst() -> void:
	for ring in range(3):
		await get_tree().create_timer(0.12).timeout
		var radius := 10.0 + ring * 10.0
		var ring_color := Color(0.9, 0.15, 0.4) if ring % 2 == 0 else Color(0.6, 0.1, 0.8)
		for i in range(12):
			var angle := i * TAU / 12.0
			var particles := GPUParticles2D.new()
			particles.one_shot = true
			particles.emitting = true
			particles.amount = 5
			particles.lifetime = 0.5
			particles.explosiveness = 0.9
			particles.direction = Vector2(cos(angle), sin(angle))
			particles.spread = 12.0
			particles.initial_velocity_min = 40.0
			particles.initial_velocity_max = 80.0
			var mat := ParticleProcessMaterial.new()
			mat.scale_min = 1.2
			mat.scale_max = 2.2
			mat.color = ring_color
			particles.process_material = mat
			particles.position = Vector2(cos(angle) * radius, sin(angle) * radius)
			add_child(particles)
			await get_tree().create_timer(particles.lifetime + 0.1).timeout
			particles.queue_free()

func _spawn_death_burst() -> void:
	for i in range(16):
		var angle := i * TAU / 16.0
		var particles := GPUParticles2D.new()
		particles.one_shot = true
		particles.emitting = true
		particles.amount = 6
		particles.lifetime = 0.8
		particles.explosiveness = 0.85
		particles.direction = Vector2(cos(angle), sin(angle))
		particles.spread = 10.0
		particles.initial_velocity_min = 50.0
		particles.initial_velocity_max = 100.0
		particles.gravity = Vector2(0, 80)
		var mat := ParticleProcessMaterial.new()
		mat.scale_min = 1.0
		mat.scale_max = 2.5
		mat.color = Color(0.9, 0.2, 0.1) if i % 3 == 0 else Color(1.0, 0.6, 0.1)
		particles.process_material = mat
		particles.position = Vector2(randf_range(-6, 6), randf_range(-6, 6))
		add_child(particles)
		await get_tree().create_timer(particles.lifetime + 0.1).timeout
		particles.queue_free()

func _flash_screen(color: Color) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var root := tree.root
	if root == null:
		return
	var flash := ColorRect.new()
	flash.color = color
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 100
	var layer := CanvasLayer.new()
	layer.name = "BossFlash"
	layer.layer = 20
	layer.add_child(flash)
	root.add_child(layer)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.4)
	tw.tween_callback(layer.free)

func _boss_texture() -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	match boss_id:
		"corporate_enforcer":
			for x in range(3, 13): for y in range(2, 12): img.set_pixel(x, y, Color(0.35, 0.38, 0.42))
			for x in range(5, 11): for y in range(0, 4): img.set_pixel(x, y, Color(0.4, 0.43, 0.48))
			for x in range(6, 10): img.set_pixel(x, 2, Color(0.2, 0.6, 0.9))
		"warlord":
			for x in range(2, 14): for y in range(2, 13): img.set_pixel(x, y, Color(0.5, 0.35, 0.2))
			for x in range(4, 12): for y in range(0, 4): img.set_pixel(x, y, Color(0.45, 0.3, 0.15))
			for x in range(5, 11): img.set_pixel(x, 5, Color(0.7, 0.5, 0.2))
		"cyber_guardian":
			for x in range(3, 13): for y in range(1, 12): img.set_pixel(x, y, Color(0.2, 0.3, 0.5))
			for x in range(5, 11): for y in range(0, 3): img.set_pixel(x, y, Color(0.1, 0.5, 0.8))
			for x in range(6, 10): img.set_pixel(x, 2, Color(0.0, 0.9, 1.0))
		"time_devourer":
			for x in range(2, 14): for y in range(1, 14): img.set_pixel(x, y, Color(0.4, 0.1, 0.3))
			for x in range(4, 12): for y in range(3, 8): img.set_pixel(x, y, Color(0.6, 0.15, 0.45))
			img.set_pixel(7, 4, Color(0.9, 0.2, 0.5))
			img.set_pixel(8, 4, Color(0.9, 0.2, 0.5))
	return ImageTexture.create_from_image(img)
