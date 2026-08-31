extends CanvasLayer

var _minimap_container: PanelContainer
var _dot_container: Control
var _player_dot: ColorRect
var _enemy_dots: Array[ColorRect] = []
var _npc_dots: Array[ColorRect] = []
var _size = Vector2(120, 120)
var _world_size = Vector2(80 * 16, 60 * 16)
var _visible = true
var _panel_pos = Vector2(1140, 10)

func _ready():
	layer = 10
	_build_minimap()

func _build_minimap():
	_minimap_container = PanelContainer.new()
	_minimap_container.position = _panel_pos
	_minimap_container.custom_minimum_size = _size
	_minimap_container.size = _size

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.75)
	style.border_color = Color(0.3, 0.35, 0.45, 0.8)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	_minimap_container.add_theme_stylebox_override("panel", style)
	add_child(_minimap_container)

	# Dot container sits as sibling at same offset so coords align
	_dot_container = Control.new()
	_dot_container.position = _panel_pos
	_dot_container.size = _size
	_dot_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dot_container)

	# Title
	var title := Label.new()
	title.text = "MAP"
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 0.6))
	title.position = Vector2(2, 1)
	title.z_index = 3
	_dot_container.add_child(title)

	# Player dot (green, pulsing)
	_player_dot = ColorRect.new()
	_player_dot.color = Color(0.2, 0.95, 0.35)
	_player_dot.size = Vector2(5, 5)
	_player_dot.position = _size / 2.0 - Vector2(2.5, 2.5)
	_player_dot.z_index = 4
	_dot_container.add_child(_player_dot)

	# Pulse animation on player dot
	var pulse := create_tween().set_loops()
	pulse.tween_property(_player_dot, "color", Color(0.5, 1.0, 0.6), 0.6).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_player_dot, "color", Color(0.2, 0.95, 0.35), 0.6).set_trans(Tween.TRANS_SINE)

func update_minimap(player_pos: Vector2, enemies: Array, npcs: Array):
	if not _visible:
		return

	for dot in _enemy_dots:
		if is_instance_valid(dot):
			dot.queue_free()
	_enemy_dots.clear()

	for dot in _npc_dots:
		if is_instance_valid(dot):
			dot.queue_free()
	_npc_dots.clear()

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dot = ColorRect.new()
		dot.color = Color(0.95, 0.2, 0.15)
		dot.size = Vector2(3, 3)
		var minimap_pos = _world_to_minimap(enemy.global_position)
		dot.position = minimap_pos - Vector2(1.5, 1.5)
		dot.z_index = 2
		_dot_container.add_child(dot)
		_enemy_dots.append(dot)

	for npc in npcs:
		if not is_instance_valid(npc):
			continue
		var dot = ColorRect.new()
		dot.color = Color(0.3, 0.55, 0.9)
		dot.size = Vector2(3, 3)
		var minimap_pos = _world_to_minimap(npc.global_position)
		dot.position = minimap_pos - Vector2(1.5, 1.5)
		dot.z_index = 2
		_dot_container.add_child(dot)
		_npc_dots.append(dot)

	var player_minimap = _world_to_minimap(player_pos)
	_player_dot.position = player_minimap - Vector2(2.5, 2.5)

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var x = world_pos.x / _world_size.x * _size.x
	var y = world_pos.y / _world_size.y * _size.y
	return Vector2(x, y)

func toggle():
	_visible = not _visible
	_minimap_container.visible = _visible
	_dot_container.visible = _visible

func set_minimap_visible(vis: bool):
	_visible = vis
	_minimap_container.visible = _visible
	_dot_container.visible = _visible
