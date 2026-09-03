extends Node2D

## JUPI Stardance MVP — Game World
## Two eras: Present ↔ Past
## Core loop: fight → find Blood Clock → travel → world changes → fight boss → win

const T := 16
const MAP_W := 40
const MAP_H := 30

# Tile constants (from master_atlas_v2.png)
const STONE_FLOOR := Vector2i(0, 0)
const BRICK_FLOOR := Vector2i(1, 0)
const DIRT := Vector2i(2, 0)
const GRASS := Vector2i(3, 0)
const WALL_STONE := Vector2i(0, 1)
const WALL_BRICK := Vector2i(1, 1)
const WALL_WOOD := Vector2i(2, 1)
const DOOR := Vector2i(4, 1)

# Game state
var current_era: String = "present"
var past_completed: bool = false
var boss_spawned: bool = false
var _player: CharacterBody2D
var _hud: CanvasLayer
var _tile_map: TileMapLayer
var _clock_ui_active: bool = false
var _clock_panel: PanelContainer

# Node containers
var _enemy_container: Node2D
var _npc_container: Node2D
var _prop_container: Node2D


func _ready():
	_enemy_container = Node2D.new()
	_enemy_container.name = "Enemies"
	add_child(_enemy_container)
	_npc_container = Node2D.new()
	_npc_container.name = "NPCs"
	add_child(_npc_container)
	_prop_container = Node2D.new()
	_prop_container.name = "Props"
	add_child(_prop_container)
	_load_map("present")
	_hud = preload("res://scripts/mvp/hud_mvp.gd").new()
	_hud.name = "HUD"
	add_child(_hud)
	_spawn_player()
	_spawn_enemies()
	_spawn_blood_clock()
	_hud.update_objective("Find the Blood Clock (Q)")
	call_deferred("_play_intro_sound")


func _spawn_player():
	_player = CharacterBody2D.new()
	_player.set_script(preload("res://scripts/mvp/player_mvp.gd"))
	_player.name = "Player"
	_player.world_rect = Rect2(Vector2.ZERO, Vector2(MAP_W * T, MAP_H * T))
	_player.position = Vector2(MAP_W / 2 * T, MAP_H / 2 * T)
	add_child(_player)
	_player.hp_changed.connect(_on_hp_changed)
	_player.xp_changed.connect(_on_xp_changed)
	_player.level_up.connect(_on_level_up)
	_player.player_died.connect(_on_player_died)
	_player.weapon_changed.connect(_on_weapon_changed)
	_on_hp_changed(_player.hp, _player.max_hp)
	_on_xp_changed(_player.xp)
	_on_level_up(_player.level)


# ─── MAPS ────────────────────────────────────────────────────────────────────

func _load_map(era: String):
	# Remove old tilemap
	for child in get_children():
		if child is TileMapLayer:
			child.queue_free()
	var atlas = preload("res://assets/2d/tiles/master_atlas_v2.png")
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(T, T)
	var source := TileSetAtlasSource.new()
	source.texture = atlas
	source.texture_region_size = Vector2i(T, T)
	tileset.add_source(source, 0)
	_tile_map = TileMapLayer.new()
	_tile_map.tile_set = tileset
	_tile_map.z_index = -1
	add_child(_tile_map)
	match era:
		"present":
			_generate_present_map()
		"past":
			_generate_past_map()


func _generate_present_map():
	for x in range(MAP_W):
		for y in range(MAP_H):
			if x == 0 or x == MAP_W - 1 or y == 0 or y == MAP_H - 1:
				_tile_map.set_cell(Vector2i(x, y), 0, WALL_STONE)
			elif randf() < 0.05:
				_tile_map.set_cell(Vector2i(x, y), 0, WALL_BRICK)
			else:
				_tile_map.set_cell(Vector2i(x, y), 0, STONE_FLOOR)
	# Add some buildings
	for bx in range(5, 35):
		for by in [10, 20]:
			if bx % 8 < 6 and by % 10 < 8:
				if bx == 8 or bx == 16 or bx == 24 or bx == 32:
					_tile_map.set_cell(Vector2i(bx, by), 0, DOOR)
				else:
					_tile_map.set_cell(Vector2i(bx, by), 0, WALL_BRICK)


func _generate_past_map():
	for x in range(MAP_W):
		for y in range(MAP_H):
			if x == 0 or x == MAP_W - 1 or y == 0 or y == MAP_H - 1:
				_tile_map.set_cell(Vector2i(x, y), 0, WALL_WOOD)
			elif randf() < 0.08:
				_tile_map.set_cell(Vector2i(x, y), 0, GRASS)
			else:
				_tile_map.set_cell(Vector2i(x, y), 0, DIRT)
	# Add village buildings
	for bx in range(8, 32):
		for by in [8, 18]:
			if bx % 10 < 7:
				if bx % 10 == 3:
					_tile_map.set_cell(Vector2i(bx, by), 0, DOOR)
				else:
					_tile_map.set_cell(Vector2i(bx, by), 0, WALL_WOOD)


