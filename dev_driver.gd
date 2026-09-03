extends Node
## JUPI foundation behavioral test driver (temporary — deleted after verification).
## Lives as a child of the tree root so real scene changes (start -> game -> restart)
## never free it. Emulates a user pressing keys and buttons.

const T := 16
const MAP_W := 40
const MAP_H := 30
const CENTER := Vector2(320, 240)
const SPAWN := Vector2(MAP_W / 2 * T, MAP_H / 2 * T)
const CLAMP_MIN := Vector2(T, T)
const CLAMP_MAX := Vector2((MAP_W - 1) * T, (MAP_H - 1) * T)

const GAME_SCENE: PackedScene = preload("res://scenes/2d/game_mvp.tscn")
const START_SCENE: PackedScene = preload("res://scenes/2d/start_screen_mvp.tscn")

var failures: Array[String] = []
var passed := 0
var _player: CharacterBody2D

func _ready() -> void:
	call_deferred("_run")

func _ok(cond: bool, label: String) -> void:
	if cond:
		passed += 1
		print("  PASS: ", label)
	else:
		failures.append(label)
		print("  FAIL: ", label)

func _find_button(node: Node, text_part: String) -> Button:
	if node is Button and text_part in (node as Button).text:
		return node
	for c in node.get_children():
		var r := _find_button(c, text_part)
		if r:
			return r
	return null

func _run() -> void:
	# Boot through the real start screen (like a user launching the game).
	get_tree().change_scene_to_packed(START_SCENE)
	await _wait_until_scene("StartScreen")
	if get_tree().current_scene == null:
		_ok(false, "start screen loaded")
		_finish()
		return
	print("== TEST 1: launch ==")
	_ok(get_tree().current_scene.name == "StartScreen", "start screen loads")
	var start_btn := _find_button(get_tree().current_scene, "START GAME")
	_ok(start_btn != null, "start screen shows START button")
	if start_btn == null:
		_finish()
		return
	start_btn.pressed.emit()
	await _wait_until_scene("GameWorld")
	_ok(get_tree().current_scene != null and get_tree().current_scene.name == "GameWorld", "START opens the GameWorld scene")
	if get_tree().current_scene == null or get_tree().current_scene.name != "GameWorld":
		_finish()
		return
	await _wait_physics(3)

	# ── TEST 2: world renders ──────────────────────────────────────────────
	print("== TEST 2: world ==")
	var world: Node2D = get_tree().current_scene
	_ok(world.visible, "world node visible")
	var tilemap: TileMapLayer = null
	for c in world.get_children():
		if c is TileMapLayer:
			tilemap = c
			break
	_ok(tilemap != null and tilemap.get_used_cells().size() > 0, "world has a populated tilemap")
	_ok(world.get_node_or_null("Enemies") != null
			and world.get_node("Enemies").get_child_count() > 0, "world spawns enemies")
	_ok(world.get_node_or_null("NPCs") != null and world.get_node_or_null("Props") != null,
			"world containers present")

	# ── TEST 3: player visible ─────────────────────────────────────────────
	print("== TEST 3: player ==")
	_player = world.get_node_or_null("Player")
	_ok(_player != null, "player node exists")
	if _player == null:
		_finish()
		return
	_ok(_player.visible, "player is visible")
	var has_body := false
	for c in _player.get_children():
		if c is Sprite2D and c.visible and c.texture != null:
			has_body = true
	_ok(has_body, "player has a visible sprite")
	_ok(_player.get_node_or_null("Camera") is Camera2D, "player has a camera")
	_ok(_player.position.distance_to(SPAWN) < 1.0, "player at spawn position")
	_ok(world.get_node_or_null("HUD") is CanvasLayer, "HUD present")

	# Keep enemies from interfering with deterministic movement checks.
	var enemy_container := world.get_node("Enemies")
	for e in enemy_container.get_children():
		e.queue_free()
	await _wait_physics(2)

	# ── No self-movement ───────────────────────────────────────────────────
	print("== no self-movement ==")
	var p0 := _player.global_position
	await _wait_physics(50)
	_ok(_player.global_position.distance_to(p0) < 0.5, "player does not move on its own")

	# ── TEST 4-7: movement directions (shared actions = WASD + arrows) ─────
	print("== TEST 4-7: movement ==")
	await _check_direction("move_up", "y", -1.0, "move_up (W / Up)")
	await _check_direction("move_down", "y", 1.0, "move_down (S / Down)")
	await _check_direction("move_left", "x", -1.0, "move_left (A / Left)")
	await _check_direction("move_right", "x", 1.0, "move_right (D / Right)")

	# ── Arrow keys bound and actually drive movement ───────────────────────
	print("== arrow key bindings ==")
	_ok(_action_has_key("move_up", KEY_UP), "move_up bound to Up arrow")
	_ok(_action_has_key("move_down", KEY_DOWN), "move_down bound to Down arrow")
	_ok(_action_has_key("move_left", KEY_LEFT), "move_left bound to Left arrow")
	_ok(_action_has_key("move_right", KEY_RIGHT), "move_right bound to Right arrow")
	await _check_physical_key(KEY_UP, "physical Up arrow moves player up")
	await _check_physical_key(KEY_LEFT, "physical Left arrow moves player left")
	await _check_physical_key(KEY_DOWN, "physical Down arrow moves player down")
	await _check_physical_key(KEY_RIGHT, "physical Right arrow moves player right")

	# ── TEST 8: stops after release ────────────────────────────────────────
	print("== TEST 8: stop ==")
	await _recenter()
	Input.action_press("move_right")
	await _wait_physics(25)
	Input.action_release("move_right")
	await _wait_physics(20)
	var s1 := _player.global_position
	await _wait_physics(20)
	_ok(_player.global_position.distance_to(s1) < 1.0, "player stops after key release")
	_ok(_player.velocity.length() < 5.0, "player velocity near zero after release")

	# ── TEST 9: world bounds ───────────────────────────────────────────────
	print("== TEST 9: bounds ==")
	await _check_bound("move_right", "x", 1.0, CLAMP_MAX.x)
	await _check_bound("move_left", "x", -1.0, CLAMP_MIN.x)
	await _check_bound("move_down", "y", 1.0, CLAMP_MAX.y)
	await _check_bound("move_up", "y", -1.0, CLAMP_MIN.y)
	var cam: Camera2D = _player.get_node("Camera")
	_ok(cam.limit_right == MAP_W * T and cam.limit_bottom == MAP_H * T
			and cam.limit_left == 0 and cam.limit_top == 0,
			"camera limits match world size")

	# ── TEST 10: restart returns to initial state ──────────────────────────
	print("== TEST 10: restart ==")
	GameManager.total_kills = 7
	GameManager.player_currency = 99
	_player.take_damage(99999.0)
	await _wait_physics(6)
	var overlay := get_tree().current_scene.get_node_or_null("GameOver")
	_ok(overlay != null, "game over overlay appears on death")
	var restart_btn := _find_button(overlay, "RESTART") if overlay else null
	_ok(restart_btn != null, "RESTART button shown")
	if restart_btn:
		restart_btn.pressed.emit()
	await _wait_until_scene("GameWorld")
	_ok(get_tree().current_scene != null and get_tree().current_scene.name == "GameWorld", "restart reloads the game scene")
	if get_tree().current_scene == null or get_tree().current_scene.name != "GameWorld":
		_finish()
		return
	_player = get_tree().current_scene.get_node_or_null("Player")
	_ok(_player != null, "fresh player spawned after restart")
	if _player:
		_ok(_player.alive and _player.hp >= _player.max_hp - 0.5, "player HP restored")
		_ok(_player.position.distance_to(SPAWN) < 1.0, "player back at spawn")
		_ok(_player.level == 1, "player level reset")
		_ok(get_tree().current_scene.get_node("Enemies").get_child_count() > 0, "enemies respawned")
		var tm2: TileMapLayer = null
		for c in get_tree().current_scene.get_children():
			if c is TileMapLayer:
				tm2 = c
				break
		_ok(tm2 != null and tm2.get_used_cells().size() > 0, "world rebuilt after restart")
	_ok(GameManager.total_kills == 0, "run stats reset on restart (kills)")
	_ok(GameManager.player_currency == 0, "run stats reset on restart (currency)")

	_finish()

