extends Node
## JUPI step 9 runtime test: open hands walk the player forward.
##
## Instantiates the real main scene and drives the hand aim source with
## synthetic UDP packets, verifying that in hand mode:
## - packets do NOT move the player while mouse mode is active;
## - an OPEN right hand walks the player forward at WALK_SPEED along the
##   view (constant speed, no keyboard needed);
## - pinching the right hand stops it walking (and only a right,release
##   resumes it);
## - a hand leaving the frame (right,gone) stops the walk;
## - an open LEFT hand walks too, and left pinch stops it;
## - walking and camera look work simultaneously (right hand open walks,
##   left pinch + movement turns the view);
## - keyboard movement (W) does nothing in hand mode but WASD still moves
##   the player in mouse mode.
##
## Run: godot --headless --path . res://tests/hand_walk_runtime_test.tscn
## Exit code 0 = all checks passed, 1 = failure.

const MAIN_SCENE := "res://scenes/main_3d.tscn"
const UDP_HOST := "127.0.0.1"
const UDP_PORT := 37020
const PlayerScript := preload("res://scripts/player_3d.gd")
const HandScript := preload("res://scripts/aim_source_hand.gd")
## Physics ticks per second and per-tick distance at WALK_SPEED.
const TICKS_PER_SEC := 60
const TICKS := 30  # 0.5 s of walking

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

	# Let _ready / physics settle. Park the target in a far corner so no
	# stray center-ray shot can ever collide with our walk path, and stop
	# the target sway for good measure.
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_main.set_physics_process(false)
	_main._anchor = Vector3(-8, 0.5, 7)
	_main._target.position = _main._anchor
	_main._sway_t = 0.0

	print("=== JUPI step 9 runtime test (open hands walk forward) ===")

	await _check_mouse_mode_ignores_hands()
	await _press_h()
	await _check_clear_hands()
	await _check_right_open_walks_forward()
	await _check_right_pinch_stops()
	await _check_right_release_resumes()
	await _check_gone_stops()
	await _check_left_open_walks()
	await _check_left_pinch_stops()
	await _check_walk_and_look_together()
	await _check_w_key_ignored_in_hand_mode()
	await _press_h()
	await _check_wasd_still_moves_in_mouse_mode()

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


func _settle() -> void:
	for i in 5:
		await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame


