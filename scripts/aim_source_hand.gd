extends "res://scripts/aim_source.gd"
## Hand-tracking aim source for JUPI's two-hand control scheme.
##
## Receives UDP packets from the Python webcam tracker
## (hand_tracking/main.py) and exposes:
## - camera look: while the LEFT pinch is held, the tracker streams the
##   left hand's position and this source rotates the camera by the
##   RELATIVE movement (deltas), never by absolute position. The first
##   position packet after a pinch starts establishes the baseline, so
##   starting a pinch never jumps the camera.
## - shooting: each RIGHT pinch emits pinch_shot exactly once
##   (edge-triggered in the tracker; one UDP message = one shot).
##
## The crosshair is permanently centered and this source does not move
## it: the shot ray always passes through the camera center, and this
## source only rotates the camera (it owns no pointer).
##
## UDP contract (fixed, localhost only):
##   host    : 127.0.0.1
##   port    : 37020 (see UDP_PORT)
##   payloads (ASCII, one per datagram):
##     "hand,left" / "hand,right" / "hand,none"
##         presence events, edge-triggered (used to detect the tracker
##         is online without spamming)
##     "left,pinch"       left pinch started -> arm camera look
##     "left,x,y"         left hand position (normalized [0, 1]) while
##                        the left pinch is held; Godot turns deltas
##                        into yaw/pitch
##     "left,release"     left pinch ended (or the left hand vanished)
##     "right,pinch"      right pinch started -> exactly one shot
##   Malformed or unknown packets are ignored.

## Emitted once per right-hand pinch (one "right,pinch" UDP message).
## The player connects this into the existing aim_requested shot path.
signal pinch_shot

const UDP_HOST := "127.0.0.1"
const UDP_PORT := 37020

## Radians of yaw per unit of normalized left-hand travel (hand moving
## right across the whole frame = 1.0). Tuned after real-hand testing:
## a comfortable arm sweep is a small fraction of the frame, so 4.5 rad
## per full-frame travel turns ~0.25 of the frame into ~64 degrees.
const YAW_SENSITIVITY := 4.5
## Radians of pitch per unit of normalized vertical hand travel.
const PITCH_SENSITIVITY := 3.75
## Tiny deadzone in normalized units: ignores sub-pixel jitter while a
## pinch is held still so the camera does not drift.
const DEADZONE := 0.002

## Wrapped mouse source: Escape capture/release, activate() and
## is_active() (mouse capture state) still come from it.
var _mouse_source

var _udp := PacketPeerUDP.new()

# Absolute aim this source owns: yaw (body) / pitch (head). The player
# seeds it from the current camera orientation when hand mode turns on,
# and left-pinch deltas accumulate onto it. Pitch is clamped to the
# aim_source PITCH_LIMIT.
var _yaw := 0.0
var _pitch := 0.0

# Left-pinch camera control state.
var _left_aiming := false
var _left_prev := Vector2.ZERO
var _left_has_prev := false

# Count of valid UDP packets received. The player uses it to switch to
# hand mode automatically once real tracker data arrives.
var _data_packets := 0

# Whether the UDP socket holds the port. A second game instance cannot
# bind it (the first one owns it); keep trying so a fresh instance
# self-heals once the stale one closes.
var _bound := false
var _last_bind_attempt := 0.0


func _init(mouse_source) -> void:
	_mouse_source = mouse_source
	_try_bind(true)


func is_bound() -> bool:
	return _bound


func _try_bind(first: bool) -> void:
	if _bound:
		return
	var err := _udp.bind(UDP_PORT, UDP_HOST)
	if err == OK:
		_bound = true
		print("[GODOT] hand UDP bound on %s:%d" % [UDP_HOST, UDP_PORT])
	elif first:
		printerr("[GODOT] ERROR: could not bind UDP %s:%d (%s) - another game instance is running? Close it and hand mode will reconnect." % [UDP_HOST, UDP_PORT, error_string(err)])


## Drains pending UDP packets. Called every frame by the player so hand
## data is fresh whenever hand mode is active.
func poll() -> void:
	if not _bound:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _last_bind_attempt >= 1.0:
			_last_bind_attempt = now
			_try_bind(false)
	while _udp.get_available_packet_count() > 0:
		var text := _udp.get_packet().get_string_from_utf8().strip_edges()
		_handle_packet(text)


func _handle_packet(text: String) -> void:
	if text == "hand,left" or text == "hand,right" or text == "hand,none":
		_data_packets += 1
		return
	if text == "left,pinch":
		# Pinch started: arm camera control. The next position packet
		# becomes the baseline, so the camera does not jump.
		_left_aiming = true
		_left_has_prev = false
		_data_packets += 1
		return
	if text == "left,release":
		# Pinch ended (or the hand vanished): stop rotating, reset the
		# baseline so the next pinch starts fresh.
		_left_aiming = false
		_left_has_prev = false
		_data_packets += 1
		return
	if text == "right,pinch":
		# One edge-triggered message from the tracker = one shot.
		pinch_shot.emit()
		_data_packets += 1
		return
	if text.begins_with("left,"):
		# "left,x,y" position packet. Only meaningful while the left
		# pinch is held (the tracker sends these only then).
		_handle_left_position(text)
		_data_packets += 1
		return
	# Anything else is malformed or unknown: ignore.


## Turns left-hand position deltas into camera rotation. The first
## packet after a pinch starts only establishes the baseline; every
## following packet rotates by its delta from the previous one.
func _handle_left_position(text: String) -> void:
	if not _left_aiming:
		return
	var parts := text.split(",")
	if parts.size() != 3:
		return
	if not parts[1].is_valid_float() or not parts[2].is_valid_float():
		return
	var pos := Vector2(parts[1].to_float(), parts[2].to_float())
	if is_nan(pos.x) or is_nan(pos.y):
		return
	pos = pos.clamp(Vector2.ZERO, Vector2.ONE)
	if not _left_has_prev:
		_left_prev = pos
		_left_has_prev = true
		return  # baseline only: no rotation on the first packet
	var delta := pos - _left_prev
	_left_prev = pos
	if delta.length() < DEADZONE:
		return
	# Same sign convention as the mouse: hand right (dx > 0 in the
	# mirrored preview) -> look right (yaw decreases); hand up (dy < 0)
	# -> look up (pitch increases).
	_yaw -= delta.x * YAW_SENSITIVITY
	_pitch = clampf(
		_pitch - delta.y * PITCH_SENSITIVITY,
		deg_to_rad(-PITCH_LIMIT_DEG),
		deg_to_rad(PITCH_LIMIT_DEG)
	)


## True once at least one valid tracker packet has been received, i.e.
## the tracker is running and initialized and has seen a hand.
func has_received_data() -> bool:
	return _data_packets > 0


func get_aim() -> Vector2:
	return Vector2(_yaw, _pitch)


## Overrides the aim this source owns (the player seeds it from the
## current camera orientation when hand mode turns on, so toggling
## modes never snaps the view).
func set_aim(yaw: float, pitch: float) -> void:
	_yaw = yaw
	_pitch = clampf(pitch, deg_to_rad(-PITCH_LIMIT_DEG), deg_to_rad(PITCH_LIMIT_DEG))


## In hand mode the left hand owns the camera, so mouse motion must NOT
## rotate the view. Only Escape is forwarded to the wrapped mouse source
## (capture/release keeps working).
func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_cancel"):
		return _mouse_source.handle_input(event)
	return false


func is_active() -> bool:
	return _mouse_source.is_active()


func activate() -> void:
	_mouse_source.activate()