# ─── ENEMIES ─────────────────────────────────────────────────────────────────

func _spawn_enemies():
	for e in _enemy_container.get_children():
		e.queue_free()
	var EnemyScript = preload("res://scripts/mvp/enemy_mvp.gd")
	var spawn_count := 5 if not past_completed else 8
	for i in range(spawn_count):
		var enemy := CharacterBody2D.new()
		enemy.set_script(EnemyScript)
		enemy.enemy_type = "fast" if randf() < 0.4 else "guard"
		enemy.position = Vector2(randi_range(3, MAP_W - 3) * T, randi_range(3, MAP_H - 3) * T)
		enemy.enemy_died.connect(_on_enemy_killed)
		_enemy_container.add_child(enemy)


func _spawn_blood_clock():
	for child in _prop_container.get_children():
		if child.has_meta("is_clock"):
			child.queue_free()
	var clock := Sprite2D.new()
	clock.position = Vector2(MAP_W / 2 * T, 3 * T)
	clock.z_index = 2
	clock.set_meta("is_clock", true)
	var img := Image.create(8, 10, false, Image.FORMAT_RGBA8)
	for x in range(8):
		for y in range(10):
			var d := Vector2(x - 3.5, y - 4.5).length()
			if d < 3.0:
				img.set_pixel(x, y, Color(0.8, 0.2, 0.1, 0.9))
			elif d < 4.0:
				img.set_pixel(x, y, Color(0.6, 0.15, 0.08, 0.7))
	# Clock hands
	img.set_pixel(4, 2, Color(0.9, 0.9, 0.9))
	img.set_pixel(4, 3, Color(0.9, 0.9, 0.9))
	img.set_pixel(4, 4, Color(0.9, 0.9, 0.9))
	img.set_pixel(5, 4, Color(0.9, 0.9, 0.9))
	img.set_pixel(3, 5, Color(0.9, 0.9, 0.9))
	clock.texture = ImageTexture.create_from_image(img)
	clock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_prop_container.add_child(clock)


# ─── BLOOD CLOCK UI ─────────────────────────────────────────────────────────

func _unhandled_input(event):
	if event.is_action_pressed("blood_clock") and _player and _player.alive:
		_toggle_clock_ui()


func _toggle_clock_ui():
	if _clock_ui_active:
		_close_clock_ui()
	else:
		_open_clock_ui()


func _open_clock_ui():
	_clock_ui_active = true
	_clock_panel = PanelContainer.new()
	_clock_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_clock_panel.custom_minimum_size = Vector2(400, 250)
	_clock_panel.z_index = 100
	_clock_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_clock_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_clock_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_clock_panel.add_child(vbox)
	var title := Label.new()
	title.text = "BLOOD CLOCK"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.8, 0.2, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())
	var era_label := Label.new()
	era_label.text = "Current Era: %s" % current_era.to_upper()
	era_label.add_theme_font_size_override("font_size", 14)
	era_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(era_label)
	var clock_says := Label.new()
	clock_says.text = _get_clock_text()
	clock_says.add_theme_font_size_override("font_size", 12)
	clock_says.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	clock_says.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_says.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(clock_says)
	if current_era == "present" and not past_completed:
		var travel_btn := Button.new()
		travel_btn.text = "TRAVEL TO PAST"
		travel_btn.custom_minimum_size = Vector2(200, 36)
		travel_btn.pressed.connect(_on_travel_to_past)
		vbox.add_child(travel_btn)
	elif current_era == "past":
		var return_btn := Button.new()
		return_btn.text = "RETURN TO PRESENT"
		return_btn.custom_minimum_size = Vector2(200, 36)
		return_btn.pressed.connect(_on_return_to_present)
		vbox.add_child(return_btn)
	var close_btn := Button.new()
	close_btn.text = "[ESC] Close"
	close_btn.pressed.connect(_close_clock_ui)
	vbox.add_child(close_btn)


func _close_clock_ui():
	_clock_ui_active = false
	if _clock_panel:
		_clock_panel.queue_free()
		_clock_panel = null


func _get_clock_text() -> String:
	if current_era == "present" and not past_completed:
		return "The past calls to you. Travel back and change history."
	elif current_era == "present" and past_completed:
		if not boss_spawned:
			return "Your actions in the past have weakened the guardian. Defeat it!"
		else:
			return "The timeline is yours. You have won."
	else:
		return "You stand in the Iron Century. Complete your task, then return."


# ─── TIME TRAVEL ─────────────────────────────────────────────────────────────

