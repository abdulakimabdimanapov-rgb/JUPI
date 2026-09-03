extends CharacterBody2D
class_name EnemyMVP

signal enemy_died(enemy: Node2D)

## Enemy types: "guard" (default), "fast", "boss"
@export var enemy_type: String = "guard"

# Stats (set by _setup_stats)
var hp: float = 40.0
var max_hp: float = 40.0
var damage: float = 10.0
var speed: float = 45.0
var detection_range: float = 100.0
var attack_range: float = 20.0
var attack_cd: float = 1.2
var xp_reward: float = 20.0

enum State { IDLE, CHASE, ATTACK, RETREAT, DEAD }
var _state: int = State.IDLE
var _attack_timer := 0.0
var _retreat_timer := 0.0

# Status effects
var _bleed_timer := 0.0
var _bleed_dps := 0.0
var _stun_timer := 0.0
var _effect_tick := 0.0

var _sprite: Sprite2D
var _hp_bar_bg: ColorRect
var _hp_bar: ColorRect
var _facing := Vector2.RIGHT


func _ready():
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)
	_setup_stats()
	_build_visuals()


func _setup_stats():
	match enemy_type:
		"fast":
			hp = 25.0; max_hp = 25.0; damage = 8.0
			speed = 80.0; detection_range = 130.0; xp_reward = 15.0
		"boss":
			hp = 200.0; max_hp = 200.0; damage = 22.0
			speed = 35.0; detection_range = 160.0; attack_range = 28.0
			attack_cd = 2.0; xp_reward = 120.0
		_:  # guard
			hp = 40.0; max_hp = 40.0; damage = 10.0
			speed = 45.0; detection_range = 110.0; xp_reward = 20.0


func _build_visuals():
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	match enemy_type:
		"fast":
			_sprite.modulate = Color(0.4, 0.7, 0.4)
		"boss":
			_sprite.modulate = Color(0.8, 0.2, 0.2)
		_:
			_sprite.modulate = Color(0.6, 0.5, 0.4)
	var img := Image.create(10, 12, false, Image.FORMAT_RGBA8)
	var body_color := _sprite.modulate
	# Head
	for x in range(3, 7):
		for y in range(0, 3):
			img.set_pixel(x, y, body_color.lightened(0.1))
	# Body
	for x in range(2, 8):
		for y in range(3, 9):
			img.set_pixel(x, y, body_color)
	# Legs
	for x in range(3, 5):
		for y in range(9, 12):
			img.set_pixel(x, y, body_color.darkened(0.15))
	for x in range(5, 7):
		for y in range(9, 12):
			img.set_pixel(x, y, body_color.darkened(0.15))
	# Eyes
	img.set_pixel(4, 1, Color(0.9, 0.2, 0.1))
	img.set_pixel(5, 1, Color(0.9, 0.2, 0.1))
	# Boss crown
	if enemy_type == "boss":
		for x in range(3, 7):
			img.set_pixel(x, 0, Color(1.0, 0.85, 0.2))
	_sprite.texture = ImageTexture.create_from_image(img)
	add_child(_sprite)
	# HP bar background
	_hp_bar_bg = ColorRect.new()
	_hp_bar_bg.color = Color(0.08, 0.08, 0.10, 0.7)
	_hp_bar_bg.position = Vector2(-7, -12)
	_hp_bar_bg.size = Vector2(14, 3)
	add_child(_hp_bar_bg)
	# HP bar fill
	_hp_bar = ColorRect.new()
	_hp_bar.color = Color(0.80, 0.20, 0.20)
	_hp_bar.position = Vector2(-6, -11)
	_hp_bar.size = Vector2(12, 1)
	add_child(_hp_bar)


func _physics_process(delta: float):
	if _state == State.DEAD:
		return

	# Tick timers
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_process_effects(delta)

	# Stun blocks all actions
	if _stun_timer > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Find player
	var player := _find_player()

	# State machine
	match _state:
		State.IDLE:
			velocity = Vector2.ZERO
			if player and global_position.distance_to(player.global_position) < detection_range:
				_state = State.CHASE
		State.CHASE:
			if not player or global_position.distance_to(player.global_position) > detection_range * 1.5:
				_state = State.IDLE
				velocity = Vector2.ZERO
			else:
				var dir: Vector2 = (player.global_position - global_position).normalized()
				velocity = dir * speed
				_facing = dir
				if global_position.distance_to(player.global_position) <= attack_range:
					_state = State.ATTACK
		State.ATTACK:
			velocity = Vector2.ZERO
			if _attack_timer <= 0.0:
				_do_attack()
				_attack_timer = attack_cd
			if not player or global_position.distance_to(player.global_position) > attack_range + 12.0:
				_state = State.CHASE
		State.RETREAT:
			_retreat_timer -= delta
			velocity = -_facing * speed * 0.5
			if _retreat_timer <= 0.0:
				_state = State.CHASE

	move_and_slide()

	# Visual updates
	if _sprite:
		_sprite.flip_h = _facing.x < 0.0
	_update_hp_bar()


