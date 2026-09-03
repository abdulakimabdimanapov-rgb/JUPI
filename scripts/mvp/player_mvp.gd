extends CharacterBody2D
class_name PlayerMVP

signal hp_changed(hp: float, max_hp: float)
signal xp_changed(xp: float)
signal level_up(new_level: int)
signal player_died()
signal weapon_changed(weapon: String)

# ── Movement ────────────────────────────────────────────────────────────────
const SPEED := 150.0
const SPRINT_MULT := 1.5
const ACCEL := 900.0
const FRICTION := 1000.0
const DASH_SPEED := 300.0
const DASH_DURATION := 0.15
const DASH_CD := 0.6
const WORLD_MARGIN := 16.0  # keep the player inside the walkable floor (== tile size)

# ── Combat ──────────────────────────────────────────────────────────────────
const ATTACK_CD := 0.35
const CRIT_CHANCE := 0.15
const CRIT_MULT := 2.0
const COMBO_WINDOW := 0.6
const COMBO_MULT := [1.0, 1.25, 1.6]

# ── World ──────────────────────────────────────────────────────────────────
## Rectangle (global pixels) the player may move inside. Set by the GameWorld
## so the map size lives in one place; default matches the current 40x30 tile map.
var world_rect := Rect2(Vector2.ZERO, Vector2(640.0, 480.0))

# ── Stats ───────────────────────────────────────────────────────────────────
var hp: float = 100.0
var max_hp: float = 100.0
var xp: float = 0.0
var xp_to_next: float = 50.0
var level: int = 1
var alive: bool = true

# ── Weapon ──────────────────────────────────────────────────────────────────
var weapon: String = "combat_knife"

# ── Internal state ──────────────────────────────────────────────────────────
var _attack_cd := 0.0
var _combo_count := 0
var _combo_timer := 0.0
var _iframes := 0.0
var _dash_timer := 0.0
var _dash_cd_timer := 0.0
var _dash_dir := Vector2.ZERO
var _facing := Vector2.RIGHT
var _shake_amp := 0.0
var _state := 0  # 0=idle, 1=walk, 2=dash
var _bob_t := 0.0
var _trail_t := 0.0

# ── Nodes ───────────────────────────────────────────────────────────────────
var _body_sprite: Sprite2D
var _weapon_sprite: Sprite2D
var _weapon_trail: Line2D
var _cam: Camera2D
var _shadow: Sprite2D


func _ready():
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)
	_build_visuals()
	_build_weapon_visuals()
	_build_camera()
	_build_shadow()


func _build_visuals():
	_body_sprite = Sprite2D.new()
	_body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_body_sprite.z_index = 1
	if ResourceLoader.exists("res://assets/2d/characters/hunter_sheet.png"):
		_body_sprite.texture = load("res://assets/2d/characters/hunter_sheet.png")
		_body_sprite.hframes = 8
		_body_sprite.vframes = 4
		_body_sprite.frame = 0
		_body_sprite.scale = Vector2(2.0, 2.0)
	else:
		# Procedural fallback character
		var img := Image.create(12, 16, false, Image.FORMAT_RGBA8)
		# Hair
		for x in range(3, 9):
			for y in range(0, 3):
				img.set_pixel(x, y, Color(0.12, 0.10, 0.08))
		# Face
		for x in range(3, 9):
			for y in range(3, 6):
				img.set_pixel(x, y, Color(0.85, 0.72, 0.60))
		img.set_pixel(4, 4, Color(0.1, 0.1, 0.15))
		img.set_pixel(7, 4, Color(0.1, 0.1, 0.15))
		# Body
		for x in range(2, 10):
			for y in range(6, 12):
				img.set_pixel(x, y, Color(0.22, 0.25, 0.32))
		# Legs
		for x in range(3, 5):
			for y in range(12, 16):
				img.set_pixel(x, y, Color(0.18, 0.18, 0.22))
		for x in range(7, 9):
			for y in range(12, 16):
				img.set_pixel(x, y, Color(0.18, 0.18, 0.22))
		_body_sprite.texture = ImageTexture.create_from_image(img)
		_body_sprite.scale = Vector2(3.0, 3.0)
	add_child(_body_sprite)


