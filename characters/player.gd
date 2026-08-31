extends CharacterBody2D
class_name Player

# signals
signal hp_changed(hp: float, max_hp: float)
signal energy_changed(energy: float)
signal weapon_changed(weapon: String)
signal player_died()
signal clock_interaction()
signal enemy_killed(enemy: Node2D)
signal picked_up(item_type: String, amount: float)
signal combo_reached(count: int)
signal dash_attack_performed()

const BASE_SPEED := 120.0
const SPRINT_SPEED := 185.0
const DODGE_SPEED := 240.0
const DODGE_DURATION := 0.2
const DODGE_CD := 0.6
const ATTACK_CD := 0.3
const ALT_ATTACK_CD := 0.5
const ACCEL := 700.0
const DECEL := 800.0
const ENERGY_REGEN := 12.0
const SPRINT_DRAIN := 25.0
const HP_REGEN := 2.0
const HP_REGEN_DELAY := 3.0
const CRIT_CHANCE := 0.15
const CRIT_MULTIPLIER := 2.0
const IFRAMES_DURATION := 0.5

# combo system
const COMBO_WINDOW := 0.6  # seconds to chain next hit
const COMBO_DAMAGE_MULT := [1.0, 1.15, 1.4]  # damage multipliers per hit
const COMBO_KNOCKBACK_MULT := [1.0, 1.1, 1.5]

# dash attack
const DASH_ATTACK_SPEED := 280.0
const DASH_ATTACK_DURATION := 0.15
const DASH_ATTACK_DAMAGE_MULT := 1.5

# status effects
signal status_effect_applied(effect: String, duration: float)
var active_effects: Dictionary = {}  # {"poison": time_left, "burn": time_left, ...}
var _effect_tick_timer := 0.0

const T := 16

var hp: float = 100.0
var max_hp: float = 100.0
var energy: float = 100.0
var max_energy: float = 100.0
var alive: bool = true

enum State { IDLE, MOVE, ATTACK, ALT_ATTACK, DODGE, HURT, DEAD }
var state: int = State.IDLE
var _facing := Vector2.RIGHT
var _facing_angle := 0.0

var weapon: String = "hunter_blade"
var armor: String = "tactical_vest"
var tool_item: String = "grapple"
var ammo: int = 0

var _attack_cd := 0.0
var _alt_attack_cd := 0.0
var _dodge_cd := 0.0
var _combo_count := 0
var _combo_timer := 0.0
var _is_dash_attacking := false
var _dash_attack_dir := Vector2.ZERO
var _hurt_time := 0.0
var _hit_pause := 0.0
var _knock := Vector2.ZERO
var _damage_mult := 1.0
var _speed_mult := 1.0
var _hp_regen_timer := 0.0
var _screen_flash: ColorRect = null
var _iframes_timer := 0.0
var _footstep_timer := 0.0
var _crit_flash_timer := 0.0

# visuals
var _bob_t := 0.0
var _shake_amp := 0.0
var _cam: Camera2D = null
var _body_sprite: Sprite2D
var _coat_sprite: Sprite2D
var _head_sprite: Sprite2D
var _weapon_sprite: Sprite2D
var _trail_points: Array[Vector2] = []
var _trail_line: Line2D
var _hurt_flash := 0.0

var _walk_frame := 0.0
var _walk_cycle := 0.0

func _ready():
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)

	_build_character_visuals()

	_trail_line = Line2D.new()
	_trail_line.width = 1.5
	_trail_line.default_color = Color(0.5, 0.6, 0.85, 0.6)
	_trail_line.visible = false
	_trail_line.z_index = 3
	add_child(_trail_line)

	_weapon_sprite = Sprite2D.new()
	_weapon_sprite.texture = _weapon_texture()
	_weapon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_weapon_sprite.position = Vector2(10, 0)
	_weapon_sprite.visible = false
	_weapon_sprite.z_index = 2
	add_child(_weapon_sprite)

	var cam := Camera2D.new()
	cam.zoom = Vector2(3.2, 3.2)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 80 * T
	cam.limit_bottom = 60 * T
	cam.name = "Camera"
	add_child(cam)
	cam.make_current()
	_cam = cam

	if GameManager.inventory:
		weapon = GameManager.inventory.get_equipped_weapon()
		_weapon_sprite.texture = _weapon_texture()


func _build_character_visuals():
	_head_sprite = Sprite2D.new()
	if ResourceLoader.exists("res://assets/2d/characters/hero.png"):
		_body_sprite = Sprite2D.new()
		_body_sprite.texture = load("res://assets/2d/characters/hero.png")
		_body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_body_sprite.scale = Vector2(3.0, 3.0)
		_body_sprite.z_index = 1
		add_child(_body_sprite)
		_head_sprite.visible = false
		_coat_sprite = null
	elif ResourceLoader.exists("res://assets/2d/characters/hunter_sheet.png"):
		_body_sprite = Sprite2D.new()
		_body_sprite.texture = load("res://assets/2d/characters/hunter_sheet.png")
		_body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_body_sprite.hframes = 8
		_body_sprite.vframes = 4
		_body_sprite.frame = 0
		_body_sprite.z_index = 1
		add_child(_body_sprite)
		_head_sprite.visible = false
		_coat_sprite = null
	elif ResourceLoader.exists("res://assets/2d/characters/hunter.png"):
		_body_sprite = Sprite2D.new()
		_body_sprite.texture = load("res://assets/2d/characters/hunter.png")
		_body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_body_sprite.z_index = 1
		add_child(_body_sprite)
		_head_sprite.visible = false
		_coat_sprite = null
	else:
		_head_sprite.texture = _head_texture()
		_head_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_head_sprite.position = Vector2(0, -6)
		_head_sprite.z_index = 2
		add_child(_head_sprite)

		_coat_sprite = Sprite2D.new()
		_coat_sprite.texture = _coat_texture()
		_coat_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_coat_sprite.position = Vector2(0, 2)
		_coat_sprite.z_index = 1
		add_child(_coat_sprite)

		_body_sprite = _coat_sprite