func _do_attack():
	var player := _find_player()
	if player and global_position.distance_to(player.global_position) <= attack_range + 10.0:
		if player.has_method("take_damage"):
			player.take_damage(damage, (player.global_position - global_position).normalized())
			AudioLib2D.play("hurt")


func _find_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("player") as CharacterBody2D


func take_damage(amount: float, from_dir: Vector2 = Vector2.ZERO):
	if _state == State.DEAD:
		return

	hp -= amount
	_spawn_damage_number(amount)

	# Flash white
	if _sprite:
		_sprite.modulate = Color(1.5, 0.5, 0.5)
		var tw := create_tween()
		tw.tween_property(_sprite, "modulate", Color.WHITE, 0.2)

	# Knockback
	velocity = from_dir.normalized() * 80.0

	# React to damage
	if _state in [State.IDLE, State.RETREAT]:
		_state = State.CHASE

	# Low HP → retreat
	if hp > 0.0 and hp < max_hp * 0.3 and _state != State.RETREAT:
		_state = State.RETREAT
		_retreat_timer = 0.8

	if hp <= 0.0:
		_die()


func apply_status(effect: String, duration: float):
	match effect:
		"bleed":
			_bleed_timer = duration
			_bleed_dps = 3.0
			_spawn_status_label("BLD", Color(0.9, 0.1, 0.1))
		"stun":
			_stun_timer = duration
			_spawn_status_label("STN", Color(0.8, 0.7, 0.3))


func _die():
	_state = State.DEAD
	velocity = Vector2.ZERO
	enemy_died.emit(self)
	# Give XP to the player directly
	var player := _find_player()
	if player and player.has_method("add_xp"):
		player.add_xp(xp_reward)
	GameManager.total_kills += 1
	# Drop loot
	if randf() < 0.35:
		GameManager.add_currency(randi_range(5, 15))
		_spawn_loot_drop()
	_spawn_death_effect()
	var tw := create_tween()
	tw.tween_property(_sprite, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)


func _update_hp_bar():
	var frac := clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.size.x = frac * 12.0
	_hp_bar.color = Color(0.8, 0.2, 0.2).lerp(Color(0.2, 0.8, 0.2), frac)
	var show_bars := hp < max_hp and hp > 0.0
	_hp_bar_bg.visible = show_bars
	_hp_bar.visible = show_bars


func _process_effects(delta: float):
	# Bleed
	if _bleed_timer > 0.0:
		_bleed_timer -= delta
		_effect_tick -= delta
		if _effect_tick <= 0.0:
			_effect_tick = 0.5
			hp -= _bleed_dps
			_spawn_damage_number(_bleed_dps)
			if hp <= 0.0:
				_die()
				return  # stop processing after death
	if _bleed_timer <= 0.0:
		_bleed_dps = 0.0
	# Stun
	if _stun_timer > 0.0:
		_stun_timer -= delta


func _spawn_damage_number(amount: float):
	var lbl := Label.new()
	lbl.text = "-%d" % int(amount)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl.position = Vector2(-8, -18)
	lbl.z_index = 10
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 16.0, 0.4)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.tween_callback(lbl.queue_free)


func _spawn_status_label(text: String, color: Color):
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = Vector2(-6, -22)
	lbl.z_index = 10
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 12.0, 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)


func _spawn_death_effect():
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = true
	p.amount = 12
	p.lifetime = 0.5
	p.explosiveness = 0.8
	p.direction = Vector2.UP
	p.spread = 160.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.gravity = Vector2(0, 80)
	p.scale_amount_min = 0.3
	p.scale_amount_max = 0.8
	p.color = Color(0.8, 0.3, 0.2, 0.8)
	p.position = Vector2(0, -4)
	p.z_index = 6
	add_child(p)
	get_tree().create_timer(0.6).timeout.connect(p.queue_free)


func _spawn_loot_drop():
	var coin := Sprite2D.new()
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	coin.position = Vector2(randf_range(-6, 6), randf_range(-4, 4))
	coin.z_index = 3
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	for x in range(4):
		for y in range(4):
			var d := Vector2(x - 1.5, y - 1.5).length()
			if d < 1.8:
				img.set_pixel(x, y, Color(1.0, 0.85, 0.2))
	coin.texture = ImageTexture.create_from_image(img)
	add_child(coin)
	var tw := create_tween()
	tw.tween_property(coin, "position:y", coin.position.y - 8.0, 0.3)
	tw.parallel().tween_property(coin, "modulate:a", 0.0, 0.4).set_delay(0.2)
	tw.tween_callback(coin.queue_free)