func _action_has_key(action: String, key: Key) -> bool:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var ie: InputEventKey = ev
			if ie.physical_keycode == key or ie.keycode == key:
				return true
	return false

func _check_direction(action: String, axis: String, sign: float, label: String) -> void:
	await _recenter()
	var p0: Vector2 = _player.global_position
	Input.action_press(action)
	await _wait_physics(40)
	Input.action_release(action)
	await _wait_physics(15)
	var diff := _player.global_position - p0
	var delta: float = (diff.x if axis == "x" else diff.y) * sign
	_ok(delta > 20.0, label + " moves player (" + str(delta) + ")")

func _check_physical_key(key: Key, label: String) -> void:
	await _recenter()
	var p0: Vector2 = _player.global_position
	var press := InputEventKey.new()
	press.physical_keycode = key
	press.pressed = true
	Input.parse_input_event(press)
	await _wait_physics(25)
	var release := InputEventKey.new()
	release.physical_keycode = key
	release.pressed = false
	Input.parse_input_event(release)
	await _wait_physics(15)
	_ok(_player.global_position.distance_to(p0) > 10.0, label)

func _check_bound(action: String, axis: String, sign: float, bound: float) -> void:
	await _recenter()
	Input.action_press(action)
	for i in range(170):
		await get_tree().physics_frame
		var v: float = _player.global_position[axis]
		if sign > 0.0 and v > bound + 0.5:
			_ok(false, action + " ran past upper bound " + str(v))
			Input.action_release(action)
			return
		if sign < 0.0 and v < bound - 0.5:
			_ok(false, action + " ran past lower bound " + str(v))
			Input.action_release(action)
			return
	Input.action_release(action)
	await _wait_physics(10)
	var end_v: float = _player.global_position[axis]
	_ok(absf(end_v - bound) <= 2.0, action + " stops at bound " + str(bound) + " (at " + str(end_v) + ")")

func _recenter() -> void:
	if not is_instance_valid(_player):
		return
	_player.global_position = CENTER
	_player.velocity = Vector2.ZERO
	await _wait_physics(1)

func _wait_physics(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame

func _wait_until_scene(name_part: String) -> void:
	for i in range(60):
		await get_tree().physics_frame
		if get_tree().current_scene != null and name_part in get_tree().current_scene.name:
			return

func _finish() -> void:
	print("========================================")
	print("PASSED: ", passed, "  FAILED: ", failures.size())
	for f in failures:
		print("  - ", f)
	print("RESULT: ", "ALL PASS" if failures.is_empty() else "HAS FAILURES")
	get_tree().quit(0 if failures.is_empty() else 1)
                               