func _physics_run(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame


func _press_h() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_H
	ev.physical_keycode = KEY_H
	ev.pressed = true
	_player._unhandled_input(ev)
	await _settle()


## Resets both hands to absent so every scenario starts clean, and parks
## the player back on open ground facing -Z.
func _check_clear_hands() -> void:
	_send("left,gone")
	_send("right,gone")
	await _settle()
	_player.global_position = Vector3(0, 1, 6)
	_player.rotation.y = 0.0
	await _physics_run(10)  # let gravity settle the body on the floor
	_check(not _hand.is_walking(), "no hands present -> player is not walking")


## Expected displacement over TICKS physics ticks (0.5 s at WALK_SPEED).
func _walk_distance() -> float:
	return PlayerScript.WALK_SPEED * float(TICKS) / float(TICKS_PER_SEC)


func _check_mouse_mode_ignores_hands() -> void:
	_check(_player.aim_source == _mouse, "mouse source is active by default")
	var before: Vector2 = Vector2(_player.global_position.x, _player.global_position.z)
	_send("hand,right")
	await _settle()
	await _physics_run(TICKS)
	var after: Vector2 = Vector2(_player.global_position.x, _player.global_position.z)
	_check(
		before.distance_to(after) < 0.001,
		"open-hand packets do not move the player in mouse mode"
	)


func _check_right_open_walks_forward() -> void:
	_send("hand,right")  # present and open
	await _settle()
	_check(_hand.is_walking(), "an open right hand reports is_walking()")
	var p0: Vector3 = _player.global_position
	await _physics_run(TICKS)
	var p1: Vector3 = _player.global_position
	var dz: float = p1.z - p0.z  # facing -Z (yaw 0): forward is negative Z
	_check(
		absf(dz + _walk_distance()) < 0.15,
		"open right hand walks forward ~%.2f m at WALK_SPEED (moved %.2f m)" % [_walk_distance(), -dz]
	)
	_check(absf(p1.x - p0.x) < 0.05, "walking is straight ahead (no sideways drift)")


func _check_right_pinch_stops() -> void:
	_send("right,pinch")  # open -> pinch: one shot, and this hand stops walking
	await _settle()
	_check(not _hand.is_walking(), "a pinched right hand stops walking")
	var p0: Vector3 = _player.global_position
	await _physics_run(TICKS)
	_check(
		p0.distance_to(_player.global_position) < 0.001,
		"holding the right pinch keeps the player stopped (shots do not move it)"
	)


func _check_right_release_resumes() -> void:
	_send("right,release")  # pinch -> open again
	await _settle()
	_check(_hand.is_walking(), "right,release makes the hand open (walking again)")
	var p0: Vector3 = _player.global_position
	await _physics_run(TICKS)
	_check(
		absf(_player.global_position.z - p0.z + _walk_distance()) < 0.15,
		"releasing the right pinch resumes walking forward"
	)


func _check_gone_stops() -> void:
	var p0: Vector3 = _player.global_position
	await _physics_run(10)  # confirm it was walking first
	_check(absf(_player.global_position.z - p0.z) > 0.1, "hand was walking before leaving")
	_send("right,gone")
	await _settle()
	_check(not _hand.is_walking(), "a hand leaving the frame stops walking")
	p0 = _player.global_position
	await _physics_run(TICKS)
	_check(p0.distance_to(_player.global_position) < 0.001, "no movement after right,gone")


func _check_left_open_walks() -> void:
	_send("hand,left")  # present and open
	await _settle()
	_check(_hand.is_walking(), "an open left hand also reports is_walking()")
	var p0: Vector3 = _player.global_position
	await _physics_run(TICKS)
	_check(
		absf(_player.global_position.z - p0.z + _walk_distance()) < 0.15,
		"open left hand walks forward at WALK_SPEED too"
	)


func _check_left_pinch_stops() -> void:
	_send("left,pinch")
	await _settle()
	_check(not _hand.is_walking(), "a pinched left hand stops walking (camera look arms instead)")
	var p0: Vector3 = _player.global_position
	await _physics_run(TICKS)
	_check(p0.distance_to(_player.global_position) < 0.001, "player stays stopped while left is pinched")
	_send("left,release")
	await _settle()


func _check_walk_and_look_together() -> void:
	# Right hand open (walks) + left hand pinching (look) = move AND turn.
	_send("left,gone")
	_send("hand,right")
	await _settle()
	_send("left,pinch")
	_send("left,0.5,0.5")  # baseline
	await _settle()
	_check(_hand.is_walking(), "walking continues while the left hand looks (right hand open)")
	var yaw_before: float = _player.rotation.y
	var p0: Vector3 = _player.global_position
	# Turn the view with the left pinch, then walk: position must change
	# along the NEW heading while the yaw tracks the hand delta.
	_send("left,0.55,0.5")  # hand right -> look right (yaw decreases)
	await _settle()
	var yaw_after: float = _player.rotation.y
	_check(
		absf(yaw_after - (yaw_before - 0.05 * HandScript.YAW_SENSITIVITY)) < 0.01,
		"left pinch turns the view while walking"
	)
	await _physics_run(TICKS)
	var moved: float = p0.distance_to(_player.global_position)
	_check(
		moved > _walk_distance() * 0.6,
		"player walks forward while turning the camera (moved %.2f m)" % moved
	)
	_send("left,release")
	_send("left,gone")
	_send("right,gone")
	await _settle()


func _check_w_key_ignored_in_hand_mode() -> void:
	_check(_player.aim_source == _hand, "still in hand mode for the W-key check")
	var p0: Vector3 = _player.global_position
	Input.action_press("move_forward")
	await _physics_run(15)
	Input.action_release("move_forward")
	_check(
		p0.distance_to(_player.global_position) < 0.001,
		"W does not move the player in hand mode (gestures own movement)"
	)


func _check_wasd_still_moves_in_mouse_mode() -> void:
	_check(_player.aim_source == _mouse, "H toggled back to mouse mode")
	var p0: Vector3 = _player.global_position
	Input.action_press("move_forward")
	await _physics_run(15)
	Input.action_release("move_forward")
	_check(_player.global_position.z < p0.z - 0.3, "W still moves the player forward in mouse mode")
