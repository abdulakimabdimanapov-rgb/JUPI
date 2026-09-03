extends CharacterBody3D
## Minimal first-person controller for the JUPI 3D prototype.
##
## - Aim comes from an AimSource (default: mouse). The player polls
##   aim_source.get_aim() every physics frame and applies it to the body
##   yaw / head pitch, so a future hand-tracking source can drive the
##   crosshair simply by being assigned to aim_source.
## - WASD moves the body relative to where it is facing.
## - LMB fires (emits aim_requested) while the aim source is active; a
##   click while the source is inactive just activates it.
##
## No weapons, health, stamina, head bob or effects by design.

const AimSourceMouseScript := preload("res://scripts/aim_source_mouse.gd")

const SPEED := 5.0
const GRAVITY := 9.8

## Emitted when the player fires (LMB while the aim source is active).
## The main scene listens and decides what the shot does.
signal aim_requested

## Swappable aim input. Anything implementing the AimSource interface
## (get_aim / handle_input / is_active / activate) can replace the mouse.
var aim_source = AimSourceMouseScript.new()

@onready var _head: Camera3D = $Head


func _ready() -> void:
	aim_source.activate()


func _unhandled_input(event: InputEvent) -> void:
	# Give the aim source first pick of every input event.
	if aim_source.handle_input(event):
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and aim_source.is_active():
			# Playing: fire an aim request. Aim logic lives in main_3d.gd.
			aim_requested.emit()
		elif not aim_source.is_active():
			# Mouse was released (Escape): any click recaptures it, no shot.
			aim_source.activate()


func _physics_process(delta: float) -> void:
	# Apply the aim source: yaw turns the body, pitch tilts the head.
	var aim: Vector2 = aim_source.get_aim()
	rotation.y = aim.x
	_head.rotation.x = aim.y

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