func _head_texture():
	var img := Image.create(10, 8, false, Image.FORMAT_RGBA8)
	for x in range(2, 8): for y in range(0, 3): img.set_pixel(x, y, Color(0.15, 0.12, 0.10))
	for x in range(2, 8): for y in range(3, 7): img.set_pixel(x, y, Color(0.82, 0.70, 0.58))
	img.set_pixel(3, 4, Color(0.1, 0.1, 0.15))
	img.set_pixel(6, 4, Color(0.1, 0.1, 0.15))
	return ImageTexture.create_from_image(img)

func _coat_texture():
	var img := Image.create(12, 14, false, Image.FORMAT_RGBA8)
	for x in range(2, 10): for y in range(0, 10): img.set_pixel(x, y, Color(0.25, 0.28, 0.35))
	for x in range(3, 9): img.set_pixel(x, 0, Color(0.30, 0.33, 0.40))
	for x in range(2, 10): img.set_pixel(x, 6, Color(0.45, 0.35, 0.22))
	img.set_pixel(6, 6, Color(0.7, 0.65, 0.3))
	for x in range(3, 5): for y in range(10, 14): img.set_pixel(x, y, Color(0.18, 0.18, 0.22))
	for x in range(7, 9): for y in range(10, 14): img.set_pixel(x, y, Color(0.18, 0.18, 0.22))
	for x in range(2, 5): for y in range(12, 14): img.set_pixel(x, y, Color(0.25, 0.20, 0.18))
	for x in range(7, 10): for y in range(12, 14): img.set_pixel(x, y, Color(0.25, 0.20, 0.18))
	return ImageTexture.create_from_image(img)

func _physics_process(delta):
	if not alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _hit_pause > 0.0:
		_hit_pause = maxf(0.0, _hit_pause - delta)
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)
	_alt_attack_cd = maxf(0.0, _alt_attack_cd - delta)
	_dodge_cd = maxf(0.0, _dodge_cd - delta)

	# combo timer
	if _combo_timer > 0.0:
		_combo_timer = maxf(0.0, _combo_timer - delta)
		if _combo_timer <= 0.0:
			_combo_count = 0

	# status effect ticks
	_effect_tick_timer -= delta
	if _effect_tick_timer <= 0.0:
		_effect_tick_timer = 0.5
		_process_status_effects()
	_hurt_time = maxf(0.0, _hurt_time - delta)
	if _hurt_time <= 0.0 and state == State.HURT:
		state = State.IDLE

	if _iframes_timer > 0.0:
		_iframes_timer = maxf(0.0, _iframes_timer - delta)

	_knock = _knock.move_toward(Vector2.ZERO, delta * 600.0)

	energy = minf(max_energy, energy + delta * ENERGY_REGEN)
	energy_changed.emit(energy)

	_hp_regen_timer = maxf(0.0, _hp_regen_timer - delta)
	if _hp_regen_timer <= 0.0 and hp < max_hp and hp > 0.0:
		hp = minf(max_hp, hp + delta * HP_REGEN)
		hp_changed.emit(hp, max_hp)

	if state in [State.ATTACK, State.ALT_ATTACK, State.DODGE]:
		velocity = _knock
		move_and_slide()
		return

	var dir := Vector2.ZERO
	if GameManager.can_act():
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting: bool = Input.is_action_pressed("sprint") and energy > 5.0 and GameManager.can_act()
	var speed := SPRINT_SPEED if is_sprinting else BASE_SPEED
	speed *= _speed_mult

	# status effect speed modifiers
	if has_status_effect("freeze"):
		speed *= 0.5
	elif has_status_effect("slow"):
		speed *= 0.7

	if is_sprinting and dir != Vector2.ZERO:
		energy -= delta * SPRINT_DRAIN
		energy = maxf(0.0, energy)
		energy_changed.emit(energy)

	if dir != Vector2.ZERO:
		var target_vel := dir * speed
		velocity = velocity.move_toward(target_vel, ACCEL * delta)
		_facing = dir.normalized()
		_facing_angle = _facing.angle()
		state = State.MOVE
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECEL * delta)
		state = State.IDLE if velocity.length() < 5.0 else State.MOVE

	velocity += _knock
	move_and_slide()

	global_position = global_position.clamp(Vector2(16, 16), Vector2(80 * T - 16, 60 * T - 16))

	# weapon quick-swap (1-4 keys)
	if Input.is_action_just_pressed("slot_1"): _swap_weapon_slot(0)
	elif Input.is_action_just_pressed("slot_2"): _swap_weapon_slot(1)
	elif Input.is_action_just_pressed("slot_3"): _swap_weapon_slot(2)
	elif Input.is_action_just_pressed("slot_4"): _swap_weapon_slot(3)

	if Input.is_action_just_pressed("attack") and _attack_cd <= 0.0:
		# dash attack: attack while moving fast
		if state == State.DODGE or (velocity.length() > SPRINT_SPEED * 0.8 and is_sprinting):
			_perform_dash_attack(dir)
		else:
			_perform_attack(false)
	elif Input.is_action_just_pressed("alt_attack") and _alt_attack_cd <= 0.0:
		_perform_attack(true)
	elif Input.is_action_just_pressed("dodge") and _dodge_cd <= 0.0 and dir != Vector2.ZERO and energy >= 15.0:
		_perform_dodge(dir)
	elif Input.is_action_just_pressed("interact"):
		_try_interact()
	elif Input.is_action_just_pressed("blood_clock"):
		clock_interaction.emit()

	_sync_visuals(delta)


