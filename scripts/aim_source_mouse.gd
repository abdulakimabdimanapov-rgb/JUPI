extends "res://scripts/aim_source.gd"
## Mouse-driven aim source.
##
## Mouse deltas accumulate into an absolute (yaw, pitch) aim that the
## player applies every physics frame. The crosshair is permanently
## centered (the aim raycast passes through the camera center), so the
## mouse only ever controls look.
##
## The source owns mouse capture: Escape toggles it, activate() captures.

const MOUSE_SENSITIVITY := 0.0022

var _yaw := 0.0
var _pitch := 0.0


func get_aim() -> Vector2:
	return Vector2(_yaw, _pitch)


func is_active() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


func activate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_aim(yaw: float, pitch: float) -> void:
	_yaw = yaw
	_pitch = clampf(pitch, deg_to_rad(-PITCH_LIMIT_DEG), deg_to_rad(PITCH_LIMIT_DEG))


func handle_input(event: InputEvent) -> bool:
	if event is InputEventMouseMotion:
		if is_active():
			_yaw -= event.relative.x * MOUSE_SENSITIVITY
			_pitch = clampf(
				_pitch - event.relative.y * MOUSE_SENSITIVITY,
				deg_to_rad(-PITCH_LIMIT_DEG),
				deg_to_rad(PITCH_LIMIT_DEG)
			)
		return true
	if event.is_action_pressed("ui_cancel"):
		if is_active():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return true
	return false