func _build_weapon_visuals():
	_weapon_sprite = Sprite2D.new()
	_weapon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_weapon_sprite.position = Vector2(12, 0)
	_weapon_sprite.visible = false
	_weapon_sprite.z_index = 2
	# Create a simple weapon sprite
	var img := Image.create(8, 3, false, Image.FORMAT_RGBA8)
	for x in range(8):
		for y in range(3):
			img.set_pixel(x, y, Color(0.7, 0.7, 0.75))
	# Handle
	for x in range(0, 3):
		img.set_pixel(x, 1, Color(0.4, 0.3, 0.2))
	_weapon_sprite.texture = ImageTexture.create_from_image(img)
	add_child(_weapon_sprite)
	# Attack trail
	_weapon_trail = Line2D.new()
	_weapon_trail.width = 2.0
	_weapon_trail.default_color = Color(1.0, 0.9, 0.5, 0.6)
	_weapon_trail.visible = false
	_weapon_trail.z_index = 2
	add_child(_weapon_trail)


func _build_camera():
	_cam = Camera2D.new()
	_cam.zoom = Vector2(3.0, 3.0)
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 8.0
	_cam.limit_left = int(world_rect.position.x)
	_cam.limit_top = int(world_rect.position.y)
	_cam.limit_right = int(world_rect.end.x)
	_cam.limit_bottom = int(world_rect.end.y)
	_cam.name = "Camera"
	add_child(_cam)
	_cam.make_current()


func _clamp_to_world():
	# Keep the player inside the world: no infinite walk into the void.
	var min_pos: Vector2 = world_rect.position + Vector2(WORLD_MARGIN, WORLD_MARGIN)
	var max_pos: Vector2 = world_rect.end - Vector2(WORLD_MARGIN, WORLD_MARGIN)
	global_position = global_position.clamp(min_pos, max_pos)


func _build_shadow():
	_shadow = Sprite2D.new()
	_shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_shadow.z_index = 0
	_shadow.modulate = Color(0, 0, 0, 0.2)
	var img := Image.create(6, 3, false, Image.FORMAT_RGBA8)
	for x in range(6):
		for y in range(3):
			var d := Vector2(x - 2.5, y - 1.0).length()
			if d < 2.5:
				img.set_pixel(x, y, Color(1, 1, 1, 0.3))
	_shadow.texture = ImageTexture.create_from_image(img)
	_shadow.position = Vector2(0, 7)
	add_child(_shadow)


func _physics_process(delta: float):
	if not alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ── Timers ────────────────────────────────────────────────────────────
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_dash_cd_timer = maxf(0.0, _dash_cd_timer - delta)
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0
	if _iframes > 0.0:
		_iframes -= delta
		if _body_sprite:
			_body_sprite.modulate.a = 0.4 + sin(_iframes * 30.0) * 0.3
	elif _body_sprite and _body_sprite.modulate.a < 1.0:
		_body_sprite.modulate.a = 1.0

	# ── HP Regen ──────────────────────────────────────────────────────────
	_hp_regen(delta)

	# ── Dash ──────────────────────────────────────────────────────────────
	if _dash_timer > 0.0:
		_dash_timer -= delta
		velocity = _dash_dir * DASH_SPEED
		_state = 2
		move_and_slide()
		_clamp_to_world()
		_sync_visuals(delta)
		return

	# ── Dodge (dash) ──────────────────────────────────────────────────────
	if Input.is_action_just_pressed("dodge") and _dash_cd_timer <= 0.0:
		var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if dir != Vector2.ZERO:
			_dash_dir = dir.normalized()
		else:
			_dash_dir = _facing
		_dash_timer = DASH_DURATION
		_dash_cd_timer = DASH_CD
		_iframes = maxf(_iframes, DASH_DURATION + 0.05)
		AudioLib2D.play("dodge")

	# ── Movement ──────────────────────────────────────────────────────────
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting := Input.is_action_pressed("sprint")
	var max_speed := SPEED * SPRINT_MULT if is_sprinting else SPEED
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * max_speed, ACCEL * delta)
		_facing = dir.normalized()
		_state = 1
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		_state = 0 if velocity.length() < 5.0 else 1

	move_and_slide()
	_clamp_to_world()

	# ── Attack ────────────────────────────────────────────────────────────
	if Input.is_action_just_pressed("attack") and _attack_cd <= 0.0:
		_perform_attack()

	# ── Weapon swap ───────────────────────────────────────────────────────
	if Input.is_action_just_pressed("slot_1"):
		_swap_weapon("combat_knife")
	elif Input.is_action_just_pressed("slot_2"):
		_swap_weapon("blood_scythe")

	# ── Visuals ───────────────────────────────────────────────────────────
	_sync_visuals(delta)