func _perform_attack(is_alt):
	if not GameManager.can_act():
		return
	state = State.ALT_ATTACK if is_alt else State.ATTACK
	var cd := ALT_ATTACK_CD if is_alt else ATTACK_CD
	_attack_cd = cd if not is_alt else 0.0
	_alt_attack_cd = cd if is_alt else 0.0

	# combo tracking
	if not is_alt:
		if _combo_timer > 0.0:
			_combo_count = mini(_combo_count + 1, COMBO_DAMAGE_MULT.size() - 1)
			combo_reached.emit(_combo_count)
		else:
			_combo_count = 0
		_combo_timer = COMBO_WINDOW

	_weapon_sprite.visible = true
	_weapon_sprite.rotation = _facing_angle

	var weapon_stats := WeaponData.get_weapon(weapon)
	var attack_range: float = weapon_stats.get("range", 22.0) if not is_alt else weapon_stats.get("range", 22.0) + 4.0
	var base_damage: float = weapon_stats.get("damage", 18.0) if not is_alt else weapon_stats.get("damage", 18.0) * 1.6
	var knock_force: float = weapon_stats.get("knock_force", 80.0) if not is_alt else weapon_stats.get("knock_force", 80.0) * 1.7

	var damage := base_damage

	# apply combo multiplier
	if not is_alt and _combo_count > 0 and _combo_count < COMBO_DAMAGE_MULT.size():
		damage *= COMBO_DAMAGE_MULT[_combo_count]

	var is_ranged: bool = weapon_stats.get("is_ranged", false)
	if is_ranged:
		_fire_projectile(weapon_stats, is_alt)
	else:
		var hit_any := false
		for e in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(e):
				continue
			var dist := global_position.distance_to(e.global_position)
			if dist <= attack_range:
				var to_enemy: Vector2 = (e.global_position - global_position).normalized()
				var angle_diff := absf(_facing.angle_to(to_enemy))
				if is_alt or angle_diff < PI / 4.0:						if e.has_method("take_damage"):
							var weapon_crit_chance: float = weapon_stats.get("crit_chance", CRIT_CHANCE)
							var is_crit := randf() < weapon_crit_chance
							var final_damage: float = (damage + GameManager.get_level_damage_bonus()) * _damage_mult
							e.take_damage(final_damage, _facing)
							# lifesteal
							var ls: float = weapon_stats.get("lifesteal", 0.0)
							if ls > 0.0:
								hp = minf(max_hp, hp + final_damage * ls)
							if is_crit:
								_spawn_combo_text(e.global_position, final_damage, is_crit)
							elif _combo_count > 0:
								_spawn_combo_indicator(e.global_position, _combo_count)
							_spawn_hit_spark(e.global_position)
							hit_any = true

		if hit_any:
			_hit_pause = 0.04
			_shake_amp = maxf(_shake_amp, 2.5 if not is_alt else 4.0)
			# combo hit sounds
			if not is_alt and _combo_count > 0:
				match _combo_count:
					1: AudioLib2D.play("combo_hit_1")
					2: AudioLib2D.play("combo_hit_2")
					_: AudioLib2D.play("combo_hit_3")
			else:
				AudioLib2D.play("attack_swing")

			# === COMBO BONUSES ===
			if not is_alt:
				_process_combo_bonuses(weapon_stats)
		else:
			_shake_amp = maxf(_shake_amp, 1.0)
			AudioLib2D.play("step")

	_start_trail()

	if _body_sprite and _body_sprite.hframes >= 8:
		_body_sprite.frame = 16 + (1 if not is_alt else 2)

	await get_tree().create_timer(0.12 if not is_alt else 0.18).timeout
	_weapon_sprite.visible = false
	_trail_line.visible = false
	if state in [State.ATTACK, State.ALT_ATTACK]:
		state = State.IDLE

func _fire_projectile(weapon_stats: Dictionary, is_alt: bool) -> void:
	var proj := Area2D.new()
	proj.collision_layer = 0
	proj.collision_mask = 4 # enemy layer
	proj.position = global_position + _facing * 12.0

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	col.shape = shape
	proj.add_child(col)

	var spr := Sprite2D.new()
	match weapon:
		"bow":
			spr.texture = _weapon_texture()
			spr.rotation = _facing_angle + PI / 4.0
			spr.scale = Vector2(0.8, 0.8)
		"icestaff":
			var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
			for y in range(8):
				for x in range(8):
					if Vector2(x - 3.5, y - 3.5).length() <= 3.5:
						img.set_pixel(x, y, Color(0.4, 0.8, 1.0, 0.9))
			spr.texture = ImageTexture.create_from_image(img)
		"pulse_pistol":
			var img := Image.create(6, 4, false, Image.FORMAT_RGBA8)
			for y in range(4):
				for x in range(6):
					img.set_pixel(x, y, Color(0.2, 0.9, 1.0, 0.9))
			spr.texture = ImageTexture.create_from_image(img)
			spr.rotation = _facing_angle
		_:
			var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
			img.fill(Color(1.0, 0.8, 0.2))
			spr.texture = ImageTexture.create_from_image(img)

	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	proj.add_child(spr)
	get_parent().add_child(proj)

	AudioLib2D.play("attack_swing")
	_shake_amp = maxf(_shake_amp, 1.5)

	var proj_speed: float = 260.0 if not is_alt else 320.0
	var proj_dir: Vector2 = _facing
	var lifetime := 0.6
	var p_timer := 0.0

	var proj_damage: float = weapon_stats.get("damage", 20.0) + GameManager.get_level_damage_bonus()
	if is_alt:
		proj_damage *= 1.4

	var hit_enemy := false
	var tw := create_tween()
	tw.tween_property(proj, "position", proj.position + proj_dir * proj_speed * lifetime, lifetime)
	
	proj.body_entered.connect(func(body):
		if hit_enemy:
			return
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			hit_enemy = true
			var is_crit: bool = randf() < weapon_stats.get("crit_chance", CRIT_CHANCE)
			var final_dmg := proj_damage
			if is_crit:
				final_dmg *= weapon_stats.get("crit_multiplier", CRIT_MULTIPLIER)
				_spawn_crit_number(body.global_position, final_dmg)
			body.take_damage(final_dmg, proj_dir)
			_spawn_hit_spark(body.global_position)
			tw.kill()
			proj.free()
	)
	
	tw.finished.connect(func():
		if is_instance_valid(proj):
			proj.free()
	)

