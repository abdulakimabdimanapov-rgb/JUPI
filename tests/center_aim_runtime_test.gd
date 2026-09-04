extends Node
## JUPI step 8 runtime test: permanently centered crosshair + center raycast.
##
## The previous design moved the crosshair to an aim pointer and cast the
## shot ray through it. Step 8 removes that: the crosshair ALWAYS stays at
## 50% X / 50% Y and the ray is always cast through the exact center of
## the camera. A source only ever rotates the camera (mouse look / hand
## look); it can never move a pointer.
##
## Instantiates the real main scene and verifies that:
## - the crosshair starts at screen center and stays there no matter what
##   happens (mouse motion, shots fired, mode toggles);
## - mouse motion still rotates the view (aim -> yaw/pitch), it just must
##   not move the crosshair;
## - aiming the camera exactly at the target and firing hits it through
##   the CENTER ray (Hits increments, target respawns, shot counted);
## - aiming at the floor misses (no Hits, but the shot is counted);
## - WASD movement, mouse look and Escape capture/release still work.
##
## Run: godot --headless --path . res://tests/center_aim_runtime_test.tscn
## Exit code 0 = all checks passed, 1 = failure.

const MAIN_SCENE := "res://scenes/main_3d.tscn"
const EPS := 0.001

var _checks := 0
var _fails := 0

var _main: Node3D
var _player: CharacterBody3D
var _head: Camera3D
var _src  # active aim source (duck-typed interface)
var _mouse
var _target: StaticBody3D
var _crosshair_h: ColorRect
var _crosshair_v: ColorRect


func _ready() -> void:
	_main = load(MAIN_SCENE).instantiate()
	_main.auto_start_tracker = false  # tests drive input synthetically
	add_child(_main)

	_player = _main.get_node("Player")
	_head = _player.get_node("Head")
	_src = _player.aim_source
	_mouse = _player._mouse_source
	_target = _main.get_node("Target")
	_crosshair_h = _main.get_node("CrosshairUI/Root/H")
	_crosshair_v = _main.get_node("CrosshairUI/Root/V")

	# Let _ready / physics settle before poking the world, then stop the
	# target's sway drift so every raycast check is deterministic.
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_main.set_physics_process(false)
	_main._sway_t = 0.0
	_place_target_clean()

	print("=== JUPI step 8 runtime test (center crosshair + center raycast) ===")

	_check_crosshair_centered()
	await _check_mouse_motion_keeps_crosshair_centered()
	await _check_ray_hits_target_at_center()
	_check_crosshair_centered()
	await _check_ray_misses_floor()
	_check_crosshair_centered()
	await _check_wasd_moves()
	await _check_look_applies()
	await _check_escape_capture()

	print("")
	print("RESULT: %d checks, %d failures" % [_checks, _fails])
	if _fails == 0:
		print("ALL CHECKS PASSED")
	get_tree().quit(0 if _fails == 0 else 1)


func _check(cond: bool, name: String) -> void:
	_checks += 1
	if cond:
		print("PASS: " + name)
	else:
		_fails += 1
		print("FAIL: " + name)


## Puts the target back at a known, clearly visible spot (straight ahead
## of the spawn, clear line of sight) and parks the sway there.
func _place_target_clean() -> void:
	_main._anchor = Vector3(0, 0.5, -4)
	_target.position = _main._anchor
	_main._sway_t = 0.0


func _crosshair_at_center() -> bool:
	return (
		absf(_crosshair_h.anchor_left - 0.5) < EPS
		and absf(_crosshair_h.anchor_top - 0.5) < EPS
		and absf(_crosshair_v.anchor_left - 0.5) < EPS
		and absf(_crosshair_v.anchor_top - 0.5) < EPS
	)


## Rotates the active aim source so the CENTER of the camera points
## exactly at `point`, then lets a physics frame apply it.
func _aim_center_at(point: Vector3) -> void:
	var dir: Vector3 = (point - _head.global_position).normalized()
	_src.set_aim(atan2(-dir.x, -dir.z), asin(clampf(dir.y, -1.0, 1.0)))
	await get_tree().physics_frame
	await get_tree().process_frame


## Fire a shot the way the player would: LMB event when the mouse is
## captured, otherwise emit the request signal directly (headless cannot
## always capture the pointer).
func _fire() -> void:
	if _src.is_active():
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		_player._unhandled_input(ev)
	else:
		_player.aim_requested.emit()
	await get_tree().process_frame


func _shots() -> int:
	return _main._shots


func _hits() -> int:
	return int(_main.get_node("CrosshairUI/HitsLabel").text.split(" ")[1])


func _check_crosshair_centered() -> void:
	_check(_crosshair_at_center(), "crosshair is exactly at screen center (50% / 50%)")


func _check_mouse_motion_keeps_crosshair_centered() -> void:
	# Big mouse deltas in both directions: look may change, the crosshair
	# must NOT follow.
	var aim_before: Vector2 = _src.get_aim()
	var ev := InputEventMouseMotion.new()
	ev.relative = Vector2(400, -200)
	_src.handle_input(ev)
	ev.relative = Vector2(-300, 150)
	_src.handle_input(ev)
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(_crosshair_at_center(), "mouse motion does not move the crosshair (it stays centered)")
	# Rotating the view from mouse motion needs a captured pointer, which
	# only exists in a real window; headless skips that half of the check.
	if _src.is_active():
		_check(_src.get_aim() != aim_before, "mouse motion still rotates the view (look updates, crosshair does not)")


func _check_ray_hits_target_at_center() -> void:
	# Point the camera dead center at the target: the center ray must hit
	# it. The crosshair never moved - aiming is pure camera rotation.
	var shots_before: int = _shots()
	await _aim_center_at(_target.global_position)
	var anchor_before: Vector3 = _main._anchor
	_fire()
	_check(_hits() == 1, "center ray aimed at the target hits it (Hits -> 1)")
	_check(_shots() == shots_before + 1, "the aimed shot was counted (shots -> %d)" % _shots())
	_check(_main._anchor != anchor_before, "target respawns after a center-ray hit")


func _check_ray_misses_floor() -> void:
	# Look steeply down at the floor right in front of the player: the
	# center ray hits the floor, which is not the target.
	var shots_before: int = _shots()
	var hits_before: int = _hits()
	_src.set_aim(0.0, deg_to_rad(-66.0))
	await get_tree().physics_frame
	await get_tree().process_frame
	_fire()
	_check(_hits() == hits_before, "center ray at the floor does not increase Hits")
	_check(_shots() == shots_before + 1, "missed shots are still counted")


func _check_wasd_moves() -> void:
	var before: Vector3 = _player.global_position
	Input.action_press("move_forward")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("move_forward")
	_check(_player.global_position.z < before.z - 0.01, "W still moves the player forward")


func _check_look_applies() -> void:
	_src.set_aim(0.3, 0.1)
	await get_tree().physics_frame
	_check(
		absf(_player.rotation.y - 0.3) < EPS and absf(_head.rotation.x - 0.1) < EPS,
		"mouse look still rotates the view (aim applied to body yaw / head pitch)"
	)


func _check_escape_capture() -> void:
	var was_active: bool = _mouse.is_active()
	var ev := InputEventKey.new()
	ev.keycode = KEY_ESCAPE
	ev.physical_keycode = KEY_ESCAPE
	ev.pressed = true
	var consumed: bool = _src.handle_input(ev)
	_check(consumed, "Escape is consumed (mouse capture toggle)")
	if DisplayServer.get_name() != "headless":
		_check(_mouse.is_active() != was_active, "Escape toggles mouse capture (windowed)")
