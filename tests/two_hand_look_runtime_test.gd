extends Node
## JUPI step 8 runtime test: two-hand protocol - LEFT pinch = camera look.
##
## Instantiates the real main scene, lets the tracker's first UDP packet
## auto-engage hand mode, then drives the hand aim source with synthetic
## packets and verifies that:
## - mouse aiming is the default and no tracker data means no hand mode;
## - the first real tracker packet auto-switches to hand mode;
## - starting the LEFT pinch establishes a baseline: the first position
##   packet (even far away) does NOT jump the camera;
## - while pinched, RELATIVE hand movement rotates the camera: hand right
##   -> look right (yaw), hand up -> look up (pitch);
## - sub-deadzone jitter does not rotate the camera;
## - releasing the LEFT pinch stops rotation and later position packets
##   are ignored;
## - pinching again starts from a fresh baseline (no jump);
## - right-hand position packets rotate nothing and shoot nothing;
## - mouse motion is ignored in hand mode (the left hand owns the camera);
## - Escape is delegated to the wrapped mouse source;
## - toggling back to mouse mode restores mouse aiming without a view snap.
##
## Run: godot --headless --path . res://tests/two_hand_look_runtime_test.tscn
## Exit code 0 = all checks passed, 1 = failure.

const MAIN_SCENE := "res://scenes/main_3d.tscn"
const UDP_HOST := "127.0.0.1"
const UDP_PORT := 37020
const HandScript := preload("res://scripts/aim_source_hand.gd")

var _checks := 0
var _fails := 0

var _main: Node3D
var _player: CharacterBody3D
var _head: Camera3D
var _mouse
var _hand
var _sender := PacketPeerUDP.new()


func _ready() -> void:
	_main = load(MAIN_SCENE).instantiate()
	_main.auto_start_tracker = false  # tests drive the tracker synthetically
	add_child(_main)

	_player = _main.get_node("Player")
	_head = _player.get_node("Head")
	_mouse = _player._mouse_source
	_hand = _player._hand_source
	_sender.set_dest_address(UDP_HOST, UDP_PORT)

	# Let _ready / physics settle before poking the world. The target's
	# sway does not matter here (we never fire), so it can keep running.
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame

	print("=== JUPI step 8 runtime test (two-hand: left pinch = camera look) ===")

	await _check_default_and_auto_hand()
	await _check_no_jump_on_pinch_start()
	await _check_relative_yaw_look()
	await _check_relative_pitch_look()
	await _check_deadzone_ignored()
	await _check_release_stops_look()
	await _check_re_pinch_starts_fresh()
	await _check_right_position_packets_do_nothing()
	await _check_mouse_motion_ignored_in_hand_mode()
	await _check_escape_delegated()
	await _check_toggle_back_no_snap()

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


func _send(text: String) -> void:
	_sender.put_packet(text.to_ascii_buffer())


## Lets the player's _process poll the UDP socket a few times.
func _settle() -> void:
	for i in 8:
		await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame


## The orientation the camera currently faces: (yaw, pitch) radians, as
## applied to the body yaw / head pitch by the active aim source.
func _cam_aim() -> Vector2:
	return Vector2(_player.rotation.y, _head.rotation.x)


func _press_h() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_H
	ev.physical_keycode = KEY_H
	ev.pressed = true
	_player._unhandled_input(ev)
	await get_tree().process_frame


func _shots() -> int:
	return _main._shots


func _check_default_and_auto_hand() -> void:
	_check(_player.aim_source == _mouse, "mouse aiming is active by default")
	_check(not _hand.has_received_data(), "no tracker packets yet -> hand mode stays off")
	# The main scene arms auto-hand once it spawns the tracker; replicate
	# that, then the first presence packet must engage hand mode.
	_player.arm_auto_hand()
	_send("hand,left")
	await _settle()
	_check(_player.aim_source == _hand, "the first tracker packet auto-switches to hand mode")
	_check(_hand.has_received_data(), "the presence packet counted as tracker data")


func _check_no_jump_on_pinch_start() -> void:
	var before: Vector2 = _cam_aim()
	_send("left,pinch")
	await _settle()
	# Far-away first position after the pinch: this must ONLY establish
	# the baseline. Absolute position never steers the camera.
	_send("left,0.9,0.1")
	await _settle()
	_check(
		before.distance_to(_cam_aim()) < 1e-9,
		"starting the left pinch does not jump the camera (first packet is baseline only)"
	)


func _check_relative_yaw_look() -> void:
	var before: Vector2 = _cam_aim()
	# Hand moved RIGHT by 0.01 normalized units (mirrored preview) while
	# pinched -> camera looks right: yaw -= dx * YAW_SENSITIVITY.
	_send("left,0.91,0.1")
	await _settle()
	var expected: Vector2 = before + Vector2(-0.01 * HandScript.YAW_SENSITIVITY, 0.0)
	_check(
		_cam_aim().distance_to(expected) < 1e-6,
		"left hand moving right rotates the camera right by the delta (%.4f rad)" % (0.01 * HandScript.YAW_SENSITIVITY)
	)
	# Hand moved LEFT again -> camera looks back left.
	before = _cam_aim()
	_send("left,0.89,0.1")
	await _settle()
	expected = before + Vector2(0.02 * HandScript.YAW_SENSITIVITY, 0.0)
	_check(
		_cam_aim().distance_to(expected) < 1e-6,
		"left hand moving left rotates the camera left by the delta"
	)


