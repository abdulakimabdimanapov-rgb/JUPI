extends CharacterBody3D
## Minimal first-person controller for the JUPI 3D prototype.
##
## - Aim comes from an AimSource (default: mouse). The player polls
##   aim_source.get_aim() every physics frame and applies it to the body
##   yaw / head pitch. The crosshair is permanently centered and the
##   aim raycast passes through the camera center, so a source only
##   drives camera orientation.
## - WASD moves the body relative to where it is facing.
## - LMB fires (emits aim_requested) while the aim source is active; a
##   click while the source is inactive just activates it.
##
## Two-hand control (hand mode):
## - LEFT hand pinch + movement rotates the camera (relative deltas,
##   owned by the hand aim source).
## - RIGHT hand pinch fires exactly one shot (pinch_shot -> aim_requested).
## - Any hand that is OPEN walks the player forward along the view at a
##   constant speed, so the session can be played hands-only; pinching a
##   hand stops it walking and starts its action. Left pinch (look) + a
##   right open hand moves AND turns at the same time.
## - Keyboard movement is disabled in hand mode (gestures own movement).
## - Mouse look is disabled in hand mode (the left hand owns the camera);
##   Escape capture/release still works through the wrapped mouse source.
##
## No weapons, health, stamina, head bob or effects by design.

const AimSourceMouseScript := preload("res://scripts/aim_source_mouse.gd")
const AimSourceHandScript := preload("res://scripts/aim_source_hand.gd")

const SPEED := 5.0
## Constant walk speed while a hand is open in hand mode.
## Slightly slower than keyboard sprint-feel so aiming stays controlled.
const WALK_SPEED := 2.5
const GRAVITY := 9.8

## Emitted when the player fires (LMB while the aim source is active, or
## a right-hand pinch in hand mode). The main scene listens and decides
## what the shot does.
signal aim_requested

## Active aim input. Anything implementing the AimSource interface
## (get_aim / handle_input / is_active / activate) can replace the mouse.
## Default is the mouse source. Press H to swap to the hand-tracking
## source: left-hand pinch rotates the camera, right-hand pinch shoots.
## Press H again to switch back to pure mouse aiming.
var aim_source = AimSourceMouseScript.new()
var _mouse_source = aim_source
var _hand_source = AimSourceHandScript.new(_mouse_source)
var _hand_mode := false

# Auto-start hand mode: once armed by the main scene (tracker spawned),
# the player switches to hand aiming as soon as the tracker's first real
# packet arrives. A manual H press disarms this so the player keeps full
# control over the mode.
var _auto_hand := false

@onready var _head: Camera3D = $Head


func _ready() -> void:
	_hand_source.pinch_shot.connect(_on_pinch_shot)
	aim_source.activate()


## A right-hand pinch arrived from the hand tracker: fire exactly one
## shot through the existing shooting path, but only in hand mode (mouse
## mode keeps LMB as its only shot input).
func _on_pinch_shot() -> void:
	if _hand_mode:
		print("Pinch shot  t=%.1f" % (Time.get_ticks_msec() / 1000.0))
		aim_requested.emit()


## Keep the hand source's UDP data fresh every frame so hand input is
## current whenever hand mode is toggled on.
func _process(_delta: float) -> void:
	_hand_source.poll()
	# The tracker is available and its first packet arrived: hand aiming
	# becomes the default without needing an H press. Mouse aiming stays
	# usable until then (and after a manual H toggle).
	if _auto_hand and not _hand_mode and _hand_source.has_received_data():
		_auto_hand = false
		_toggle_hand_mode()


func _unhandled_input(event: InputEvent) -> void:
	# H toggles between hand-tracking and mouse aiming. Match the
	# physical key too so the toggle works on non-QWERTY layouts where
	# keycode is layout-mapped.
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_H or event.physical_keycode == KEY_H):
		_auto_hand = false  # a manual press takes over from auto-start
		_toggle_hand_mode()
		return
	# Give the aim source first pick of every input event.
	if aim_source.handle_input(event):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _hand_mode:
			# In hand mode the right-hand pinch is the ONLY shot input;
			# LMB neither fires nor recaptures the mouse.
			return
		if aim_source.is_active():
			# Playing: fire an aim request. Aim logic lives in main_3d.gd.
			aim_requested.emit()
		else:
			# Mouse was released (Escape): any click recaptures it, no shot.
			aim_source.activate()


## Arms the automatic hand-mode switch (called by the main scene once
## the tracker process has been spawned successfully).
func arm_auto_hand() -> void:
	_auto_hand = true


## Whether hand aiming is currently the active mode.
func is_hand_mode() -> bool:
	return _hand_mode


## Swaps the active aim source between the mouse and the hand-tracking
## source (which wraps the mouse for capture / firing / Escape).
func _toggle_hand_mode() -> void:
	# Seed the incoming source with the current camera orientation so
	# toggling modes never snaps the view: in hand mode the left hand
	# accumulates deltas onto the aim it owns, in mouse mode the mouse
	# does the same.
	if _hand_mode:
		_mouse_source.set_aim(rotation.y, _head.rotation.x)
	else:
		_hand_source.set_aim(rotation.y, _head.rotation.x)
	_hand_mode = not _hand_mode
	aim_source = _hand_source if _hand_mode else _mouse_source
	print("Aim source: %s  t=%.1f" % ["hand (left pinch = look, right pinch = shoot)" if _hand_mode else "mouse", Time.get_ticks_msec() / 1000.0])
	if _hand_mode and not _hand_source.is_bound():
		# The user just asked for hand control and the port is held by
		# another game instance - say so on stderr (visible in the editor
		# output and the terminal).
		printerr("[GODOT] ERROR: hand mode is ON but UDP 37020 is not bound (another game instance holds it). Close the other game window and hand data will connect.")


func _physics_process(delta: float) -> void:
	# Apply the aim source: yaw turns the body, pitch tilts the head.
	var aim: Vector2 = aim_source.get_aim()
	rotation.y = aim.x
	_head.rotation.x = aim.y

	# Gravity.
	velocity.y -= GRAVITY * delta

	# Horizontal movement, relative to facing.
	if _hand_mode:
		# Hands-only: while any detected hand is open (is_walking()), walk
		# forward along the view at a constant speed. Pinching both hands
		# (look / shoot) or dropping them stops the player. WASD is not
		# read in hand mode so gestures fully own movement.
		if aim_source.is_walking():
			var fwd := -transform.basis.z  # yaw-only basis: horizontal
			velocity.x = fwd.x * WALK_SPEED
			velocity.z = fwd.z * WALK_SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var wish := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
		if wish.length() > 0.001:
			wish = wish.normalized()
			velocity.x = wish.x * SPEED
			velocity.z = wish.z * SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

	# Stay grounded on the floor.
	if is_on_floor() and velocity.y < 0.0:
		velocity.y = 0.0