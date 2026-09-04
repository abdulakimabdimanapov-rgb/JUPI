extends Node3D
## Main scene for the JUPI minimal 3D prototype.
##
## Owns the aim mechanic and the session score:
## - The crosshair is permanently centered and the aim raycast always
##   passes through the exact center of the camera, so where you hit is
##   wherever the camera faces. When the player fires (player_3d.gd
##   emits aim_requested on LMB or on a right-hand pinch), a ray is cast
##   from the head camera through the screen center. If it hits the
##   target cube the hit is counted and the target respawns elsewhere.
## - Every fired shot (hit or miss) is counted, so accuracy is
##   hits / shots. Elapsed session time is tracked and both are shown in
##   the HUD. A scene restart resets the score naturally.
##
## Target behaviour: after a hit it jumps to a random spot and height
## tier (floor / chest / high) and drifts slowly around that anchor, so
## the player must re-aim vertically and track a moving cube.
##
## Everything else (movement, mouse look, hand look, world geometry)
## lives in scenes / player_3d.gd and the aim sources, and is
## intentionally untouched here.

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

# --- Hand tracker process -----------------------------------------------
# The Python tracker (hand_tracking/main.py + its .venv) is spawned when
# the game starts and killed when the game exits, so hand controls work
# without the user starting it manually. If it cannot start, the game
# still runs normally with mouse aiming as the fallback.
const TRACKER_PYTHON := "res://hand_tracking/.venv/bin/python"
const TRACKER_SCRIPT := "res://hand_tracking/main.py"

## Set to false to skip auto-starting the tracker (used by tests).
@export var auto_start_tracker := true

var _tracker_pid := -1
var _tracker_state := ""  # "", "starting", "online", "unavailable"
var _tracker_check_t := 0.0
var _online_hide_at := 0.0

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
@onready var _tracker_label: Label = $CrosshairUI/TrackerStatusLabel


func _ready() -> void:
	_player.aim_requested.connect(_on_aim_requested)
	_anchor = _target.position
	_hits_label.text = "Hits: %d" % _hits
	_stats_label.text = _stats_text()
	if auto_start_tracker and DisplayServer.get_name() != "headless":
		_start_hand_tracker()


func _exit_tree() -> void:
	_stop_hand_tracker()


func _process(delta: float) -> void:
	_elapsed += delta
	_stats_label.text = _stats_text()
	_update_tracker_status()


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

	# The crosshair is permanently centered, so the ray always passes
	# through the exact center of the camera.
	var viewport_size: Vector2 = _head.get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5)
	var origin: Vector3 = _head.project_ray_origin(screen_pos)
	var end: Vector3 = origin + _head.project_ray_normal(screen_pos) * RAY_LENGTH
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


# --- Hand tracker process lifecycle --------------------------------------

## Starts the existing Python hand tracker (hand_tracking/.venv/bin/
## python hand_tracking/main.py) as a child process. Never crashes the
## game: on any failure the tracker status shows "unavailable" and mouse
## aiming remains the fallback.
func _start_hand_tracker() -> void:
	var python := ProjectSettings.globalize_path(TRACKER_PYTHON)
	var script := ProjectSettings.globalize_path(TRACKER_SCRIPT)
	if not FileAccess.file_exists(python) or not FileAccess.file_exists(script):
		printerr("[JUPI] hand tracker unavailable: %s or %s not found" % [TRACKER_PYTHON, TRACKER_SCRIPT])
		_set_tracker_state("unavailable")
		return
	# -u keeps the tracker's stdout unbuffered so its hand/pinch lines
	# show up live in the Godot console (terminal runs).
	var pid := OS.create_process(python, ["-u", script])
	if pid <= 0:
		printerr("[JUPI] hand tracker unavailable: could not start %s" % python)
		_set_tracker_state("unavailable")
		return
	_tracker_pid = pid
	print("[JUPI] hand tracker started (pid %d)" % pid)
	_set_tracker_state("starting")
	_player.arm_auto_hand()


## Kills the spawned tracker so no Python process or webcam is left
## behind when JUPI exits. Safe when the tracker already exited.
func _stop_hand_tracker() -> void:
	if _tracker_pid > 0:
		if OS.is_process_running(_tracker_pid):
			print("[JUPI] stopping hand tracker (pid %d)" % _tracker_pid)
			OS.kill(_tracker_pid)
		_tracker_pid = -1


## Keeps the small status label truthful: "starting..." until the first
## hand packet switches the player to hand mode, then "online" for a few
## seconds; "unavailable" (persistent) if the tracker never comes up or
## dies on its own.
func _update_tracker_status() -> void:
	var now := Time.get_ticks_msec()
	# First real hand packet arrived -> the player auto-switched to hand
	# mode, so the tracker is genuinely online.
	if _tracker_state == "starting" and _player.is_hand_mode():
		_set_tracker_state("online")
		_online_hide_at = now + 4000
	# Hide the brief "online" notice after a few seconds.
	if _tracker_state == "online" and now >= _online_hide_at:
		_tracker_label.text = ""
	# Poll the child every ~2 s: if it died on its own (crashed, camera
	# taken by another process, ...), tell the user once.
	if _tracker_state in ["starting", "online"] and _tracker_pid > 0 and now - _tracker_check_t >= 2000:
		_tracker_check_t = now
		if not OS.is_process_running(_tracker_pid):
			printerr("[JUPI] hand tracker exited unexpectedly (pid %d)" % _tracker_pid)
			_tracker_pid = -1
			_set_tracker_state("unavailable")


func _set_tracker_state(state: String) -> void:
	_tracker_state = state
	match state:
		"starting":
			_tracker_label.text = "Hand tracking: starting..."
			_tracker_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		"online":
			_tracker_label.text = "Hand tracking online - left pinch = look, right pinch = shoot"
			_tracker_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
		"unavailable":
			_tracker_label.text = "Hand tracking unavailable - mouse aiming active"
			_tracker_label.add_theme_color_override("font_color", Color(0.95, 0.45, 0.35))