func _perform_dodge(dir):
	state = State.DODGE
	_dodge_cd = DODGE_CD
	energy -= 15.0
	energy_changed.emit(energy)
	_knock = dir * DODGE_SPEED

	if _body_sprite:
		_body_sprite.modulate.a = 0.35
	await get_tree().create_timer(DODGE_DURATION).timeout
	if _body_sprite:
		_body_sprite.modulate.a = 1.0
	state = State.IDLE

func take_damage(amount, from_dir = Vector2.ZERO):
	if not alive or state == State.DODGE or _iframes_timer > 0.0:
		return
	_iframes_timer = IFRAMES_DURATION

	var reduction := 0.0
	match armor:
		"chainmail": reduction = 0.15
		"tactical_vest": reduction = 0.25
		"nano_suit": reduction = 0.35
		"energy_shield": reduction = 0.50
	var actual: float = amount * (1.0 - reduction)
	hp = maxf(0.0, hp - actual)
	hp_changed.emit(hp, max_hp)

	if hp <= 0.0:
		_die()
		return

	state = State.HURT
	_hurt_time = 0.3
	_knock = from_dir.normalized() * 130.0

	_hp_regen_timer = HP_REGEN_DELAY
	AudioLib2D.play("hurt")

	_hurt_flash = 0.3
	if _body_sprite:
		_body_sprite.modulate = Color(1.0, 0.4, 0.4)
		var tw := create_tween()
		tw.tween_property(_body_sprite, "modulate", Color.WHITE, 0.3)

	_flash_screen(Color(0.8, 0.1, 0.05, 0.25))

	_shake_amp = maxf(_shake_amp, 3.0)

func _die():
	alive = false
	state = State.DEAD
	velocity = Vector2.ZERO
	if _body_sprite:
		_body_sprite.modulate = Color(0.5, 0.4, 0.5, 0.6)
	_flash_screen(Color(0.6, 0.0, 0.0, 0.45))
	_shake_amp = maxf(_shake_amp, 4.0)
	player_died.emit()
	AudioLib2D.play("death")
	GameManager.fail_contract()

func apply_buff(buff_type: String, value: float, duration: float) -> void:
	match buff_type:
		"damage":
			_damage_mult = value
			var tw := create_tween()
			tw.tween_interval(duration)
			tw.tween_callback(func(): _damage_mult = 1.0)
		"defense":
			_damage_mult = value
			var tw2 := create_tween()
			tw2.tween_interval(duration)
			tw2.tween_callback(func(): _damage_mult = 1.0)
		"speed":
			_speed_mult = value
			var tw3 := create_tween()
			tw3.tween_interval(duration)
			tw3.tween_callback(func(): _speed_mult = 1.0)

func respawn():
	alive = true
	hp = GameManager.player_max_hp
	max_hp = GameManager.player_max_hp
	energy = max_energy
	state = State.IDLE
	_knock = Vector2.ZERO
	_iframes_timer = 0.0
	if _body_sprite:
		_body_sprite.modulate = Color.WHITE
	hp_changed.emit(hp, max_hp)
	energy_changed.emit(energy)
	AudioLib2D.play("respawn")


func set_era_equipment(equipment):
	weapon = equipment.get("weapon", "combat_knife")
	armor = equipment.get("armor", "tactical_vest")
	tool_item = equipment.get("tool", "grapple")
	if GameManager.inventory:
		weapon = GameManager.inventory.get_equipped_weapon()
	_weapon_sprite.texture = _weapon_texture()
	weapon_changed.emit(weapon)

func sync_weapon_from_inventory():
	if GameManager.inventory:
		weapon = GameManager.inventory.get_equipped_weapon()
		_weapon_sprite.texture = _weapon_texture()
		weapon_changed.emit(weapon)


func _try_interact():
	for obj in get_tree().get_nodes_in_group("interactable"):
		if global_position.distance_to(obj.global_position) < 24.0:
			if obj.has_method("interact"):
				obj.interact.call(self)
			return


func _sync_visuals(delta):
	var moving: bool = state == State.MOVE
	var sprinting: bool = Input.is_action_pressed("sprint") and moving

	if _iframes_timer > 0.0 and _body_sprite:
		_body_sprite.modulate.a = 0.4 + sin(_iframes_timer * 30.0) * 0.3
	elif _body_sprite and _body_sprite.modulate.a < 1.0:
		_body_sprite.modulate.a = 1.0

	if moving and velocity.length() > 30.0:
		_footstep_timer -= delta
		if _footstep_timer <= 0.0:
			AudioLib2D.play("step")
			_footstep_timer = 0.3 if sprinting else 0.45
	else:
		_footstep_timer = 0.0

	if moving:
		var speed_factor := SPRINT_SPEED if sprinting else BASE_SPEED
		_bob_t += delta * clampf(velocity.length() / speed_factor, 0.4, 2.0) * 8.0
		var s := absf(sin(_bob_t))

		_walk_cycle += delta * clampf(velocity.length() / BASE_SPEED, 0.4, 2.0) * 6.0
		_walk_frame = sin(_walk_cycle)

		if _body_sprite and _body_sprite != _weapon_sprite:
			_body_sprite.scale = Vector2(1.0 + s * 0.05, 1.0 - s * 0.03)
			_body_sprite.rotation = sin(_bob_t * 0.5) * 0.03
			if _body_sprite.hframes >= 8:
				_body_sprite.frame = 8 + (int(_walk_cycle * 1.5) % 4)
	else:
		_bob_t += delta * 2.0
		var b := sin(_bob_t) * 0.015
		if _body_sprite and _body_sprite != _weapon_sprite:
			_body_sprite.scale = Vector2(1.0 + b, 1.0 - b)
			_body_sprite.rotation = lerpf(_body_sprite.rotation, 0.0, delta * 6.0)
			if _body_sprite.hframes >= 8 and state == State.IDLE:
				_body_sprite.frame = int(_bob_t * 1.5) % 4
		_walk_frame = lerpf(_walk_frame, 0.0, delta * 8.0)

	if state == State.DODGE and _body_sprite and _body_sprite.hframes >= 8:
		_body_sprite.frame = 26 + (int(_bob_t * 3.0) % 2)
	elif (state == State.HURT or state == State.DEAD) and _body_sprite and _body_sprite.hframes >= 8:
		_body_sprite.frame = 24

	if _body_sprite:
		_body_sprite.flip_h = _facing.x < 0.0
	if _head_sprite:
		_head_sprite.flip_h = _facing.x < 0.0
		if moving:
			_head_sprite.position.y = -6 + sin(_bob_t) * 1.5
		else:
			_head_sprite.position.y = -6 + sin(_bob_t) * 0.5

	_weapon_sprite.flip_h = _facing.x < 0.0

	if sprinting and _body_sprite:
		_body_sprite.rotation += _facing.angle() * 0.05

