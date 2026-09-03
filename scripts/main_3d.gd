extends Node3D
## Main scene for the JUPI minimal 3D prototype.
##
## Owns the aim mechanic: when the player fires (player_3d.gd emits
## aim_requested on LMB while the mouse is captured), a ray is cast from
## the exact center of the head camera. If it hits the target cube the hit
## is counted and the target moves to another spot in the room.
##
## Everything else (movement, mouse look, world geometry) lives in the
## scenes / player_3d.gd and is intentionally untouched here.

## Floor positions the target can jump to after a hit.
const TARGET_CANDIDATES := [
	Vector3(-6, 0.5, -7),
	Vector3(6, 0.5, -7),
	Vector3(-9, 0.5, 1),
	Vector3(9, 0.5, 1),
	Vector3(-6, 0.5, 7),
	Vector3(6, 0.5, 7),
	Vector3(-3, 0.5, 0),
	Vector3(4, 0.5, 0),
]

const RAY_LENGTH := 100.0

var _hits := 0

@onready var _target: StaticBody3D = $Target
@onready var _player: CharacterBody3D = $Player
@onready var _head: Camera3D = $Player/Head
@onready var _hits_label: Label = $CrosshairUI/HitsLabel


func _ready() -> void:
	_player.aim_requested.connect(_on_aim_requested)


func _on_aim_requested() -> void:
	# Ray starts at the camera and goes straight through the crosshair center.
	var origin: Vector3 = _head.global_position
	var end: Vector3 = origin - _head.global_transform.basis.z * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [_player.get_rid()]  # don't hit our own body
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return
	if result.collider != _target:
		return  # clicked on the floor / a wall / a block: no hit

	_hits += 1
	_hits_label.text = "Hits: %d" % _hits
	_move_target()


func _move_target() -> void:
	var free := TARGET_CANDIDATES.filter(
		func(pos: Vector3) -> bool: return pos != _target.position
	)
	_target.position = free[randi() % free.size()]
