extends Node
## JUPI step 8 runtime test: RIGHT pinch = exactly one shot.
##
## Instantiates the real main scene, toggles hand mode (KEY_H), then
## drives the hand aim source with synthetic UDP packets and verifies:
## - the crosshair stays at screen center while pinching / shooting;
## - one "right,pinch" produces exactly ONE shot; a second separate pinch
##   produces another (each packet is the tracker's edge, fired once);
## - the LEFT pinch never shoots (it only arms camera look);
## - a right pinch aimed at the target hits it through the center ray:
##   Hits increments and the target respawns;
## - pinches are ignored in mouse mode (LMB remains the only shot input);
## - LMB still fires in mouse mode;
## - the crosshair is still centered after everything.
##
## Run: godot --headless --path . res://tests/pinch_shot_runtime_test.tscn
## Exit code 0 = all checks passed, 1 = failure.

const MAIN_SCENE := "res://scenes/main_3d.tscn"
const UDP_HOST := "127.0.0.1"
const UDP_PORT := 37020
const EPS := 0.001

var _checks := 0
var _fails := 0

var _main: Node3D
var _player: CharacterBody3D
var _head: Camera3D
var _mouse
var _hand
var _target: StaticBody3D
var _crosshair_h: ColorRect
var _crosshair_v: ColorRect
var _sender := PacketPeerUDP.new()


func _ready() -> void:
	_main = load(MAIN_SCENE).instantiate()
	_main.auto_start_tracker = false  # tests drive the tracker synthetically
	add_child(_main)

	_player = _main.get_node("Player")
	_head = _player.get_node("Head")
	_mouse = _player._mouse_source
	_hand = _player._hand_source
	_target = _main.get_node("Target")
	_crosshair_h = _main.get_node("CrosshairUI/Root/H")
	_crosshair_v = _main.get_node("CrosshairUI/Root/V")
	_sender.set_dest_address(UDP_HOST, UDP_PORT)

	# Let _ready / physics settle, then freeze the target's sway drift so
	# the aimed-hit check is deterministic.
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_main.set_physics_process(false)

	print("=== JUPI step 8 runtime test (right pinch = one shot) ===")

	await _check_hand_toggle()
	await _check_crosshair_centered()
	await _check_one_pinch_one_shot()
	await _check_left_pinch_does_not_shoot()
	await _check_pinch_aimed_hits_target()
	_check_crosshair_centered()
	await _check_mouse_mode_ignores_pinch()
	await _check_lmb_still_fires()
	_check_crosshair_centered()

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
	for i in 8:
		await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame


func _shots() -> int:
	return _main._shots


func _hits() -> int:
	return int(_main.get_node("CrosshairUI/HitsLabel").text.split(" ")[1])


func _crosshair_at_center() -> bool:
	return (
		absf(_crosshair_h.anchor_left - 0.5) < EPS
		and absf(_crosshair_h.anchor_top - 0.5) < EPS
		and absf(_crosshair_v.anchor_left - 0.5) < EPS
		and absf(_crosshair_v.anchor_top - 0.5) < EPS
	)


func _press_h() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_H
	ev.physical_keycode = KEY_H
	ev.pressed = true
	_player._unhandled_input(ev)
	await get_tree().process_frame


## Rotates the active aim source so the CENTER of the camera points
## exactly at `point`, then lets a physics frame apply it.
func _aim_center_at(point: Vector3) -> void:
	var src = _player.aim_source
	var dir: Vector3 = (point - _head.global_position).normalized()
	src.set_aim(atan2(-dir.x, -dir.z), asin(clampf(dir.y, -1.0, 1.0)))
	await get_tree().physics_frame
	await get_tree().process_frame


func _check_hand_toggle() -> void:
	_check(_player.aim_source == _mouse, "mouse source is active by default")
	await _press_h()
	_check(_player.aim_source == _hand, "H toggles the hand source active")


func _check_crosshair_centered() -> void:
	_check(_crosshair_at_center(), "crosshair is exactly at screen center (50% / 50%)")


func _check_one_pinch_one_shot() -> void:
	var before: int = _shots()
	_send("right,pinch")
	await _settle()
	_check(_shots() == before + 1, "one right pinch produces exactly one shot (shots %d -> %d)" % [before, _shots()])
	# Holding the pinch must not keep firing: wait several frames and
	# confirm the count is stable (the tracker sends the edge once).
	var stable: int = _shots()
	for i in 10:
		await get_tree().process_frame
	_check(_shots() == stable, "holding the right pinch does not repeatedly shoot (shots stays %d)" % stable)
	# pinch -> open -> pinch: a second, separate pinch is a new shot.
	_send("right,pinch")
	await _settle()
	_check(_shots() == stable + 1, "a second right pinch produces another shot (shots %d)" % _shots())


func _check_left_pinch_does_not_shoot() -> void:
	var before: int = _shots()
	var cam_before: Vector2 = Vector2(_player.rotation.y, _head.rotation.x)
	# Left pinch + movement + release: camera look only, no shot.
	_send("left,pinch")
	await _settle()
	_send("left,0.6,0.5")
	await _settle()
	_send("left,0.66,0.5")
	await _settle()
	_send("left,release")
	await _settle()
	_check(_shots() == before, "the left pinch never shoots (shots unchanged)")
	_check(
		Vector2(_player.rotation.y, _head.rotation.x).distance_to(cam_before) > 0.001,
		"the left pinch still rotated the camera while held"
	)


func _check_pinch_aimed_hits_target() -> void:
	# Park the target somewhere clearly visible straight ahead, aim the
	# camera center exactly at it, then pinch: the CENTER ray must hit.
	_main._anchor = Vector3(0, 0.5, -4)
	_target.position = _main._anchor
	_main._sway_t = 0.0
	await get_tree().process_frame

	var hits_before: int = _hits()
	var shots_before: int = _shots()
	var anchor_before: Vector3 = _main._anchor
	await _aim_center_at(_target.global_position)
	_send("right,pinch")
	await _settle()
	_check(
		_hits() == hits_before + 1,
		"right pinch aimed at the target hits through the center ray (Hits -> %d)" % _hits()
	)
	_check(_shots() == shots_before + 1, "the pinched shot was counted (shots -> %d)" % _shots())
	_check(_main._anchor != anchor_before, "target respawns after a pinched hit")


func _check_mouse_mode_ignores_pinch() -> void:
	await _press_h()
	_check(_player.aim_source == _mouse, "H toggles back to the mouse source")
	var before: int = _shots()
	_send("right,pinch")
	_send("right,pinch")
	await _settle()
	_check(_shots() == before, "pinch messages are ignored in mouse mode (shots unchanged)")


func _check_lmb_still_fires() -> void:
	var before: int = _shots()
	if _player.aim_source.is_active():
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		_player._unhandled_input(ev)
	else:
		_player.aim_requested.emit()
	await get_tree().physics_frame
	_check(_shots() == before + 1, "LMB still fires a shot in mouse mode")