func shake(amp):
	_shake_amp = maxf(_shake_amp, amp)

func _process(delta):
	if _cam:
		if _shake_amp > 0.01:
			_cam.offset = Vector2(randf_range(-_shake_amp, _shake_amp), randf_range(-_shake_amp, _shake_amp))
			_shake_amp = lerpf(_shake_amp, 0.0, delta * 12.0)
		else:
			_cam.offset = Vector2.ZERO

	if _hurt_flash > 0.0:
		_hurt_flash = maxf(0.0, _hurt_flash - delta)

func _start_trail():
	_trail_line.visible = true
	_trail_line.clear_points()
	var start_angle := _facing_angle - PI / 6.0
	var end_angle := _facing_angle + PI / 6.0
	for i in range(8):
		var a := lerpf(start_angle, end_angle, float(i) / 7.0)
		_trail_line.add_point(Vector2(cos(a) * 14.0, sin(a) * 14.0))

func _spawn_crit_number(pos, damage):
	var lbl := Label.new()
	lbl.text = "CRIT! -" + str(int(damage))
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	lbl.position = pos + Vector2(-20, -24)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 20.0, 0.5)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.free)

func apply_level_bonuses(hp_bonus, energy_bonus, damage_bonus):
	max_hp += hp_bonus
	hp = max_hp
	max_energy += energy_bonus
	energy = max_energy
	hp_changed.emit(hp, max_hp)
	energy_changed.emit(energy)
	_flash_screen(Color(0.2, 0.8, 0.3, 0.3))
	_shake_amp = maxf(_shake_amp, 2.0)
	AudioLib2D.play("success")

func _spawn_hit_spark(pos):
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 8
	p.lifetime = 0.2
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 140.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 80.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.9
	p.color = Color(1.0, 0.85, 0.35, 0.9)
	p.position = pos
	p.z_index = 6
	get_parent().add_child(p)
	get_tree().create_timer(0.35).timeout.connect(p.queue_free)

func _flash_screen(color):
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
	layer.name = "ScreenFlash"
	layer.layer = 20
	layer.add_child(flash)
	root.add_child(layer)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.25)
	tw.tween_callback(layer.free)


# ─── COMBO BONUS SYSTEM ────────────────────────────────────────────────────────

func _process_combo_bonuses(weapon_stats: Dictionary) -> void:
	var combo_data: Dictionary = weapon_stats.get("combo_bonuses", {})
	if combo_data.is_empty():
		return

	# --- Hit effects (trigger on every combo hit) ---
	var hit_effect: String = combo_data.get("hit_effect", "")
	if hit_effect != "":
		var chance: float = combo_data.get("hit_effect_chance", 1.0)
		if randf() <= chance:
			_apply_combo_hit_effect(hit_effect, combo_data)

	# --- Finisher (trigger on 3rd combo hit, i.e. combo_count >= 2) ---
	if _combo_count >= 2:
		var finisher: String = combo_data.get("finisher", "")
		if finisher != "":
			_apply_combo_finisher(finisher, combo_data)


func _apply_combo_hit_effect(effect: String, data: Dictionary) -> void:
	match effect:
		"poison":
			var dur: float = data.get("hit_effect_duration", 3.0)
			for e in _get_nearby_enemies(48.0):
				if e.has_method("apply_status_effect"):
					e.apply_status_effect("poison", dur)
				elif e.has_method("take_damage"):
					# apply to player-visible poison on enemy hp bar
					_passive_effect_visual(e, Color(0.3, 0.8, 0.2), "PSN")
		"burn":
			var dur: float = data.get("hit_effect_duration", 2.0)
			for e in _get_nearby_enemies(48.0):
				if e.has_method("apply_status_effect"):
					e.apply_status_effect("burn", dur)
				else:
					_passive_effect_visual(e, Color(1.0, 0.4, 0.1), "BRN")
		"slow":
			var dur: float = data.get("hit_effect_duration", 2.0)
			for e in _get_nearby_enemies(48.0):
				if e.has_method("apply_status_effect"):
					e.apply_status_effect("slow", dur)
				else:
					_passive_effect_visual(e, Color(0.4, 0.5, 0.9), "SLOW")
		"dodge_reset":
			var reduction: float = data.get("hit_dodge_cd_reduction", 0.2)
			_dodge_cd = maxf(0.0, _dodge_cd - reduction * DODGE_CD)
		"charge":
			# visual indicator of charge building
			_spawn_status_particles(Color(0.8, 0.8, 1.0))