func _check_relative_pitch_look() -> void:
	var before: Vector2 = _cam_aim()
	# Hand moved UP (smaller y) by 0.03 normalized units while pinched ->
	# camera looks up: pitch -= dy * PITCH_SENSITIVITY.
	_send("left,0.89,0.07")
	await _settle()
	var expected: Vector2 = before + Vector2(0.0, 0.03 * HandScript.PITCH_SENSITIVITY)
	_check(
		_cam_aim().distance_to(expected) < 1e-6,
		"left hand moving up rotates the camera up by the delta (%.4f rad)" % (0.03 * HandScript.PITCH_SENSITIVITY)
	)
	# Hand moved DOWN -> camera looks back down.
	before = _cam_aim()
	_send("left,0.89,0.12")
	await _settle()
	expected = before + Vector2(0.0, -0.05 * HandScript.PITCH_SENSITIVITY)
	_check(
		_cam_aim().distance_to(expected) < 1e-6,
		"left hand moving down rotates the camera down by the delta"
	)


func _check_deadzone_ignored() -> void:
	var before: Vector2 = _cam_aim()
	# 0.0003 normalized units of travel is below the deadzone: sub-pixel
	# jitter must not make the camera drift while a pinch is held still.
	_send("left,0.8903,0.12")
	await _settle()
	_check(
		before.distance_to(_cam_aim()) < 1e-9,
		"sub-deadzone hand jitter does not rotate the camera"
	)


func _check_release_stops_look() -> void:
	_send("left,release")
	await _settle()
	var before: Vector2 = _cam_aim()
	# After the release the tracker stops sending positions; even if one
	# sneaks through, Godot must ignore it (not aiming anymore).
	_send("left,0.99,0.99")
	await _settle()
	_check(
		before.distance_to(_cam_aim()) < 1e-9,
		"releasing the left pinch stops camera rotation (later packets ignored)"
	)


func _check_re_pinch_starts_fresh() -> void:
	var before: Vector2 = _cam_aim()
	_send("left,pinch")
	await _settle()
	_send("left,0.1,0.9")  # new far-away baseline
	await _settle()
	_check(
		before.distance_to(_cam_aim()) < 1e-9,
		"a second left pinch also starts from a fresh baseline (no jump)"
	)
	# And relative movement still works after re-arming.
	_send("left,0.12,0.9")
	await _settle()
	var expected: Vector2 = before + Vector2(-0.02 * HandScript.YAW_SENSITIVITY, 0.0)
	_check(
		_cam_aim().distance_to(expected) < 1e-6,
		"camera rotation works again after re-pinching"
	)
	_send("left,release")
	await _settle()


func _check_right_position_packets_do_nothing() -> void:
	var before: Vector2 = _cam_aim()
	var shots_before: int = _shots()
	# The protocol only has right,pinch for the right hand. A stray
	# position packet for the right hand is unknown -> ignored entirely.
	_send("right,0.5,0.5")
	_send("right,0.9,0.1")
	await _settle()
	_check(before.distance_to(_cam_aim()) < 1e-9, "right-hand movement packets do not rotate the camera")
	_check(_shots() == shots_before, "right-hand movement packets do not shoot")


func _check_mouse_motion_ignored_in_hand_mode() -> void:
	var before: Vector2 = _cam_aim()
	var ev := InputEventMouseMotion.new()
	ev.relative = Vector2(200, -100)
	_player._unhandled_input(ev)
	await _settle()
	_check(
		before.distance_to(_cam_aim()) < 1e-9,
		"mouse motion does not rotate the camera in hand mode (the left hand owns look)"
	)


func _check_escape_delegated() -> void:
	var was_active: bool = _mouse.is_active()
	var ev := InputEventKey.new()
	ev.keycode = KEY_ESCAPE
	ev.physical_keycode = KEY_ESCAPE
	ev.pressed = true
	var consumed: bool = _hand.handle_input(ev)
	_check(consumed, "Escape is consumed in hand mode (delegated to the mouse source)")
	if DisplayServer.get_name() != "headless":
		_check(_mouse.is_active() != was_active, "Escape toggles mouse capture (windowed)")


func _check_toggle_back_no_snap() -> void:
	var cam: Vector2 = _cam_aim()
	await _press_h()
	_check(_player.aim_source == _mouse, "H toggles back to mouse aiming")
	_check(
		_mouse.get_aim().distance_to(cam) < 1e-6,
		"toggling modes seeds the mouse source with the current view (no snap)"
	)