func _perform_attack():
	_attack_cd = ATTACK_CD
	if _combo_timer > 0.0:
		_combo_count = mini(_combo_count + 1, 2)
	else:
		_combo_count = 0
	_combo_timer = COMBO_WINDOW

	# Show weapon
	_weapon_sprite.visible = true
	_weapon_sprite.rotation = _facing.angle()

	# Swing arc visual
	_start_swing_trail()

	var stats := _get_weapon_stats()
	var base_dmg: float = stats.get("damage", 18.0)
	var mult: float = COMBO_MULT[_combo_count] if _combo_count < COMBO_MULT.size() else 1.6
	var damage := base_dmg * mult
	var hit_any := false

	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var dist := global_position.distance_to(e.global_position)
		if dist <= stats.get("range", 24.0):
			var to_enemy: Vector2 = (e.global_position - global_position).normalized()
			if absf(_facing.angle_to(to_enemy)) < PI / 3.0:
				if e.has_method("take_damage"):
					var is_crit := randf() < CRIT_CHANCE
					var final_dmg := damage
					if is_crit:
						final_dmg *= CRIT_MULT
					e.take_damage(final_dmg, _facing)
					hit_any = true
					_spawn_hit_spark(e.global_position)
					# Lifesteal
					var lifesteal: float = stats.get("lifesteal", 0.0)
					if lifesteal > 0.0:
						heal(final_dmg * lifesteal)
					# Finisher on 3rd hit
					if _combo_count >= 2:
						_apply_finisher(e)

	if hit_any:
		_shake_amp = maxf(_shake_amp, 3.0)
		AudioLib2D.play("attack_swing")
	else:
		AudioLib2D.play("attack_swing", -14.0)

	await get_tree().create_timer(0.12).timeout
	_weapon_sprite.visible = false
	_weapon_trail.visible = false


func _start_swing_trail():
	_weapon_trail.visible = true
	_weapon_trail.clear_points()
	var start_angle := _facing.angle() - PI / 4.0
	var end_angle := _facing.angle() + PI / 4.0
	for i in range(8):
		var t := float(i) / 7.0
		var angle := lerpf(start_angle, end_angle, t)
		var r := 14.0
		_weapon_trail.add_point(Vector2(cos(angle) * r, sin(angle) * r))


func _apply_finisher(enemy: Node2D):
	var stats := _get_weapon_stats()
	var finisher: String = stats.get("finisher", "")
	if finisher == "":
		return
	match finisher:
		"bleed":
			if enemy.has_method("apply_status"):
				enemy.apply_status("bleed", 4.0)
			_spawn_label(enemy.global_position, "BLEED", Color(0.9, 0.1, 0.1))
		"stun":
			if enemy.has_method("apply_status"):
				enemy.apply_status("stun", 1.5)
			_spawn_label(enemy.global_position, "STUN", Color(0.8, 0.7, 0.3))