func _apply_combo_finisher(finisher: String, data: Dictionary) -> void:
	AudioLib2D.play("combo_finisher")
	match finisher:
		"poison_burst":
			var aoe_range: float = data.get("finisher_aoe_range", 48.0)
			var bonus_dmg: float = data.get("finisher_extra_damage", 12.0)
			for e in _get_nearby_enemies(aoe_range):
				if e.has_method("take_damage"):
					e.take_damage(bonus_dmg + GameManager.get_level_damage_bonus(), _facing)
					if e.has_method("apply_status_effect"):
						e.apply_status_effect("poison", 4.0)
					_passive_effect_visual(e, Color(0.3, 0.8, 0.2), "BURST")
			_spawn_finisher_burst(Color(0.3, 0.8, 0.2), aoe_range)
			_shake_amp = maxf(_shake_amp, 3.5)

		"lightning_chain":
			var aoe_range: float = data.get("finisher_aoe_range", 64.0)
			var chain_count: int = data.get("finisher_chain_count", 3)
			var chain_dmg_mult: float = data.get("finisher_chain_damage_mult", 0.5)
			var enemies := _get_nearby_enemies(aoe_range)
			var base_dmg: float = WeaponData.get_weapon(weapon).get("damage", 18.0)
			var chain_damage: float = base_dmg * chain_dmg_mult + GameManager.get_level_damage_bonus()
			var hit_count := 0
			for e in enemies:
				if hit_count >= chain_count:
					break
				if e.has_method("take_damage"):
					e.take_damage(chain_damage, _facing)
					_hit_pause = 0.03
					_spawn_lightning_bolt(e.global_position)
					hit_count += 1
			_spawn_finisher_burst(Color(0.6, 0.7, 1.0), aoe_range * 0.5)
			_shake_amp = maxf(_shake_amp, 4.0)
			AudioLib2D.play("enemy_alert")

		"shadow_step":
			var teleport_range: float = data.get("finisher_teleport_range", 40.0)
			var bonus_dmg: float = data.get("finisher_bonus_damage", 20.0)
			# teleport behind nearest enemy
			var nearest: Node2D = null
			var near_dist: float = 9999.0
			for e in _get_nearby_enemies(teleport_range * 2.0):
				var d: float = global_position.distance_to(e.global_position)
				if d < near_dist:
					near_dist = d
					nearest = e
			if nearest:
				var behind: Vector2 = nearest.global_position + (nearest.global_position - global_position).normalized() * 12.0
				global_position = behind
				if nearest.has_method("take_damage"):
					nearest.take_damage(bonus_dmg + GameManager.get_level_damage_bonus(), _facing)
					_spawn_crit_number(nearest.global_position, bonus_dmg + GameManager.get_level_damage_bonus())
			# shadow trail visual
			_spawn_shadow_trail()
			_shake_amp = maxf(_shake_amp, 2.5)
			AudioLib2D.play("time_travel")

		"fire_trail":
			var trail_dmg: float = data.get("finisher_trail_damage", 8.0)
			var trail_dur: float = data.get("finisher_trail_duration", 3.0)
			var trail_range: float = data.get("finisher_trail_range", 60.0)
			_spawn_fire_trail(trail_dmg, trail_dur, trail_range)
			_shake_amp = maxf(_shake_amp, 3.0)

		"time_freeze":
			var aoe_range: float = data.get("finisher_aoe_range", 56.0)
			var freeze_dur: float = data.get("finisher_freeze_duration", 2.5)
			for e in _get_nearby_enemies(aoe_range):
				if e.has_method("apply_status_effect"):
					e.apply_status_effect("freeze", freeze_dur)
				elif e.has_method("take_damage"):
					e.take_damage(0, Vector2.ZERO)  # trigger flash
					_passive_effect_visual(e, Color(0.3, 0.6, 1.0), "FROZEN")
			_spawn_time_freeze_visual(aoe_range)
			_shake_amp = maxf(_shake_amp, 3.0)
			AudioLib2D.play("time_travel")


func _get_nearby_enemies(range: float) -> Array:
	var result: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and global_position.distance_to(e.global_position) <= range:
			result.append(e)
	return result


func _passive_effect_visual(enemy: Node2D, color: Color, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = enemy.global_position + Vector2(-6, -18)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 12.0, 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.free)


# ─── FINISHER VISUAL EFFECTS ───────────────────────────────────────────────────

func _spawn_finisher_burst(color: Color, aoe_range: float) -> void:
	var burst := CPUParticles2D.new()
	burst.one_shot = true
	burst.emitting = true
	burst.amount = 24
	burst.lifetime = 0.4
	burst.explosiveness = 1.0
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 120.0
	burst.gravity = Vector2.ZERO
	burst.scale_amount_min = 0.4
	burst.scale_amount_max = 1.2
	burst.color = color
	burst.position = position
	burst.z_index = 8
	get_parent().add_child(burst)
	get_tree().create_timer(0.5).timeout.connect(burst.queue_free)

	# screen flash
	_flash_screen(Color(color.r, color.g, color.b, 0.12))


func _spawn_lightning_bolt(target_pos: Vector2) -> void:
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.7, 0.8, 1.0, 0.9)
	line.z_index = 8
	line.add_point(position + Vector2(randf_range(-4, 4), randf_range(-8, 0)))
	# zigzag points
	var dir: Vector2 = (target_pos - position).normalized()
	var dist: float = position.distance_to(target_pos)
	var segments: int = int(dist / 8.0)
	for i in range(1, segments + 1):
		var t: float = float(i) / float(segments)
		var p: Vector2 = position.lerp(target_pos, t)
		p += Vector2(randf_range(-5, 5), randf_range(-5, 5))
		line.add_point(p)
	get_parent().add_child(line)
	var tw := create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.25)
	tw.tween_callback(line.free)


func _spawn_shadow_trail() -> void:
	# after-image effect
	if not _body_sprite:
		return
	var afterimage := Sprite2D.new()
	afterimage.texture = _body_sprite.texture
	afterimage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	afterimage.position = position - _facing * 10.0
	afterimage.flip_h = _facing.x < 0.0
	afterimage.modulate = Color(0.4, 0.2, 0.6, 0.5)
	afterimage.z_index = 0
	get_parent().add_child(afterimage)
	var tw := create_tween()
	tw.tween_property(afterimage, "modulate:a", 0.0, 0.3)
	tw.tween_callback(afterimage.free)


