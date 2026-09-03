extends CharacterBody3D
## Minimal first-person controller for the JUPI 3D prototype.
##
## - WASD moves the body relative to where it is facing.
## - Mouse X rotates the body (yaw); mouse Y pitches the head camera.
## - Escape releases the mouse; click recaptures it.
##
## Deliberately tiny: no weapons, health, stamina, head bob or effects.
## A future input source (e.g. laptop-camera hand tracking) can drive the
## aim by controlling _head.rotation (pitch) and rotation.y (yaw) instead
## of mouse input — the rest of the controller does not care where they
## come from.

const SPEED := 5.0
const MOUSE_SENSITIVITY := 0.0022
const PITCH_LIMIT_DEG := 89.0
const GRAVITY := 9.8

## Emitted when the player fires (LMB while the mouse is captured).
## The main scene listens and decides what the shot does.
signal aim_requested

@onready var _head: Camera3D = $Head


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Horizontal mouse movement turns the body (yaw).
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			# Vertical mouse movement pitches the head camera, clamped.
			_head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			_head.rotation.x = clampf(
				_head.rotation.x,
				deg_to_rad(-PITCH_LIMIT_DEG),
				deg_to_rad(PITCH_LIMIT_DEG)
			)
	elif event.is_action_pressed("ui_cancel"):
		# Escape toggles mouse capture.
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				# Playing: fire an aim request. Aim logic lives in main_3d.gd.
				aim_requested.emit()
			else:
				# Mouse was released (Escape): a click recaptures it, no shot.
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Gravity.
	velocity.y -= GRAVITY * delta

	# Horizontal movement from WASD, relative to facing.
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
