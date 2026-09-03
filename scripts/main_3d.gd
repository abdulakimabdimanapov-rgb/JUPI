extends Node3D
## Main scene for the JUPI minimal 3D prototype.
##
## Owns the aim mechanic and the session score:
## - When the player fires (player_3d.gd emits aim_requested on LMB while
##   the mouse is captured), a ray is cast from the exact center of the
##   head camera. If it hits the target cube the hit is counted and the
##   target respawns elsewhere.
## - Every fired shot (hit or miss) is counted, so accuracy is
##   hits / shots. Elapsed session time is tracked and both are shown in
##   the HUD. A scene restart resets the score naturally.
##
## Target behaviour: after a hit it jumps to a random spot and height
## tier (floor / chest / high) and drifts slowly around that anchor, so
## the player must re-aim vertically and track a moving cube.
##
## Everything else (movement, mouse look, world geometry) lives in the
## scenes / player_3d.gd and is intentionally untouched here.

## Floor positions the target can jump to after a hit (y is unused;
## the height tier is chosen separately).
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

## Center heights the cube can respawn at (floor, chest, high).
const HEIGHT_TIERS := [0.5, 1.5, 2.2]

const RAY_LENGTH := 100.0
## Slow horizontal drift around the anchor after each respawn.
const SWAY_RADIUS := 1.0
const SWAY_SPEED := 1.2

var _hits := 0
var _shots := 0
var _elapsed := 0.0
var _sway_t := 0.0
var _anchor := Vector3(0, 0.5, -4)

@onready var _target: StaticBody3D = $Target
@onready var _player: CharacterBody3D = $Player
@onready var _head: Camera3D = $Player/Head
@onready var _hits_label: Label = $CrosshairUI/HitsLabel
@onready var _stats_label: Label = $CrosshairUI/StatsLabel


func _ready() -> void:
	_player.aim_requested.connect(_on_aim_requested)
	_anchor = _target.position
	_hits_label.text = "Hits: %d" % _hits
	_stats_label.text = _stats_text()


func _process(delta: float) -> void:
	_elapsed += delta
	_stats_label.text = _stats_text()


func _physics_process(delta: float) -> void:
	# Drift the target slowly around its anchor so it must be tracked.
	_sway_t += delta * SWAY_SPEED
	_target.position = _anchor + Vector3(
		sin(_sway_t) * SWAY_RADIUS,
		0.0,
		cos(_sway_t * 0.7) * SWAY_RADIUS
	)


func _on_aim_requested() -> void:
	_shots += 1  # every fired shot counts, hit or miss

	# Ray starts at the camera and goes straight through the crosshair center.
	var origin: Vector3 = _head.global_position
	var end: Vector3 = origin - _head.global_transform.basis.z * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [_player.get_rid()]  # don't hit our own body
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return  # hit nothing: a missed shot
	if result.collider != _target:
		return  # hit the floor / a wall / a block: a missed shot

	_hits += 1
	_hits_label.text = "Hits: %d" % _hits
	_stats_label.text = _stats_text()
	_respawn_target()


func _respawn_target() -> void:
	var free := TARGET_CANDIDATES.filter(
		func(pos: Vector3) -> bool:
			return Vector2(pos.x, pos.z) != Vector2(_anchor.x, _anchor.z)
	)
	var spot: Vector3 = free[randi() % free.size()]
	var tier: float = HEIGHT_TIERS[randi() % HEIGHT_TIERS.size()]
	_anchor = Vector3(spot.x, tier, spot.z)
	_sway_t = randf() * TAU
	_target.position = _anchor


func _stats_text() -> String:
	var acc := 0
	if _shots > 0:
		acc = int(round(100.0 * float(_hits) / float(_shots)))
	return "Accuracy: %d%%   Time: %.1fs" % [acc, _elapsed]