func _spawn_fire_trail(damage: float, duration: float, trail_range: float) -> void:
	# create a line of fire particles along facing direction
	var segments: int = int(trail_range / 10.0)
	for i in range(segments):
		var offset: Vector2 = _facing * (i * 10.0 + 8.0)
		var fire_pos: Vector2 = position + offset
		var fire := CPUParticles2D.new()
		fire.one_shot = true
		fire.emitting = true
		fire.amount = 6
		fire.lifetime = duration
		fire.explosiveness = 0.5
		fire.direction = Vector2.UP
		fire.spread = 40.0
		fire.initial_velocity_min = 10.0
		fire.initial_velocity_max = 30.0
		fire.gravity = Vector2(0, -15)
		fire.scale_amount_min = 0.3
		fire.scale_amount_max = 0.8
		fire.color = Color(1.0, 0.5, 0.1, 0.8)
		fire.position = fire_pos
		fire.z_index = 4
		get_parent().add_child(fire)

		# damage zone
		var dmg_zone := Area2D.new()
		dmg_zone.collision_layer = 0
		dmg_zone.collision_mask = 4  # enemy layer
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 8.0
		col.shape = shape
		dmg_zone.add_child(col)
		dmg_zone.position = fire_pos
		get_parent().add_child(dmg_zone)

		# tick damage every 0.5s
		var elapsed := 0.0
		var tick_timer := 0.0
		var dmg_tick := damage
		while elapsed < duration:
			await get_tree().create_timer(0.5).timeout
			elapsed += 0.5
			for body in dmg_zone.get_overlapping_bodies():
				if body.is_in_group("enemies") and body.has_method("take_damage"):
					body.take_damage(dmg_tick, Vector2.ZERO)
					_passive_effect_visual(body, Color(1.0, 0.4, 0.1), "FIRE")

		fire.queue_free()
		dmg_zone.queue_free()


func _spawn_time_freeze_visual(aoe_range: float) -> void:
	# expanding ring visual
	var ring := Sprite2D.new()
	var ring_img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for x in range(32):
		for y in range(32):
			var d: float = Vector2(x - 15.5, y - 15.5).length()
			if d > 12.0 and d < 15.5:
				ring_img.set_pixel(x, y, Color(0.3, 0.6, 1.0, clampf(1.0 - (d - 12.0) / 3.5, 0.2, 0.8)))
	ring.texture = ImageTexture.create_from_image(ring_img)
	ring.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ring.position = position
	ring.z_index = 7
	get_parent().add_child(ring)
	var target_scale := aoe_range / 16.0
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector2(target_scale, target_scale), 0.25)
	tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.tween_callback(ring.free)

	# screen tint
	_flash_screen(Color(0.2, 0.4, 0.9, 0.1))


func _perform_dash_attack(dir: Vector2) -> void:
	if not GameManager.can_act():
		return
	_is_dash_attacking = true
	state = State.ATTACK
	_attack_cd = ATTACK_CD * 0.7  # faster recovery
	_dash_attack_dir = dir.normalized() if dir.length() > 0.1 else _facing
	dash_attack_performed.emit()

	# dash forward
	var tween := create_tween()
	tween.tween_property(self, "velocity", _dash_attack_dir * DASH_ATTACK_SPEED, 0.05)
	tween.tween_interval(DASH_ATTACK_DURATION)
	tween.tween_property(self, "velocity", Vector2.ZERO, 0.1)

	# visual flash
	if _body_sprite:
		_body_sprite.modulate = Color(0.6, 0.8, 1.0)
		var tw2 := create_tween()
		tw2.tween_property(_body_sprite, "modulate", Color.WHITE, 0.2)

	# hit all nearby enemies with bonus damage
	var weapon_stats := WeaponData.get_weapon(weapon)
	var dash_range: float = weapon_stats.get("range", 22.0) + 12.0
	var dash_damage: float = weapon_stats.get("damage", 18.0) * DASH_ATTACK_DAMAGE_MULT

	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var dist := global_position.distance_to(e.global_position)
		if dist <= dash_range:
			if e.has_method("take_damage"):
				var is_crit: bool = randf() < float(weapon_stats.get("crit_chance", CRIT_CHANCE))
				var final_dmg: float = dash_damage + GameManager.get_level_damage_bonus()
				if is_crit:
					final_dmg *= float(weapon_stats.get("crit_multiplier", CRIT_MULTIPLIER))
					e.take_damage(final_dmg, _dash_attack_dir)
					_spawn_crit_number(e.global_position, final_dmg)
				else:
					e.take_damage(final_dmg, _dash_attack_dir)
					_spawn_hit_spark(e.global_position)

	# big trail + shake
	_start_trail()
	_shake_amp = maxf(_shake_amp, 4.0)
	_hit_pause = 0.06
	AudioLib2D.play("dash_attack")

	if _body_sprite and _body_sprite.hframes >= 8:
		_body_sprite.frame = 18

	await get_tree().create_timer(0.2).timeout
	_weapon_sprite.visible = false
	_trail_line.visible = false
	_is_dash_attacking = false
	if state in [State.ATTACK, State.ALT_ATTACK]:
		state = State.IDLE


func _swap_weapon_slot(slot: int) -> void:
	if not GameManager.inventory:
		return
	var all_items := GameManager.inventory.get_all_items()
	var weapons: Array = []
	for item in all_items:
		var item_id: String = item.get("id", "")
		if WeaponData.WEAPONS.has(item_id):
			weapons.append(item_id)
	if slot >= weapons.size():
		return
	var new_weapon: String = weapons[slot]
	if new_weapon == weapon:
		return
	GameManager.inventory.equip_weapon(new_weapon)
	GameManager.current_equipment["weapon"] = new_weapon
	weapon = new_weapon
	_weapon_sprite.texture = _weapon_texture()
	weapon_changed.emit(weapon)
	AudioLib2D.play("equip")
	# visual feedback
	_flash_screen(Color(0.3, 0.6, 0.9, 0.15))