func _get_weapon_stats() -> Dictionary:
	match weapon:
		"blood_scythe":
			return {
				"damage": 32.0,
				"range": 28.0,
				"lifesteal": 0.08,
				"finisher": "bleed"
			}
		_:
			return {
				"damage": 18.0,
				"range": 24.0,
				"finisher": ""
			}


func _swap_weapon(new_weapon: String):
	if new_weapon == weapon:
		return
	weapon = new_weapon
	weapon_changed.emit(weapon)
	AudioLib2D.play("equip")
	# Flash weapon sprite color
	match weapon:
		"blood_scythe":
			_weapon_sprite.modulate = Color(0.8, 0.2, 0.9)
		_:
			_weapon_sprite.modulate = Color.WHITE


func take_damage(amount: float, from_dir: Vector2 = Vector2.ZERO):
	if not alive or _iframes > 0.0:
		return
	_iframes = 0.6
	var actual := amount * 0.8  # base armor
	hp = maxf(0.0, hp - actual)
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()
		return
	_shake_amp = maxf(_shake_amp, 3.0)
	AudioLib2D.play("hurt")
	_spawn_hit_spark(global_position)
	# Knockback
	velocity = from_dir.normalized() * -120.0


func _die():
	alive = false
	velocity = Vector2.ZERO
	if _body_sprite:
		_body_sprite.modulate = Color(0.5, 0.4, 0.5, 0.6)
	_shake_amp = maxf(_shake_amp, 4.0)
	AudioLib2D.play("death")
	player_died.emit()


func add_xp(amount: float):
	xp += amount
	xp_changed.emit(xp)
	if xp >= xp_to_next:
		level += 1
		xp -= xp_to_next
		xp_to_next = 50.0 + (level - 1) * 30.0
		max_hp += 10.0
		hp = max_hp
		hp_changed.emit(hp, max_hp)
		level_up.emit(level)
		AudioLib2D.play("success")
		_spawn_level_up_effect()


func heal(amount: float):
	hp = minf(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)


func _hp_regen(delta: float):
	if hp > 0.0 and hp < max_hp:
		hp = minf(max_hp, hp + 2.0 * delta)
		hp_changed.emit(hp, max_hp)


func _spawn_level_up_effect():
	_flash_body(Color(0.3, 1.0, 0.4, 0.8))
	_spawn_label(global_position + Vector2(0, -24), "LEVEL UP!", Color(0.3, 1.0, 0.4))


func _sync_visuals(delta: float):
	if _body_sprite:
		_body_sprite.flip_h = _facing.x < 0.0
		if _state == 1:
			_bob_t += delta * 8.0
			_body_sprite.scale.y = 3.0 + sin(_bob_t) * 0.05
		elif _state == 2:
			# Dash squash
			_body_sprite.scale.y = 2.8
		else:
			_body_sprite.scale.y = 3.0


func _flash_body(color: Color):
	if _body_sprite:
		_body_sprite.modulate = color
		var tw := create_tween()
		tw.tween_property(_body_sprite, "modulate", Color.WHITE, 0.4)


func _spawn_hit_spark(pos: Vector2):
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 8
	p.lifetime = 0.25
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 140.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.9
	p.color = Color(1.0, 0.85, 0.35, 0.9)
	p.position = pos
	p.z_index = 6
	get_parent().add_child(p)
	get_tree().create_timer(0.3).timeout.connect(p.queue_free)


func _spawn_label(pos: Vector2, text: String, color: Color):
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = pos + Vector2(-8, -20)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 14.0, 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)


func shake(amp: float):
	_shake_amp = maxf(_shake_amp, amp)


func _process(delta: float):
	if _cam and _shake_amp > 0.01:
		_cam.offset = Vector2(
			randf_range(-_shake_amp, _shake_amp),
			randf_range(-_shake_amp, _shake_amp)
		)
		_shake_amp = lerpf(_shake_amp, 0.0, delta * 12.0)
	elif _cam:
		_cam.offset = Vector2.ZERO