func _on_travel_to_past():
	_close_clock_ui()
	current_era = "past"
	_load_map("past")
	_spawn_enemies()
	_spawn_blood_clock()
	_player.position = Vector2(MAP_W / 2 * T, MAP_H / 2 * T)
	_hud.update_objective("Complete your mission in the Past")
	_hud.update_era("past")
	AudioLib2D.play("time_travel")


func _on_return_to_present():
	_close_clock_ui()
	current_era = "present"
	past_completed = true
	_load_map("present")
	_spawn_enemies()
	_spawn_blood_clock()
	_player.position = Vector2(MAP_W / 2 * T, MAP_H / 2 * T)
	_hud.update_era("present")
	if not boss_spawned:
		_spawn_boss()
		_hud.update_objective("Defeat the Guardian!")
	else:
		_hud.update_objective("The world has changed!")
	AudioLib2D.play("time_travel")


func _spawn_boss():
	boss_spawned = true
	var BossScript = preload("res://scripts/mvp/enemy_mvp.gd")
	var boss := CharacterBody2D.new()
	boss.set_script(BossScript)
	boss.enemy_type = "boss"
	boss.position = Vector2(MAP_W / 2 * T, 5 * T)
	boss.enemy_died.connect(_on_boss_killed)
	_enemy_container.add_child(boss)
	_flash_screen(Color(0.8, 0.1, 0.05, 0.3))


# ─── GAME EVENTS ─────────────────────────────────────────────────────────────

func _on_enemy_killed(_enemy: Node2D):
	if _hud:
		_hud.update_kills(GameManager.total_kills)
	# Check if all enemies cleared in past → trigger return objective
	if current_era == "past" and not past_completed:
		var remaining := 0
		for e in _enemy_container.get_children():
			if is_instance_valid(e):
				remaining += 1
		if remaining <= 0:
			_hud.update_objective("Enemies cleared! Use Blood Clock (Q) to return.")


func _on_boss_killed(_boss: Node2D):
	_flash_screen(Color(1.0, 0.9, 0.2, 0.4))
	_show_win_screen()


func _on_player_died():
	_show_game_over()


func _on_hp_changed(hp_val: float, max_hp_val: float):
	if _hud:
		_hud.update_hp(hp_val, max_hp_val)


func _on_xp_changed(_xp_val: float):
	if _hud and _player:
		_hud.update_xp(_player.xp, _player.xp_to_next)


func _on_level_up(level: int):
	if _hud:
		_hud.update_level(level)
	_flash_screen(Color(0.2, 0.8, 0.3, 0.2))


func _on_weapon_changed(weapon_name: String):
	if _hud:
		_hud.update_weapon(weapon_name)


# ─── UI OVERLAYS ─────────────────────────────────────────────────────────────

func _show_game_over():
	var layer := CanvasLayer.new()
	layer.name = "GameOver"
	layer.layer = 100
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.add_theme_constant_override("separation", 16)
	layer.add_child(vbox)
	var title := Label.new()
	title.text = "YOU DIED"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.9, 0.15, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var stats := Label.new()
	stats.text = "Level: %d | Kills: %d" % [_player.level, GameManager.total_kills]
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stats)
	var restart_btn := Button.new()
	restart_btn.text = "RESTART"
	restart_btn.custom_minimum_size = Vector2(200, 36)
	restart_btn.pressed.connect(_restart_game)
	vbox.add_child(restart_btn)


func _show_win_screen():
	var layer := CanvasLayer.new()
	layer.name = "WinScreen"
	layer.layer = 100
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.05, 0.02, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.add_theme_constant_override("separation", 16)
	layer.add_child(vbox)
	var title := Label.new()
	title.text = "YOU WIN"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "The timeline is restored."
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)
	var stats := Label.new()
	stats.text = "Level: %d | Kills: %d | Weapon: %s" % [_player.level, GameManager.total_kills, _player.weapon]
	stats.add_theme_font_size_override("font_size", 13)
	stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stats)
	var restart_btn := Button.new()
	restart_btn.text = "PLAY AGAIN"
	restart_btn.custom_minimum_size = Vector2(200, 36)
	restart_btn.pressed.connect(_restart_game)
	vbox.add_child(restart_btn)


func _restart_game():
	GameManager.reset_run()
	get_tree().reload_current_scene()


# ─── EFFECTS ─────────────────────────────────────────────────────────────────

func _play_intro_sound():
	AudioLib2D.play("clock_open")


func _flash_screen(color: Color):
	var flash := ColorRect.new()
	flash.color = color
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.z_index = 200
	var layer := CanvasLayer.new()
	layer.layer = 90
	layer.add_child(flash)
	add_child(layer)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.3)
	tw.tween_callback(layer.queue_free)