func apply_status_effect(effect: String, duration: float, damage_per_tick: float = 0.0) -> void:
	if effect in active_effects:
		active_effects[effect] = maxf(active_effects[effect], duration)
	else:
		active_effects[effect] = duration
	status_effect_applied.emit(effect, duration)
	# visual + audio feedback per effect
	match effect:
		"poison":
			if _body_sprite: _body_sprite.modulate = Color(0.4, 0.9, 0.3)
			_show_status_label("POISONED", Color(0.3, 0.8, 0.2))
			AudioLib2D.play("status_poison")
		"burn":
			if _body_sprite: _body_sprite.modulate = Color(1.0, 0.5, 0.1)
			_show_status_label("BURNING", Color(1.0, 0.4, 0.0))
			AudioLib2D.play("status_burn")
		"freeze":
			if _body_sprite: _body_sprite.modulate = Color(0.4, 0.7, 1.0)
			_show_status_label("FROZEN", Color(0.3, 0.6, 1.0))
			AudioLib2D.play("status_freeze")
		"bleed":
			if _body_sprite: _body_sprite.modulate = Color(0.9, 0.3, 0.3)
			_show_status_label("BLEEDING", Color(0.9, 0.1, 0.1))
			AudioLib2D.play("status_bleed")
		"slow":
			_show_status_label("SLOWED", Color(0.5, 0.5, 0.7))
			AudioLib2D.play("status_slow")


func _process_status_effects() -> void:
	if active_effects.is_empty():
		return
	var expired: Array = []
	for effect in active_effects:
		active_effects[effect] -= 0.5
		if active_effects[effect] <= 0.0:
			expired.append(effect)
			continue
		# look up effect info from StatusEffectSystem
		var info: Dictionary = StatusEffectSystem.get_effect_info(effect)
		var dmg: float = info.get("damage_per_tick", 0.0)
		var prevents_kill: bool = info.get("prevents_kill", false)
		if dmg > 0.0:
			var min_hp := 1.0 if prevents_kill else 0.0
			hp = maxf(min_hp, hp - dmg)
			hp_changed.emit(hp, max_hp)
			_spawn_status_particles(info.get("color", Color.WHITE))
			AudioLib2D.play("status_tick", -14.0)
			if hp <= 0.0:
				_die()
		# freeze slow is handled in _physics_process via has_status_effect

	for effect in expired:
		active_effects.erase(effect)
		AudioLib2D.play("status_expire")
	# restore sprite color if no effects remain
	if active_effects.is_empty() and _body_sprite:
		_body_sprite.modulate = Color.WHITE


func _spawn_status_particles(color: Color) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 4
	p.lifetime = 0.4
	p.explosiveness = 0.8
	p.direction = Vector2.UP
	p.spread = 60.0
	p.initial_velocity_min = 10.0
	p.initial_velocity_max = 25.0
	p.gravity = Vector2(0, -20)
	p.scale_amount_min = 0.2
	p.scale_amount_max = 0.5
	p.color = color
	p.position = position + Vector2(randf_range(-4, 4), randf_range(-8, 0))
	p.z_index = 7
	get_parent().add_child(p)
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)


func _show_status_label(text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = position + Vector2(-16, -28)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 18.0, 1.2)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.2)
	tw.tween_callback(lbl.free)


func _spawn_combo_text(pos: Vector2, damage: float, is_crit: bool) -> void:
	var text := "-" + str(int(damage))
	var color := Color.WHITE
	if is_crit:
		text = "CRIT! -" + str(int(damage))
		color = Color(1.0, 0.3, 0.1)
	elif _combo_count >= 2:
		text = "COMBO x%d -%d" % [_combo_count + 1, int(damage)]
		color = Color(1.0, 0.8, 0.2)

	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12 if not is_crit else 14)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = pos + Vector2(-20, -24)
	lbl.z_index = 10
	get_parent().add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 20.0, 0.5)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.free)


func _spawn_combo_indicator(pos: Vector2, combo: int) -> void:
	var colors := [Color.WHITE, Color(0.4, 0.8, 1.0), Color(1.0, 0.8, 0.2), Color(1.0, 0.3, 0.1)]
	var color: Color = colors[mini(combo, colors.size() - 1)]
	var indicator := Label.new()
	indicator.text = "x%d" % (combo + 1)
	indicator.add_theme_font_size_override("font_size", 10)
	indicator.add_theme_color_override("font_color", color)
	indicator.position = pos + Vector2(8, -16)
	indicator.z_index = 10
	get_parent().add_child(indicator)
	var tw := create_tween()
	tw.tween_property(indicator, "position:y", indicator.position.y - 12.0, 0.4)
	tw.parallel().tween_property(indicator, "modulate:a", 0.0, 0.4)
	tw.tween_callback(indicator.free)


func get_combo_count() -> int:
	return _combo_count


func has_status_effect(effect: String) -> bool:
	return active_effects.has(effect)


func clear_status_effect(effect: String) -> void:
	active_effects.erase(effect)
	if active_effects.is_empty() and _body_sprite:
		_body_sprite.modulate = Color.WHITE


func _weapon_texture():
	var path := "res://assets/2d/weapons/%s.png" % weapon
	if ResourceLoader.exists(path):
		return load(path)
	var img := Image.create(12, 4, false, Image.FORMAT_RGBA8)
	match weapon:
		"hunter_blade":
			for x in range(2, 10): img.set_pixel(x, 1, Color(0.65, 0.68, 0.72))
			for x in range(4, 9): img.set_pixel(x, 0, Color(0.75, 0.78, 0.82))
			img.set_pixel(10, 1, Color(0.85, 0.88, 0.92))
			img.set_pixel(1, 2, Color(0.40, 0.35, 0.25))
		"iron_sword":
			for x in range(1, 9): img.set_pixel(x, 1, Color(0.55, 0.55, 0.60))
			img.set_pixel(0, 1, Color(0.60, 0.45, 0.25))
		"pulse_pistol":
			for x in range(4, 9): img.set_pixel(x, 1, Color(0.25, 0.45, 0.75))
			img.set_pixel(9, 1, Color(0.40, 0.80, 1.0))
		"phase_blade":
			for x in range(1, 9):
				img.set_pixel(x, 0, Color(0.6, 0.2, 0.8, 0.5))
				img.set_pixel(x, 1, Color(0.8, 0.4, 1.0))
				img.set_pixel(x, 2, Color(0.6, 0.2, 0.8, 0.5))
		_:
			for x in range(2, 8): img.set_pixel(x, 1, Color(0.55, 0.55, 0.60))
	return ImageTexture.create_from_image(img)
