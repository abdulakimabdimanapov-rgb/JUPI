extends Node2D


const T := 16
const MAP_W := 80
const MAP_H := 60

# Atlas layout: 10 columns × 8 rows (master_atlas_v2.png = 160x128)
# Row 0 — ground tiles
const STONE_FLOOR := Vector2i(0, 0)
const BRICK_FLOOR := Vector2i(1, 0)
const DIRT := Vector2i(2, 0)
const GRASS_PATCH := Vector2i(3, 0)
const WATER := Vector2i(4, 0)
const LAVA := Vector2i(5, 0)
const SAND := Vector2i(6, 0)
const CARPET_RED := Vector2i(7, 0)
const WOOD_FLOOR := Vector2i(8, 0)
const MARBLE := Vector2i(9, 0)
# Row 1 — walls
const WALL_STONE := Vector2i(0, 1)
const WALL_BRICK := Vector2i(1, 1)
const WALL_WOOD := Vector2i(2, 1)
const WALL_IRON := Vector2i(3, 1)
const DOOR_WOOD := Vector2i(4, 1)
const DOOR_IRON := Vector2i(5, 1)
const WINDOW_BARS := Vector2i(6, 1)
const WALL_MOSS := Vector2i(7, 1)
const WALL_CRACK := Vector2i(8, 1)
const ARCH := Vector2i(9, 1)
# Row 2 — misc structures
const COLUMN := Vector2i(0, 2)
const RAILING := Vector2i(1, 2)
const FENCE := Vector2i(2, 2)
const GATE := Vector2i(3, 2)
const WALL_VINE := Vector2i(4, 2)
const WALL_TORCH := Vector2i(5, 2)
const COBBLE := Vector2i(6, 2)
const PATH_TILE := Vector2i(7, 2)
const MUD := Vector2i(8, 2)
const SNOW := Vector2i(9, 2)
# Row 3 — building parts
const HOUSE_BRICK := Vector2i(0, 3)
const HOUSE_STONE := Vector2i(1, 3)
const ROOF_RED := Vector2i(2, 3)
const ROOF_BLUE := Vector2i(3, 3)
const ROOF_GREEN := Vector2i(4, 3)
const HOUSE_WINDOW := Vector2i(5, 3)
const HOUSE_DOOR := Vector2i(6, 3)
const TOWER_BASE := Vector2i(7, 3)
const TOWER_TOP := Vector2i(8, 3)
const WALL_CASTLE := Vector2i(9, 3)
# Row 4 — more floors/ground
const FLOOR_WOOD := Vector2i(0, 4)
const FLOOR_STONE := Vector2i(1, 4)
const FLOOR_CARPET := Vector2i(2, 4)
const FLOOR_MARBLE := Vector2i(3, 4)
const GROUND_DIRT := Vector2i(4, 4)
const GROUND_GRASS := Vector2i(5, 4)
const GROUND_SAND := Vector2i(6, 4)
const GROUND_SNOW := Vector2i(7, 4)
const WATER_DEEP := Vector2i(8, 4)
const LAVA_DEEP := Vector2i(9, 4)
# Row 5 — plants
const BUSH_GREEN := Vector2i(0, 5)
const BUSH_BLUE := Vector2i(1, 5)
const FLOWER_RED := Vector2i(2, 5)
const FLOWER_YELLOW := Vector2i(3, 5)
const FLOWER_WHITE := Vector2i(4, 5)
const FERN := Vector2i(5, 5)
const FERN_SMALL := Vector2i(6, 5)
const MUSHROOM_RED := Vector2i(7, 5)
const MUSHROOM := Vector2i(8, 5)
const TALL_GRASS := Vector2i(9, 5)
# Row 6 — more plants
const CATTAIL := Vector2i(0, 6)
const IVY_WALL := Vector2i(1, 6)
const VINE_HANG := Vector2i(2, 6)
# Row 7 — bar
const BAR_COUNTER := Vector2i(0, 7)
const BAR_SHELF := Vector2i(1, 7)
const BAR_STOOL := Vector2i(2, 7)
const BAR_FLOOR1 := Vector2i(3, 7)
const BAR_FLOOR2 := Vector2i(4, 7)
const BAR_TABLE := Vector2i(5, 7)
const BAR_BOTTLE := Vector2i(6, 7)
const BAR_FIREPLACE := Vector2i(7, 7)
const BAR_DOOR := Vector2i(8, 7)
const BAR_BARREL := Vector2i(9, 7)
# Aliases for backward compatibility
const ASPHALT := STONE_FLOOR
const SIDEWALK := BRICK_FLOOR
const ROAD := DIRT
const PUDDLE := WATER
const CONCRETE := LAVA
const FLOOR_MODERN := SAND
const FLOOR_FUTURE := CARPET_RED
const DIRT_PATH := WOOD_FLOOR
const CARPET := MARBLE
const WALL_DARK := WALL_BRICK
const WINDOW_LIT := WALL_WOOD
const WINDOW_DARK := WALL_IRON
const DOOR_TILE := DOOR_WOOD
const NEON_ON := DOOR_IRON
const BLDG_MODERN := WINDOW_BARS
const BLDG_FUTURE := WALL_MOSS
const CLOCK_TOWER_BG := WALL_CRACK
const HANGING_WIRE := ARCH
const COLUMN_TILE := COLUMN
const TABLE_TILE := BAR_TABLE
const CHAIR_TILE := BAR_STOOL
const BARREL_TILE := BAR_BARREL
const CRATE_TILE := HOUSE_DOOR
const TORCH_WALL := WALL_TORCH
const ANVIL_TILE := TOWER_BASE
const LOOM_TILE := BAR_SHELF
const BARREL_TOP := BAR_BARREL
const LAMP := BAR_COUNTER
const SIGN_TILE := BAR_BOTTLE
const BOOKSHELF := BAR_SHELF
const BED_TILE := BAR_TABLE
const PILLAR_TILE := COLUMN
const FOUNTAIN_SMALL := BAR_COUNTER
const BARREL_SIDE := BAR_BARREL
const TABLE_WOOD := BAR_TABLE
const BARREL := BAR_BARREL
const DUMPSTER := BAR_BARREL
const CAR_TILE := TOWER_BASE
const MANHOLE := BAR_COUNTER
const TRASH := BAR_BOTTLE
const PUDDLE_REF := COLUMN
const WIRE_TILE := BAR_SHELF
const NEON_OFF := GATE
const NF_GROUND := CARPET_RED
const NF_WALL := WALL_MOSS
const NF_NEON_BLUE := DOOR_IRON
const NF_NEON_PURPLE := GATE
const NF_PANEL := HOUSE_DOOR
const NF_WIRE := BAR_SHELF
const SHELF_TILE := BAR_SHELF
const COBBLE_TILE := COBBLE
const ICE := SNOW
const CRACKED := WALL_CRACK

var ground_layer: TileMapLayer
var wall_layer: TileMapLayer
var obj_layer: TileMapLayer
var fg_layer: TileMapLayer
var bg_layer: TileMapLayer
var light_layer: CanvasLayer
var hud_layer: CanvasLayer
var player: Node2D
var clock_ai: RefCounted
var time_travel: TimeTravel
var current_era := "modern"
var _rain_particles: CPUParticles2D
var _clock_ui_open := false
var _clock_ui_layer: CanvasLayer
var _pause_layer: CanvasLayer
var _paused := false
var _objective_label: Label
var _era_label: Label
var _hp_bar: ColorRect
var _hp_bg: ColorRect
var _en_bar: ColorRect
var _en_bg: ColorRect
var _weapon_label: Label
var _detection_indicator: Label
var _dialogue_layer: CanvasLayer
var _contract_active := false
var _target_name := ""
var _target_pos := Vector2.ZERO
var _target_found := false
var _target_defeated := false
var _time_traveled := false
var _survive_timer_active := false
var _survive_remaining := 0.0
var _interior_zone := false
var _interior_exit_pos := Vector2.ZERO

var _kill_count := 0
var _kill_label: Label
var _target_arrow: Label
var _target_npc: Node2D = null

# combo achievement tracking
var _combo_kill_streak := 0
var _combo_kill_total := 0
var _combo_finisher_count := 0
var _combo_finisher_weapons: Array[String] = []
var _dash_kill_count := 0
var _status_kill_poison := 0
var _status_kill_burn := 0
var _combo_no_damage := true
var _combo_achievement_system: AchievementSystem = null
var _streak_timer: SceneTreeTimer = null

var _xp_bar: ColorRect
var _xp_bg: ColorRect
var _level_label: Label
var _currency_label: Label
var _contract_type_label: Label
var _combo_label: Label
var _combo_bg: ColorRect
var _combo_timer_label: Label
var _combo_flash := 0.0

var _civilians: Array[Node2D] = []
var _civilian_timer := 0.0

var _shop_ui: CanvasLayer
var _inventory_ui: CanvasLayer
var _era_selection_ui: CanvasLayer
var _timeline_ui: CanvasLayer
var _dialogue_ui: CanvasLayer
var _tutorial_ui: CanvasLayer
var _ambient_manager: AmbientManager

var _travel_overlay: CanvasLayer
var _travel_flash: ColorRect

var _door_positions: Dictionary = {}
var _damage_vignette: ColorRect

var _minimap_ui: CanvasLayer
var _dialogue_queue: Array[String] = []
var _dialogue_speaker := ""

func _ready() -> void:
	add_to_group("game_world")
	print_debug("[JUPI] _ready START")
	var ClockAIClass = preload("res://clock/clock_ai.gd")
	var TimeTravelClass = preload("res://time/time_travel.gd")
	clock_ai = ClockAIClass.new()
	time_travel = TimeTravelClass.new()
	_combo_achievement_system = AchievementSystem.new()
	_combo_achievement_system.achievement_unlocked.connect(_on_achievement_unlocked)

	bg_layer = TileMapLayer.new()
	bg_layer.name = "BG"
	bg_layer.z_index = -10
	add_child(bg_layer)

	ground_layer = TileMapLayer.new()
	ground_layer.name = "Ground"
	ground_layer.z_index = -5
	add_child(ground_layer)

	wall_layer = TileMapLayer.new()
	wall_layer.name = "Walls"
	wall_layer.z_index = -4
	add_child(wall_layer)

	obj_layer = TileMapLayer.new()
	obj_layer.name = "Objects"
	obj_layer.z_index = -3
	add_child(obj_layer)

	fg_layer = TileMapLayer.new()
	fg_layer.name = "Foreground"
	fg_layer.z_index = 5
	add_child(fg_layer)

	var ts := _build_tileset()
	ground_layer.tile_set = ts
	wall_layer.tile_set = ts
	obj_layer.tile_set = ts
	bg_layer.tile_set = ts
	fg_layer.tile_set = ts

	_generate_city()
	print_debug("[JUPI] city done")

	_spawn_player()
	print_debug("[JUPI] player done")

	_spawn_enemies()
	print_debug("[JUPI] enemies done")

	_spawn_extra_enemies()
	print_debug("[JUPI] extra enemies done")

	_spawn_npcs()
	print_debug("[JUPI] npcs done")

	_spawn_environment_props()
	print_debug("[JUPI] props done")

	_setup_hud()
	print_debug("[JUPI] hud done")

	_clock_intro()
	print_debug("[JUPI] intro done")

	_setup_rain()
	_setup_lighting()
	print_debug("[JUPI] atmosphere done")

	var ShopUILoad = preload("res://ui/shop_ui.gd")
	_shop_ui = ShopUILoad.new()
	_shop_ui.name = "ShopUI"
	add_child(_shop_ui)

	var InventoryUILoad = preload("res://ui/inventory_ui.gd")
	_inventory_ui = InventoryUILoad.new()
	_inventory_ui.name = "InventoryUI"
	add_child(_inventory_ui)

	var EraSelectionLoad = preload("res://ui/era_selection_ui.gd")
	_era_selection_ui = EraSelectionLoad.new()
	_era_selection_ui.name = "EraSelectionUI"
	_era_selection_ui.era_selected.connect(_on_era_selected)
	add_child(_era_selection_ui)

	var TimelineUILoad = preload("res://ui/timeline_ui.gd")
	_timeline_ui = TimelineUILoad.new()
	_timeline_ui.name = "TimelineUI"
	add_child(_timeline_ui)

	var DialogueUILoad = preload("res://ui/dialogue_ui.gd")
	_dialogue_ui = DialogueUILoad.new()
	_dialogue_ui.name = "DialogueUI"
	add_child(_dialogue_ui)

	var TutorialUILoad = preload("res://tutorial/tutorial_ui.gd")
	_tutorial_ui = TutorialUILoad.new()
	_tutorial_ui.name = "TutorialUI"
	add_child(_tutorial_ui)

	if not GameManager.tutorial_completed:
		_tutorial_ui.start_tutorial()

	var MinimapUILoad = preload("res://ui/minimap_ui.gd")
	_minimap_ui = MinimapUILoad.new()
	_minimap_ui.name = "MinimapUI"
	add_child(_minimap_ui)

	_ambient_manager = AmbientManager.new()
	_ambient_manager.setup(self)
	_ambient_manager.secret_found.connect(_on_secret_found)
	_ambient_manager.location_discovered.connect(_on_location_discovered)

	GameManager.era_travel_started.connect(_on_travel_started)
	GameManager.era_travel_completed.connect(_on_travel_completed)
	GameManager.boss_defeated_signal_fired = false

	GameManager.check_era_unlocks()

	_spawn_boss_for_era()

func _exit_tree() -> void:
	AudioLib2D.stop_all()

func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)

	var src := TileSetAtlasSource.new()
	if ResourceLoader.exists("res://assets/2d/tiles/master_atlas_v2.png"):
		src.texture = load("res://assets/2d/tiles/master_atlas_v2.png")
	elif ResourceLoader.exists("res://assets/2d/tiles/env_atlas.png"):
		src.texture = load("res://assets/2d/tiles/env_atlas.png")
	else:
		src.texture = _fallback_atlas()
	src.texture_region_size = Vector2i(T, T)
	ts.add_source(src, 0)

	# Create ALL tiles used in the game so they render
	var all_ground := [STONE_FLOOR, BRICK_FLOOR, DIRT, GRASS_PATCH, WATER, LAVA, SAND, CARPET_RED, WOOD_FLOOR, MARBLE]
	var all_walls := [WALL_STONE, WALL_BRICK, WALL_WOOD, WALL_IRON, DOOR_WOOD, DOOR_IRON, WINDOW_BARS, WALL_MOSS, WALL_CRACK, ARCH]
	var all_misc := [COLUMN, RAILING, FENCE, GATE, WALL_VINE, WALL_TORCH, COBBLE, PATH_TILE, MUD, SNOW]
	var all_bldg := [HOUSE_BRICK, HOUSE_STONE, ROOF_RED, ROOF_BLUE, ROOF_GREEN, HOUSE_WINDOW, HOUSE_DOOR, TOWER_BASE, TOWER_TOP, WALL_CASTLE]
	var all_floors := [FLOOR_WOOD, FLOOR_STONE, FLOOR_CARPET, FLOOR_MARBLE, GROUND_DIRT, GROUND_GRASS, GROUND_SAND, GROUND_SNOW, WATER_DEEP, LAVA_DEEP]
	var all_plants := [BUSH_GREEN, BUSH_BLUE, FLOWER_RED, FLOWER_YELLOW, FLOWER_WHITE, FERN, FERN_SMALL, MUSHROOM_RED, MUSHROOM, TALL_GRASS, CATTAIL, IVY_WALL, VINE_HANG]
	var all_bar := [BAR_COUNTER, BAR_SHELF, BAR_STOOL, BAR_FLOOR1, BAR_FLOOR2, BAR_TABLE, BAR_BOTTLE, BAR_FIREPLACE, BAR_DOOR, BAR_BARREL]
	for coord in all_ground + all_walls + all_misc + all_bldg + all_floors + all_plants + all_bar:
		if not src.has_tile(coord):
			src.create_tile(coord)

	# wall tiles that block movement
	var wall_coords := [
		WALL_STONE, WALL_BRICK, WALL_WOOD, WALL_IRON,
		WINDOW_BARS, WALL_MOSS, WALL_CRACK, ARCH,
		COLUMN, FENCE, GATE, WALL_VINE,
		HOUSE_BRICK, HOUSE_STONE, WALL_CASTLE, TOWER_BASE, TOWER_TOP,
	]
	for coord in wall_coords:
		if not src.has_tile(coord):
			src.create_tile(coord)
		var td := src.get_tile_data(coord, 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]))

	# prop tiles that block movement (use valid atlas coords)
	var prop_coords := [BAR_BARREL, BAR_STOOL, BAR_TABLE, BAR_SHELF, TOWER_BASE, COLUMN, HOUSE_DOOR]
	for coord in prop_coords:
		if not src.has_tile(coord):
			src.create_tile(coord)
		var td := src.get_tile_data(coord, 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-6, -6), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]))

	return ts

func _fallback_atlas() -> ImageTexture:
	var img := Image.create(160, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.2, 0.22))
	# row 0 — ground colors
	for i in range(10):
		var c := Color(0.18 + i * 0.02, 0.16 + i * 0.01, 0.15 + i * 0.01)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(0, 16): img.set_pixel(x, y, c)
	# row 1 — wall colors
	for i in range(10):
		var c := Color(0.30 + i * 0.03, 0.25 + i * 0.02, 0.20)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(16, 32): img.set_pixel(x, y, c)
	# row 2 — structure colors
	for i in range(10):
		var c := Color(0.35, 0.30 + i * 0.03, 0.25)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(32, 48): img.set_pixel(x, y, c)
	# row 3 — building colors
	for i in range(10):
		var c := Color(0.28, 0.24 + i * 0.02, 0.20)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(48, 64): img.set_pixel(x, y, c)
	# row 4 — floor colors
	for i in range(10):
		var c := Color(0.22, 0.20, 0.18 + i * 0.01)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(64, 80): img.set_pixel(x, y, c)
	# row 5 — plant colors
	for i in range(10):
		var c := Color(0.15 + i * 0.02, 0.30 + i * 0.03, 0.12)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(80, 96): img.set_pixel(x, y, c)
	# row 6 — more plant colors
	for i in range(10):
		var c := Color(0.10, 0.25, 0.10 + i * 0.02)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(96, 112): img.set_pixel(x, y, c)
	# row 7 — bar colors
	for i in range(10):
		var c := Color(0.25 + i * 0.02, 0.18, 0.12)
		for x in range(i * 16, (i + 1) * 16):
			for y in range(112, 128): img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

func _generate_city() -> void:
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground_layer.set_cell(Vector2i(x, y), 0, ASPHALT)

	for x in range(0, MAP_W):
		ground_layer.set_cell(Vector2i(x, 28), 0, ROAD)
		ground_layer.set_cell(Vector2i(x, 29), 0, ROAD)
		ground_layer.set_cell(Vector2i(x, 30), 0, ROAD)

	for y in range(0, MAP_H):
		ground_layer.set_cell(Vector2i(35, y), 0, ROAD)
		ground_layer.set_cell(Vector2i(36, y), 0, ROAD)

	for x in range(0, MAP_W):
		for sy in [27, 31]:
			ground_layer.set_cell(Vector2i(x, sy), 0, SIDEWALK)
	for y in range(0, MAP_H):
		for sx in [34, 37]:
			ground_layer.set_cell(Vector2i(sx, y), 0, SIDEWALK)

	for p in [[10, 29], [25, 30], [50, 28], [65, 29], [40, 15], [20, 45]]:
		ground_layer.set_cell(Vector2i(p[0], p[1]), 0, PUDDLE)

	_place_building(5, 5, 14, 10, "Hotel", true)
	_place_building(45, 5, 12, 10, "Workshop", false)
	_place_building(30, 2, 8, 6, "Clock Tower", false)
	_place_building(5, 38, 12, 10, "Apartments", true)
	_place_building(50, 38, 10, 8, "Bar", false)
	_place_building(45, 38, 6, 6, "", false)
	_place_building(62, 5, 8, 7, "Armory", false)
	_place_building(20, 42, 8, 8, "Inn", true)
	_place_building(55, 42, 10, 8, "Gallery", true)  # Painter's studio

	for iy in range(39, 43):
		for ix in range(46, 50):
			ground_layer.set_cell(Vector2i(ix, iy), 0, FLOOR_MODERN)

	for c in [[3, 20], [4, 20], [8, 35], [60, 25], [62, 25], [70, 40]]:
		obj_layer.set_cell(Vector2i(c[0], c[1]), 0, CRATE_TILE)
	for b in [[3, 22], [61, 27], [72, 42]]:
		obj_layer.set_cell(Vector2i(b[0], b[1]), 0, BARREL)
	obj_layer.set_cell(Vector2i(40, 32), 0, DUMPSTER)
	obj_layer.set_cell(Vector2i(22, 32), 0, TRASH)

	for lp in [[10, 27], [20, 27], [30, 27], [40, 27], [55, 27], [65, 27],
			  [10, 31], [20, 31], [30, 31], [40, 31], [55, 31], [65, 31],
			  [34, 15], [34, 25], [37, 15], [37, 25], [34, 40], [37, 40]]:
		obj_layer.set_cell(Vector2i(lp[0], lp[1]), 0, LAMP)

	for ns in [[8, 5], [20, 5], [50, 5], [15, 38], [55, 38]]:
		obj_layer.set_cell(Vector2i(ns[0], ns[1]), 0, NEON_ON)

	for c in [[12, 30], [25, 31], [50, 30], [60, 31]]:
		obj_layer.set_cell(Vector2i(c[0], c[1]), 0, CAR_TILE)

	for m in [[15, 29], [45, 29], [30, 45]]:
		obj_layer.set_cell(Vector2i(m[0], m[1]), 0, MANHOLE)

	bg_layer.set_cell(Vector2i(32, 0), 0, CLOCK_TOWER_BG)
	bg_layer.set_cell(Vector2i(33, 0), 0, CLOCK_TOWER_BG)
	for wy in [3, 7]:
		for wx in range(5, 70):
			bg_layer.set_cell(Vector2i(wx, wy), 0, HANGING_WIRE)

	for wy in range(6, 14, 2):
		for wx in [6, 10, 14]:
			obj_layer.set_cell(Vector2i(wx, wy), 0, WINDOW_LIT if randf() > 0.3 else WINDOW_DARK)
	for wy in range(6, 13, 2):
		for wx in [46, 50, 54]:
			obj_layer.set_cell(Vector2i(wx, wy), 0, WINDOW_LIT if randf() > 0.4 else WINDOW_DARK)
	for wy in range(39, 46, 2):
		for wx in [6, 10, 14]:
			obj_layer.set_cell(Vector2i(wx, wy), 0, WINDOW_LIT if randf() > 0.5 else WINDOW_DARK)

	_door_positions[Vector2i(47, 38)] = Vector2(48, 40) * T
	_door_positions[Vector2i(48, 39)] = Vector2(47, 37) * T

	for x in range(0, MAP_W, 4):
		ground_layer.set_cell(Vector2i(x, 29), 0, ROAD)
	for sf in [[52, 45], [53, 45], [56, 46]]:
		obj_layer.set_cell(Vector2i(sf[0], sf[1]), 0, CRATE_TILE)
	for p2 in [[5, 15], [30, 20], [55, 40], [70, 28], [15, 50], [65, 10]]:
		ground_layer.set_cell(Vector2i(p2[0], p2[1]), 0, PUDDLE)

	# extra ground variety: grass patches in park zone
	for gp in [[66, 8], [67, 9], [69, 11], [73, 15], [75, 17], [65, 20], [70, 20]]:
		ground_layer.set_cell(Vector2i(gp[0], gp[1]), 0, GRASS_PATCH)

	# cobblestone plazas
	for cp in [[30, 15], [31, 15], [32, 15], [33, 15], [30, 16], [31, 16], [32, 16], [33, 16]]:
		ground_layer.set_cell(Vector2i(cp[0], cp[1]), 0, COBBLE)

	# dirt paths through alleys
	for dp in [[42, 10], [43, 11], [44, 12], [43, 13], [42, 14], [41, 15], [40, 16]]:
		ground_layer.set_cell(Vector2i(dp[0], dp[1]), 0, DIRT_PATH)

	# carpet inside buildings
	for iy in range(6, 14):
		for ix in range(6, 18):
			ground_layer.set_cell(Vector2i(ix, iy), 0, CARPET)

	# snow patches near fountain
	for sp in [[27, 15], [29, 17], [26, 17]]:
		ground_layer.set_cell(Vector2i(sp[0], sp[1]), 0, SNOW)

	# more scattered crates / barrels for atmosphere
	for sc in [[18, 45], [19, 46], [57, 42], [58, 43], [38, 12], [39, 13]]:
		obj_layer.set_cell(Vector2i(sc[0], sc[1]), 0, CRATE_TILE)
	for sb in [[20, 47], [56, 44], [37, 11]]:
		obj_layer.set_cell(Vector2i(sb[0], sb[1]), 0, BARREL)

func _place_building(bx: int, by: int, bw: int, bh: int, _label: String, has_door: bool) -> void:
	# pick a wall style based on building width for variety
	var walls := [WALL_STONE, WALL_BRICK, WALL_WOOD, WALL_IRON, HOUSE_BRICK, HOUSE_STONE, WALL_VINE, WALL_MOSS]
	var wall_tile: Vector2i = walls[bx % walls.size()]
	for x in range(bx, bx + bw):
		wall_layer.set_cell(Vector2i(x, by), 0, wall_tile)
		wall_layer.set_cell(Vector2i(x, by + bh - 1), 0, wall_tile)
	for y in range(by, by + bh):
		wall_layer.set_cell(Vector2i(bx, y), 0, wall_tile)
		wall_layer.set_cell(Vector2i(bx + bw - 1, y), 0, wall_tile)
	# interior floor variety
	var floors := [LAVA, SAND, COBBLE, WOOD_FLOOR, FLOOR_WOOD, FLOOR_STONE, FLOOR_CARPET, FLOOR_MARBLE]
	var floor_tile: Vector2i = floors[bx % floors.size()]
	for y in range(by + 1, by + bh - 1):
		for x in range(bx + 1, bx + bw - 1):
			ground_layer.set_cell(Vector2i(x, y), 0, floor_tile)
	if has_door:
		wall_layer.set_cell(Vector2i(bx + bw / 2, by + bh - 1), 0, DOOR_TILE)

func _spawn_player() -> void:
	var PlayerClass = load("res://characters/player.gd")
	player = PlayerClass.new()
	player.name = "Hunter"
	player.position = Vector2(30, 26) * T
	add_child(player)

	GameManager.current_era = "modern"
	if player.has_method("set_era_equipment"):
		player.set_era_equipment(GameManager.current_equipment)
	player.clock_interaction.connect(_on_clock_interaction)
	player.player_died.connect(_on_player_died)
	player.combo_reached.connect(_on_combo_reached)
	player.dash_attack_performed.connect(_on_dash_attack_performed)
	player.weapon_changed.connect(_on_weapon_changed)
	player.status_effect_applied.connect(_on_status_effect_applied)

func _spawn_enemies() -> void:
	var guard_data := [
		{"pos": Vector2(48, 8), "patrol": [Vector2(48, 8), Vector2(55, 8), Vector2(55, 13), Vector2(48, 13)], "hp": 50.0, "dmg": 12.0},
		{"pos": Vector2(10, 40), "patrol": [Vector2(10, 40), Vector2(15, 40), Vector2(15, 45), Vector2(10, 45)], "hp": 50.0, "dmg": 12.0},
		{"pos": Vector2(60, 28), "patrol": [Vector2(60, 28), Vector2(68, 28), Vector2(68, 30)], "hp": 50.0, "dmg": 12.0},
	]
	for i in range(guard_data.size()):
		var e := preload("res://ai/enemy_base.gd").new()
		e.name = "Guard_%d" % i
		e.enemy_type = "guard"
		e.patrol_points = guard_data[i].patrol
		e.position = guard_data[i].pos * T
		e.hp = guard_data[i].hp
		e.max_hp = guard_data[i].hp
		e.damage = guard_data[i].dmg
		e.speed = 45.0
		e.chase_speed = 75.0
		e.detection_range = 90.0
		e.enemy_died.connect(_on_enemy_killed)
		add_child(e)

	var fast := preload("res://ai/enemy_base.gd").new()
	fast.name = "Runner"
	fast.enemy_type = "fast"
	fast.patrol_points = [Vector2(60, 40), Vector2(70, 40), Vector2(70, 50), Vector2(60, 50)]
	fast.position = Vector2(60, 40) * T
	fast.hp = 25.0
	fast.max_hp = 25.0
	fast.damage = 8.0
	fast.speed = 70.0
	fast.chase_speed = 110.0
	fast.detection_range = 100.0
	fast.attack_cd = 0.6
	fast.enemy_died.connect(_on_enemy_killed)
	add_child(fast)

	var heavy := preload("res://ai/enemy_base.gd").new()
	heavy.name = "Brute"
	heavy.enemy_type = "heavy"
	heavy.patrol_points = [Vector2(20, 42), Vector2(28, 42), Vector2(28, 48), Vector2(20, 48)]
	heavy.position = Vector2(20, 42) * T
	heavy.hp = 100.0
	heavy.max_hp = 100.0
	heavy.damage = 20.0
	heavy.speed = 30.0
	heavy.chase_speed = 50.0
	heavy.detection_range = 70.0
	heavy.attack_cd = 1.5
	heavy.enemy_died.connect(_on_enemy_killed)
	add_child(heavy)

	# === MAGE (ranged, teleports away) ===
	var mage := preload("res://ai/enemy_mage.gd").new()
	mage.name = "DarkMage"
	mage.patrol_points = [Vector2(35, 15), Vector2(45, 15), Vector2(45, 20), Vector2(35, 20)]
	mage.position = Vector2(40, 17) * T
	mage.hp = 40.0
	mage.max_hp = 40.0
	mage.damage = 18.0
	mage.speed = 35.0
	mage.chase_speed = 50.0
	mage.detection_range = 130.0
	mage.attack_range = 80.0
	mage.attack_cd = 1.8
	mage.xp_reward = 45.0
	mage.enemy_died.connect(_on_enemy_killed)
	add_child(mage)

	# === SNIPER (long range, high damage, slow) ===
	var sniper := preload("res://ai/enemy_sniper.gd").new()
	sniper.name = "Sniper"
	sniper.patrol_points = [Vector2(10, 10), Vector2(18, 10), Vector2(18, 15), Vector2(10, 15)]
	sniper.position = Vector2(14, 12) * T
	sniper.hp = 30.0
	sniper.max_hp = 30.0
	sniper.damage = 30.0
	sniper.speed = 30.0
	sniper.chase_speed = 45.0
	sniper.detection_range = 150.0
	sniper.attack_range = 120.0
	sniper.attack_cd = 2.5
	sniper.xp_reward = 40.0
	sniper.enemy_died.connect(_on_enemy_killed)
	add_child(sniper)

	# === SECOND MAGE (near bar area) ===
	var mage2 := preload("res://ai/enemy_mage.gd").new()
	mage2.name = "ArcaneMage"
	mage2.patrol_points = [Vector2(55, 35), Vector2(65, 35), Vector2(65, 42), Vector2(55, 42)]
	mage2.position = Vector2(60, 38) * T
	mage2.hp = 45.0
	mage2.max_hp = 45.0
	mage2.damage = 22.0
	mage2.speed = 38.0
	mage2.chase_speed = 52.0
	mage2.detection_range = 120.0
	mage2.attack_range = 75.0
	mage2.attack_cd = 1.6
	mage2.xp_reward = 50.0
	mage2.enemy_died.connect(_on_enemy_killed)
	add_child(mage2)

	# === SECOND SNIPER (near city entrance) ===
	var sniper2 := preload("res://ai/enemy_sniper.gd").new()
	sniper2.name = "EliteSniper"
	sniper2.patrol_points = [Vector2(70, 10), Vector2(75, 10), Vector2(75, 18), Vector2(70, 18)]
	sniper2.position = Vector2(72, 14) * T
	sniper2.hp = 35.0
	sniper2.max_hp = 35.0
	sniper2.damage = 35.0
	sniper2.speed = 32.0
	sniper2.chase_speed = 48.0
	sniper2.detection_range = 160.0
	sniper2.attack_range = 130.0
	sniper2.attack_cd = 2.2
	sniper2.xp_reward = 45.0
	sniper2.enemy_died.connect(_on_enemy_killed)
	add_child(sniper2)

	# === PRACTICE DUMMIES (near spawn for tutorial) ===
	var dummy_positions := [
		Vector2(32, 24) * T,
		Vector2(34, 24) * T,
		Vector2(36, 24) * T,
	]
	for i in range(dummy_positions.size()):
		var dummy := preload("res://ai/enemy_base.gd").new()
		dummy.name = "PracticeDummy_%d" % i
		dummy.enemy_type = "guard"
		dummy.patrol_points = []
		dummy.position = dummy_positions[i]
		dummy.hp = 200.0
		dummy.max_hp = 200.0
		dummy.damage = 0.0
		dummy.speed = 0.0
		dummy.chase_speed = 0.0
		dummy.detection_range = 0.0
		dummy.attack_cd = 999.0
		dummy.xp_reward = 0.0
		dummy.loot_table = {}
		dummy.enemy_died.connect(_on_dummy_killed)
		add_child(dummy)
		var lbl := Label.new()
		lbl.text = "PRACTICE"
		lbl.add_theme_font_size_override("font_size", 7)
		lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.4, 0.6))
		lbl.position = Vector2(-10, -18)
		dummy.add_child(lbl)

func _on_dummy_killed(_enemy: Node2D) -> void:
	await get_tree().create_timer(5.0).timeout
	var dummy_positions := [
		Vector2(32, 24) * T,
		Vector2(34, 24) * T,
		Vector2(36, 24) * T,
	]
	for i in range(dummy_positions.size()):
		var dummy := preload("res://ai/enemy_base.gd").new()
		dummy.name = "PracticeDummy_%d" % i
		dummy.enemy_type = "guard"
		dummy.patrol_points = []
		dummy.position = dummy_positions[i]
		dummy.hp = 200.0
		dummy.max_hp = 200.0
		dummy.damage = 0.0
		dummy.speed = 0.0
		dummy.chase_speed = 0.0
		dummy.detection_range = 0.0
		dummy.attack_cd = 999.0
		dummy.xp_reward = 0.0
		dummy.loot_table = {}
		dummy.enemy_died.connect(_on_dummy_killed)
		add_child(dummy)

func _spawn_extra_enemies() -> void:
	# === EXTRA GUARDS in alleyways ===
	var extra_guards := [
		{"pos": Vector2(42, 12), "patrol": [Vector2(42, 12), Vector2(44, 14), Vector2(42, 16)], "hp": 55.0, "dmg": 14.0},
		{"pos": Vector2(8, 25), "patrol": [Vector2(8, 25), Vector2(12, 25), Vector2(12, 28)], "hp": 50.0, "dmg": 12.0},
		{"pos": Vector2(65, 32), "patrol": [Vector2(65, 32), Vector2(70, 32), Vector2(70, 36)], "hp": 60.0, "dmg": 15.0},
	]
	for i in range(extra_guards.size()):
		var e := preload("res://ai/enemy_base.gd").new()
		e.name = "PatrolGuard_%d" % i
		e.enemy_type = "guard"
		e.patrol_points = extra_guards[i].patrol
		e.position = extra_guards[i].pos * T
		e.hp = extra_guards[i].hp
		e.max_hp = extra_guards[i].hp
		e.damage = extra_guards[i].dmg
		e.speed = 48.0
		e.chase_speed = 78.0
		e.detection_range = 85.0
		e.enemy_died.connect(_on_enemy_killed)
		add_child(e)

	# === FAST RUNNERS in open areas ===
	var fast_enemies := [
		{"pos": Vector2(30, 50), "patrol": [Vector2(30, 50), Vector2(38, 50), Vector2(38, 55), Vector2(30, 55)]},
		{"pos": Vector2(55, 15), "patrol": [Vector2(55, 15), Vector2(62, 15), Vector2(62, 20)]},
	]
	for i in range(fast_enemies.size()):
		var f := preload("res://ai/enemy_base.gd").new()
		f.name = "SpeedRunner_%d" % i
		f.enemy_type = "fast"
		f.patrol_points = fast_enemies[i].patrol
		f.position = fast_enemies[i].pos * T
		f.hp = 28.0
		f.max_hp = 28.0
		f.damage = 10.0
		f.speed = 75.0
		f.chase_speed = 115.0
		f.detection_range = 105.0
		f.attack_cd = 0.5
		f.enemy_died.connect(_on_enemy_killed)
		add_child(f)

	# === HEAVY BRUTE near Clock Tower ===
	var heavy2 := preload("res://ai/enemy_base.gd").new()
	heavy2.name = "TowerGuard"
	heavy2.enemy_type = "heavy"
	heavy2.patrol_points = [Vector2(28, 3), Vector2(36, 3), Vector2(36, 8), Vector2(28, 8)]
	heavy2.position = Vector2(32, 5) * T
	heavy2.hp = 120.0
	heavy2.max_hp = 120.0
	heavy2.damage = 25.0
	heavy2.speed = 28.0
	heavy2.chase_speed = 48.0
	heavy2.detection_range = 75.0
	heavy2.attack_cd = 1.8
	heavy2.xp_reward = 30.0
	heavy2.enemy_died.connect(_on_enemy_killed)
	add_child(heavy2)

	# === EXTRA MAGE near apartments ===
	var mage3 := preload("res://ai/enemy_mage.gd").new()
	mage3.name = "ShadowMage"
	mage3.patrol_points = [Vector2(8, 38), Vector2(16, 38), Vector2(16, 45), Vector2(8, 45)]
	mage3.position = Vector2(12, 42) * T
	mage3.hp = 42.0
	mage3.max_hp = 42.0
	mage3.damage = 20.0
	mage3.speed = 36.0
	mage3.chase_speed = 50.0
	mage3.detection_range = 115.0
	mage3.attack_range = 78.0
	mage3.attack_cd = 1.7
	mage3.xp_reward = 48.0
	mage3.enemy_died.connect(_on_enemy_killed)
	add_child(mage3)

	# === EXTRA SNIPER on rooftop area ===
	var sniper3 := preload("res://ai/enemy_sniper.gd").new()
	sniper3.name = "RooftopSniper"
	sniper3.patrol_points = [Vector2(48, 2), Vector2(55, 2), Vector2(55, 6)]
	sniper3.position = Vector2(50, 4) * T
	sniper3.hp = 28.0
	sniper3.max_hp = 28.0
	sniper3.damage = 32.0
	sniper3.speed = 28.0
	sniper3.chase_speed = 42.0
	sniper3.detection_range = 155.0
	sniper3.attack_range = 125.0
	sniper3.attack_cd = 2.3
	sniper3.xp_reward = 42.0
	sniper3.enemy_died.connect(_on_enemy_killed)
	add_child(sniper3)

func _spawn_npcs() -> void:
	var informant := _make_npc(Vector2(15, 16) * T, "Informant", Color(0.4, 0.55, 0.75))
	informant.set_meta("interact_text", "Talk to Informant")
	informant.set_meta("dialogue", "I heard something about a man named Harlan. Be careful out there.")
	add_child(informant)

	var passerby1 := _make_npc(Vector2(25, 27) * T, "Citizen", Color(0.5, 0.55, 0.55))
	passerby1.set_meta("interact_text", "Just a citizen")
	passerby1.set_meta("dialogue", "This city never sleeps. Too many shadows.")
	add_child(passerby1)

	var painter := _make_npc(Vector2(58, 45) * T, "Painter", Color(0.65, 0.5, 0.4))
	painter.set_meta("interact_text", "Talk to Painter")
	painter.set_meta("dialogue", "Every brushstroke captures a moment in time. I paint what the Clock shows me...")
	add_child(painter)

	var civilian_data := [
		{"pos": Vector2(12, 27), "color": Color(0.55, 0.50, 0.45), "name": "Pedestrian"},
		{"pos": Vector2(42, 27), "color": Color(0.50, 0.55, 0.50), "name": "Merchant"},
		{"pos": Vector2(58, 31), "color": Color(0.55, 0.50, 0.55), "name": "Drifter"},
		{"pos": Vector2(22, 31), "color": Color(0.50, 0.50, 0.55), "name": "Worker"},
		{"pos": Vector2(33, 40), "color": Color(0.55, 0.55, 0.50), "name": "Resident"},
	]
	for cd in civilian_data:
		var civ := _make_civilian(cd.pos * T, cd.name, cd.color)
		_civilians.append(civ)
		add_child(civ)

	var trader := _make_npc(Vector2(20, 28) * T, "Trader", Color(0.7, 0.6, 0.2))
	trader.set_meta("interact_text", "Open Shop")
	trader.set_meta("is_trader", true)
	trader.set_meta("dialogue", "Welcome! Browse my wares.")
	add_child(trader)

	var board := _make_npc(Vector2(32, 16) * T, "Contract Board", Color(0.4, 0.4, 0.5))
	board.set_meta("interact_text", "View Contracts")
	board.set_meta("is_contract_board", true)
	add_child(board)

	var tm := _make_npc(Vector2(32, 28) * T, "Time Machine", Color(0.3, 0.6, 0.9))
	tm.set_meta("interact_text", "Use Time Machine")
	tm.set_meta("is_time_machine", true)
	tm.set_meta("dialogue", "Select a destination era.")
	add_child(tm)

	# === NEW NPCs ===
	var guard_npc := _make_npc(Vector2(40, 10) * T, "City Guard", Color(0.4, 0.45, 0.5))
	guard_npc.set_meta("interact_text", "Talk to Guard")
	guard_npc.set_meta("dialogue", "Keep your weapon sheathed in the market. The enforcers don't like trouble.")
	add_child(guard_npc)

	var bartender := _make_npc(Vector2(58, 38) * T, "Bartender", Color(0.6, 0.45, 0.3))
	bartender.set_meta("interact_text", "Talk to Bartender")
	bartender.set_meta("dialogue", "Drinks are on the house if you can tell me what the Clock whispered last night...")
	add_child(bartender)

	var old_woman := _make_npc(Vector2(12, 35) * T, "Old Woman", Color(0.55, 0.5, 0.55))
	old_woman.set_meta("interact_text", "Talk to Old Woman")
	old_woman.set_meta("dialogue", "I remember when this city was different. The Clock changed everything... for better or worse.")
	add_child(old_woman)

	var kid := _make_npc(Vector2(45, 30) * T, "Street Kid", Color(0.6, 0.55, 0.4))
	kid.set_meta("interact_text", "Talk to Street Kid")
	kid.set_meta("dialogue", "Psst! I saw someone suspicious near the old tower. Want me to show you?")
	add_child(kid)

	var merchant2 := _make_npc(Vector2(65, 25) * T, "Black Market Dealer", Color(0.35, 0.3, 0.4))
	merchant2.set_meta("interact_text", "Browse Black Market")
	merchant2.set_meta("is_trader", true)
	merchant2.set_meta("dialogue", "I have things the regular trader can't get. Interested?")
	add_child(merchant2)

	var traveler := _make_npc(Vector2(22, 15) * T, "Time Traveler", Color(0.5, 0.7, 0.9))
	traveler.set_meta("interact_text", "Talk to Traveler")
	traveler.set_meta("dialogue", "I've been to the past. The future. Even the collapsed timeline. Each era has its own secrets.")
	add_child(traveler)

	var bounty_hunter := _make_npc(Vector2(50, 45) * T, "Bounty Hunter", Color(0.7, 0.3, 0.25))
	bounty_hunter.set_meta("interact_text", "Talk to Bounty Hunter")
	bounty_hunter.set_meta("dialogue", "High-value targets pay well. But they also shoot back. You look like you can handle yourself.")
	add_child(bounty_hunter)

func _spawn_environment_props() -> void:
	# 0. Training Zone Marker (near spawn dummies)
	_make_training_zone_marker(Vector2(34, 22) * T)

	# 1. Central Plaza Animated Water Fountain
	_make_interactive_fountain(Vector2(28, 16) * T)

	# 2. Park Zone Greenery & Trees
	var tree_spots := [
		{"pos": Vector2(68, 6) * T, "type": "tree_oak"},
		{"pos": Vector2(74, 8) * T, "type": "tree_pine"},
		{"pos": Vector2(70, 14) * T, "type": "tree_green_2"},
		{"pos": Vector2(75, 18) * T, "type": "tree_dead"},
		{"pos": Vector2(66, 22) * T, "type": "tree_small_1"},
		{"pos": Vector2(14, 18) * T, "type": "tree_oak"},
		{"pos": Vector2(6, 32) * T, "type": "stump"},
		# Extra trees around the world
		{"pos": Vector2(4, 14) * T, "type": "tree_small_1"},
		{"pos": Vector2(8, 6) * T, "type": "tree_green_1"},
		{"pos": Vector2(16, 8) * T, "type": "tree_palm"},
		{"pos": Vector2(24, 6) * T, "type": "tree_autumn_1"},
		{"pos": Vector2(50, 8) * T, "type": "tree_pine"},
		{"pos": Vector2(58, 6) * T, "type": "tree_small_2"},
		{"pos": Vector2(42, 50) * T, "type": "tree_dead"},
		{"pos": Vector2(10, 48) * T, "type": "tree_oak"},
		{"pos": Vector2(30, 52) * T, "type": "tree_green_2"},
	]
	for ts in tree_spots:
		_make_tree(ts.pos, ts.type)

	var flora_spots := [
		{"pos": Vector2(68, 10) * T, "type": "bush_green"},
		{"pos": Vector2(72, 12) * T, "type": "flower_red"},
		{"pos": Vector2(74, 16) * T, "type": "bush_blue"},
		{"pos": Vector2(67, 18) * T, "type": "mushroom"},
		{"pos": Vector2(71, 22) * T, "type": "fern"},
		{"pos": Vector2(25, 25) * T, "type": "grass_tall"},
		{"pos": Vector2(35, 25) * T, "type": "flower_yellow"},
		{"pos": Vector2(69, 8) * T, "type": "rock"},
		{"pos": Vector2(73, 20) * T, "type": "log"},
	]
	for fs in flora_spots:
		_make_flora(fs.pos, fs.type)

	# === EXTRA FLORA (scattered around the world) ===
	var extra_flora := [
		# Park area - dense vegetation
		{"pos": Vector2(66, 8) * T, "type": "bush_large_1"},
		{"pos": Vector2(76, 10) * T, "type": "bush_small_2"},
		{"pos": Vector2(68, 16) * T, "type": "flower_red"},
		{"pos": Vector2(72, 8) * T, "type": "flower_yellow"},
		{"pos": Vector2(74, 14) * T, "type": "fern_patch"},
		{"pos": Vector2(70, 20) * T, "type": "mushrooms"},
		{"pos": Vector2(76, 18) * T, "type": "plants_patch_1"},
		# Near water area
		{"pos": Vector2(48, 50) * T, "type": "cattail"},
		{"pos": Vector2(50, 52) * T, "type": "cattail"},
		{"pos": Vector2(52, 50) * T, "type": "fern"},
		# City outskirts
		{"pos": Vector2(8, 8) * T, "type": "bush_green"},
		{"pos": Vector2(10, 12) * T, "type": "grass_tall"},
		{"pos": Vector2(6, 18) * T, "type": "rock"},
		{"pos": Vector2(14, 6) * T, "type": "flower_patch_1"},
		# Scattered around buildings
		{"pos": Vector2(25, 10) * T, "type": "bush_small_1"},
		{"pos": Vector2(35, 8) * T, "type": "flower_yellow"},
		{"pos": Vector2(55, 12) * T, "type": "bush_blue"},
		{"pos": Vector2(60, 15) * T, "type": "fern"},
		# Bar area decorations
		{"pos": Vector2(56, 36) * T, "type": "mushroom"},
		{"pos": Vector2(62, 40) * T, "type": "log"},
		{"pos": Vector2(58, 42) * T, "type": "plants_patch_2"},
	]
	for ef in extra_flora:
		_make_flora(ef.pos, ef.type)

	# 3. Interactive Treasure Chests
	var chest_spots := [
		Vector2(8, 22) * T,
		Vector2(72, 42) * T,
		Vector2(48, 6) * T,
		Vector2(62, 24) * T,
	]
	for cp in chest_spots:
		_make_chest(cp)

	# 4. Torches on building walls
	var torch_spots := [
		Vector2(5, 7) * T, Vector2(18, 7) * T,
		Vector2(45, 7) * T, Vector2(56, 7) * T,
		Vector2(5, 40) * T, Vector2(16, 40) * T,
		Vector2(50, 40) * T,
	]
	for tp in torch_spots:
		_make_torch(tp)

	# 5. Campfires in park zone
	var campfire_spots := [
		Vector2(68, 10) * T,
		Vector2(12, 20) * T,
	]
	for cp in campfire_spots:
		_make_campfire(cp)

	# 6. Portal (time machine visual marker)
	_make_portal(Vector2(32, 28) * T)

	# 7. Benches along streets
	var bench_spots := [
		Vector2(20, 27) * T, Vector2(30, 27) * T, Vector2(40, 27) * T,
		Vector2(55, 27) * T, Vector2(65, 27) * T,
		Vector2(20, 31) * T, Vector2(40, 31) * T, Vector2(55, 31) * T,
	]
	for bp in bench_spots:
		_make_bench(bp)

	# 8. Street Signs
	var sign_spots := [
		{"pos": Vector2(15, 27) * T, "text": "MARKET →"},
		{"pos": Vector2(45, 27) * T, "text": "← CLOCK TOWER"},
		{"pos": Vector2(35, 25) * T, "text": "TRAINING ZONE"},
		{"pos": Vector2(60, 27) * T, "text": "PARK →"},
		{"pos": Vector2(10, 31) * T, "text": "INN ↑"},
	]
	for ss in sign_spots:
		_make_sign(ss.pos, ss.text)

	# 9. Market Stalls
	var stall_spots := [
		Vector2(22, 28) * T,
		Vector2(26, 28) * T,
		Vector2(42, 30) * T,
	]
	for sp in stall_spots:
		_make_market_stall(sp)

	# 10. Barrels and Crates clusters
	var barrel_clusters := [
		[Vector2(58, 36) * T, Vector2(59, 36) * T, Vector2(58, 37) * T],
		[Vector2(18, 44) * T, Vector2(19, 44) * T],
		[Vector2(68, 40) * T, Vector2(69, 40) * T, Vector2(69, 41) * T],
	]
	for cluster in barrel_clusters:
		for bp in cluster:
			_make_barrel(bp)

	# 11. Well in courtyard
	_make_well(Vector2(15, 10) * T)

	# 12. Graveyard near church area
	var gravestones := [
		Vector2(70, 24) * T, Vector2(73, 24) * T, Vector2(76, 24) * T,
		Vector2(70, 26) * T, Vector2(73, 26) * T,
	]
	for gp in gravestones:
		_make_gravestone(gp)

func _make_bench(pos: Vector2) -> void:
	var bench := StaticBody2D.new()
	bench.name = "Bench"
	bench.position = pos
	bench.collision_layer = 1
	bench.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 8)
	col.shape = shape
	bench.add_child(col)
	var spr := Sprite2D.new()
	var img := Image.create(10, 4, false, Image.FORMAT_RGBA8)
	for x in range(10):
		for y in range(4):
			if y == 0 or y == 3:
				img.set_pixel(x, y, Color(0.35, 0.22, 0.12))
			elif y == 1:
				img.set_pixel(x, y, Color(0.45, 0.30, 0.15))
			else:
				img.set_pixel(x, y, Color(0.40, 0.26, 0.13))
	spr.texture = ImageTexture.create_from_image(img)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(2, 2)
	bench.add_child(spr)
	add_child(bench)

func _make_sign(pos: Vector2, text: String) -> void:
	var sign := StaticBody2D.new()
	sign.name = "StreetSign"
	sign.position = pos
	sign.collision_layer = 1
	sign.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 20)
	col.shape = shape
	sign.add_child(col)
	var post := ColorRect.new()
	post.color = Color(0.3, 0.2, 0.1)
	post.position = Vector2(-1, -4)
	post.size = Vector2(3, 16)
	sign.add_child(post)
	var board := ColorRect.new()
	board.color = Color(0.25, 0.18, 0.08)
	board.position = Vector2(-14, -14)
	board.size = Vector2(28, 10)
	sign.add_child(board)
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.80, 0.60))
	lbl.position = Vector2(-13, -13)
	sign.add_child(lbl)
	add_child(sign)

func _make_market_stall(pos: Vector2) -> void:
	var stall := StaticBody2D.new()
	stall.name = "MarketStall"
	stall.position = pos
	stall.collision_layer = 1
	stall.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 20)
	col.shape = shape
	stall.add_child(col)
	var roof := ColorRect.new()
	roof.color = Color(0.6, 0.2, 0.15)
	roof.position = Vector2(-16, -16)
	roof.size = Vector2(32, 6)
	stall.add_child(roof)
	var counter := ColorRect.new()
	counter.color = Color(0.4, 0.28, 0.14)
	counter.position = Vector2(-14, -8)
	counter.size = Vector2(28, 10)
	stall.add_child(counter)
	var goods := ColorRect.new()
	goods.color = Color(0.7, 0.5, 0.2)
	goods.position = Vector2(-10, -6)
	goods.size = Vector2(6, 4)
	stall.add_child(goods)
	var goods2 := ColorRect.new()
	goods2.color = Color(0.3, 0.6, 0.3)
	goods2.position = Vector2(2, -6)
	goods2.size = Vector2(8, 4)
	stall.add_child(goods2)
	add_child(stall)

func _make_barrel(pos: Vector2) -> void:
	var barrel := StaticBody2D.new()
	barrel.name = "Barrel"
	barrel.position = pos
	barrel.collision_layer = 1
	barrel.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	barrel.add_child(col)
	var spr := Sprite2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	for x in range(6):
		for y in range(6):
			var d := Vector2(x - 2.5, y - 2.5).length()
			if d <= 2.5:
				var c := Color(0.4, 0.28, 0.12) if (y == 1 or y == 4) else Color(0.5, 0.35, 0.15)
				img.set_pixel(x, y, c)
	spr.texture = ImageTexture.create_from_image(img)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	barrel.add_child(spr)
	add_child(barrel)

func _make_well(pos: Vector2) -> void:
	var well := StaticBody2D.new()
	well.name = "Well"
	well.position = pos
	well.collision_layer = 1
	well.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	col.shape = shape
	well.add_child(col)
	var wall := Sprite2D.new()
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	for x in range(12):
		for y in range(12):
			var d := Vector2(x - 5.5, y - 5.5).length()
			if d <= 5.5 and d > 3.5:
				img.set_pixel(x, y, Color(0.35, 0.30, 0.25))
			elif d <= 3.5:
				img.set_pixel(x, y, Color(0.15, 0.25, 0.40))
	wall.texture = ImageTexture.create_from_image(img)
	wall.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	well.add_child(wall)
	add_child(well)

func _make_gravestone(pos: Vector2) -> void:
	var stone := StaticBody2D.new()
	stone.name = "Gravestone"
	stone.position = pos
	stone.collision_layer = 1
	stone.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(6, 10)
	col.shape = shape
	stone.add_child(col)
	var spr := Sprite2D.new()
	var img := Image.create(4, 6, false, Image.FORMAT_RGBA8)
	for x in range(4):
		for y in range(6):
			var d := Vector2(x - 1.5, y - 0.5).length()
			if d <= 2.0 or (y >= 1 and x >= 0 and x < 4):
				img.set_pixel(x, y, Color(0.4, 0.38, 0.35))
	spr.texture = ImageTexture.create_from_image(img)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stone.add_child(spr)
	add_child(stone)

func _make_training_zone_marker(pos: Vector2) -> void:
	var marker := StaticBody2D.new()
	marker.name = "TrainingZone"
	marker.position = pos
	marker.collision_layer = 1
	marker.collision_mask = 2
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	marker.add_child(col)
	var lbl := Label.new()
	lbl.text = "TRAINING ZONE\nLMB x3 = Combo\nShift+LMB = Dash"
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5, 0.7))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-32, -30)
	marker.add_child(lbl)
	add_child(marker)

func _make_interactive_fountain(pos: Vector2) -> void:
	var f := StaticBody2D.new()
	f.name = "WaterFountain"
	f.position = pos
	f.collision_layer = 1
	f.collision_mask = 2

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 40)
	col.shape = shape
	col.position = Vector2(0, 16)
	f.add_child(col)

	var spr := Sprite2D.new()
	var sheet_path := "res://assets/2d/environment/props/water_fountain_sheet.png"
	if ResourceLoader.exists(sheet_path):
		spr.texture = load(sheet_path)
		spr.hframes = 2
		spr.frame = 0
		var tw := create_tween().set_loops()
		tw.tween_callback(func(): spr.frame = (spr.frame + 1) % 2)
		tw.tween_interval(0.4)
	elif ResourceLoader.exists("res://assets/2d/environment/props/water_fountain.png"):
		spr.texture = load("res://assets/2d/environment/props/water_fountain.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 0
	f.add_child(spr)

	f.set_meta("interact_text", "Rest at Temporal Fountain")
	f.set_meta("interact_func", Callable(self, "_on_fountain_interacted"))
	f.add_to_group("interactable")
	add_child(f)

func _on_fountain_interacted(caller: Node2D) -> void:
	if player and "hp" in player and "energy" in player:
		player.hp = minf(player.max_hp, player.hp + 35.0)
		player.energy = minf(player.max_energy, player.energy + 35.0)
		if "hp_changed" in player:
			player.hp_changed.emit(player.hp, player.max_hp)
		if "energy_changed" in player:
			player.energy_changed.emit(player.energy)
	AudioLib2D.play("success")
	_show_floating_text("RESTED AT FOUNTAIN (+35 HP / +35 EN)", Color(0.3, 0.9, 0.9), Vector2(640, 300))

func _make_tree(pos: Vector2, tree_type: String) -> void:
	var path := "res://assets/2d/environment/plants/%s.png" % tree_type
	if not ResourceLoader.exists(path):
		return
	var tree := StaticBody2D.new()
	tree.position = pos
	tree.collision_layer = 1
	tree.collision_mask = 2

	var spr := Sprite2D.new()
	spr.texture = load(path)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(0, -20)
	spr.z_index = 2
	tree.add_child(spr)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	col.shape = shape
	col.position = Vector2(0, 4)
	tree.add_child(col)

	add_child(tree)

func _make_flora(pos: Vector2, flora_type: String) -> void:
	var path := "res://assets/2d/environment/plants/%s.png" % flora_type
	if not ResourceLoader.exists(path):
		return
	var spr := Sprite2D.new()
	spr.texture = load(path)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = pos
	spr.z_index = 0
	add_child(spr)

func _make_chest(pos: Vector2) -> void:
	var chest := StaticBody2D.new()
	chest.name = "TreasureChest"
	chest.position = pos
	chest.collision_layer = 8
	chest.collision_mask = 1
	chest.set_meta("interact_text", "Open Chest")
	chest.set_meta("opened", false)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14, 12)
	col.shape = shape
	chest.add_child(col)

	var spr := Sprite2D.new()
	var closed_path := "res://assets/2d/environment/props/chest_closed.png"
	if ResourceLoader.exists(closed_path):
		spr.texture = load(closed_path)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 1
	chest.add_child(spr)

	chest.set_meta("interact_func", Callable(func(caller):
		if chest.get_meta("opened", false):
			return
		chest.set_meta("opened", true)
		var open_path := "res://assets/2d/environment/props/chest_open.png"
		if ResourceLoader.exists(open_path):
			spr.texture = load(open_path)
		var credits := randi_range(40, 120)
		GameManager.add_currency(credits)
		GameManager.add_xp(30.0)
		AudioLib2D.play("success")
		_show_floating_text("+%d CREDITS / +30 XP" % credits, Color(0.9, 0.8, 0.2), Vector2(640, 280))
	))

	chest.add_to_group("interactable")
	add_child(chest)


func _make_torch(pos: Vector2) -> void:
	var torch := StaticBody2D.new()
	torch.name = "Torch"
	torch.position = pos
	torch.collision_layer = 0
	var spr := Sprite2D.new()
	var path := "res://assets/2d/environment/props/torch_lit.png"
	if ResourceLoader.exists(path):
		spr.texture = load(path)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	else:
		var img := Image.create(6, 10, false, Image.FORMAT_RGBA8)
		for x in range(2, 4): for y in range(0, 4): img.set_pixel(x, y, Color(1.0, 0.7, 0.1, 0.9))
		for x in range(2, 4): for y in range(4, 10): img.set_pixel(x, y, Color(0.35, 0.25, 0.15))
		spr.texture = ImageTexture.create_from_image(img)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 1
	torch.add_child(spr)
	# animated flame glow
	var glow := Sprite2D.new()
	glow.position = Vector2(0, -2)
	glow.scale = Vector2(1.5, 1.5)
	var glow_img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in range(8):
		for x in range(8):
			var d: float = Vector2(x - 3.5, y - 3.5).length()
			if d < 3.5:
				var a: float = clampf(1.0 - d / 3.5, 0.0, 0.4)
				glow_img.set_pixel(x, y, Color(1.0, 0.6, 0.1, a))
	glow.texture = ImageTexture.create_from_image(glow_img)
	glow.z_index = 0
	torch.add_child(glow)
	var tw := create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.3).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.7, 0.3).set_trans(Tween.TRANS_SINE)
	add_child(torch)


func _make_campfire(pos: Vector2) -> void:
	var fire := StaticBody2D.new()
	fire.name = "Campfire"
	fire.position = pos
	fire.collision_layer = 0
	var spr := Sprite2D.new()
	var path := "res://assets/2d/environment/props/campfire.png"
	if ResourceLoader.exists(path):
		spr.texture = load(path)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	else:
		var img := Image.create(12, 10, false, Image.FORMAT_RGBA8)
		for x in range(3, 9): for y in range(4, 7): img.set_pixel(x, y, Color(0.35, 0.25, 0.15))
		for x in range(4, 8): for y in range(0, 4): img.set_pixel(x, y, Color(1.0, 0.6, 0.1, 0.9))
		img.set_pixel(5, 0, Color(1.0, 0.9, 0.3, 0.8))
		img.set_pixel(6, 0, Color(1.0, 0.8, 0.2, 0.8))
		spr.texture = ImageTexture.create_from_image(img)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 1
	fire.add_child(spr)
	# flame particles
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 8
	particles.lifetime = 0.6
	particles.direction = Vector2(0, -1)
	particles.spread = 20.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 25.0
	particles.gravity = Vector2(0, -20)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.7
	particles.color = Color(1.0, 0.6, 0.1, 0.8)
	particles.position = Vector2(0, -4)
	particles.z_index = 2
	fire.add_child(particles)
	# glow
	var glow := Sprite2D.new()
	glow.position = Vector2(0, -2)
	glow.scale = Vector2(2.0, 2.0)
	var glow_img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	for y in range(12):
		for x in range(12):
			var d: float = Vector2(x - 5.5, y - 5.5).length()
			if d < 5.5:
				var a: float = clampf(1.0 - d / 5.5, 0.0, 0.25)
				glow_img.set_pixel(x, y, Color(1.0, 0.5, 0.05, a))
	glow.texture = ImageTexture.create_from_image(glow_img)
	glow.z_index = 0
	fire.add_child(glow)
	var tw := create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.4, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.9, 0.4).set_trans(Tween.TRANS_SINE)
	add_child(fire)


func _make_portal(pos: Vector2) -> void:
	var portal := StaticBody2D.new()
	portal.name = "Portal"
	portal.position = pos
	portal.collision_layer = 0
	var spr := Sprite2D.new()
	var path := "res://assets/2d/environment/props/portal_blue.png"
	if ResourceLoader.exists(path):
		spr.texture = load(path)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	else:
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		for y in range(16):
			for x in range(16):
				var d: float = Vector2(x - 7.5, y - 7.5).length()
				if d > 3.0 and d < 7.5:
					var a: float = clampf(1.0 - (d - 3.0) / 4.5, 0.1, 0.7)
					img.set_pixel(x, y, Color(0.3, 0.5, 1.0, a))
		spr.texture = ImageTexture.create_from_image(img)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 1
	portal.add_child(spr)
	# swirling glow
	var glow := Sprite2D.new()
	glow.scale = Vector2(1.8, 1.8)
	var glow_img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var d: float = Vector2(x - 7.5, y - 7.5).length()
			if d < 7.5:
				var a: float = clampf(1.0 - d / 7.5, 0.0, 0.3)
				glow_img.set_pixel(x, y, Color(0.2, 0.4, 0.9, a))
	glow.texture = ImageTexture.create_from_image(glow_img)
	glow.z_index = 0
	portal.add_child(glow)
	var tw := create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.15, 1.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.5, 1.5).set_trans(Tween.TRANS_SINE)
	add_child(portal)


func _placeholder_heart(color: Color) -> Texture2D:
	var img := Image.create(8, 7, false, Image.FORMAT_RGBA8)
	for x in [2, 5]: img.set_pixel(x, 0, color)
	for x in range(1, 7): img.set_pixel(x, 1, color)
	for x in range(0, 8): img.set_pixel(x, 2, color)
	for x in range(0, 8): img.set_pixel(x, 3, color)
	for x in range(1, 7): img.set_pixel(x, 4, color)
	for x in range(2, 6): img.set_pixel(x, 5, color)
	img.set_pixel(3, 6, color)
	img.set_pixel(4, 6, color)
	return ImageTexture.create_from_image(img)

func _npc_texture(color: Color) -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for x in range(5, 11): for y in range(0, 4): img.set_pixel(x, y, color.lightened(0.1))
	for x in range(4, 12): for y in range(4, 11): img.set_pixel(x, y, color)
	for x in range(5, 7): for y in range(11, 16): img.set_pixel(x, y, color.darkened(0.15))
	for x in range(9, 11): for y in range(11, 16): img.set_pixel(x, y, color.darkened(0.15))
	return ImageTexture.create_from_image(img)

func _make_npc(pos: Vector2, npc_name: String, color: Color) -> Node2D:
	var npc := StaticBody2D.new()
	npc.name = npc_name
	npc.position = pos
	npc.collision_layer = 8
	npc.collision_mask = 1
	npc.set_meta("interact_text", "")
	npc.set_meta("npc_name", npc_name)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	npc.add_child(col)

	var spr := Sprite2D.new()
	var sheet_path := "res://assets/2d/characters/npc_sheet.png"
	if ResourceLoader.exists(sheet_path):
		spr.texture = load(sheet_path)
		spr.hframes = 8
		spr.vframes = 2
		spr.frame = 0
	elif ResourceLoader.exists("res://assets/2d/characters/npc.png"):
		spr.texture = load("res://assets/2d/characters/npc.png")
	else:
		spr.texture = _npc_texture(color)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.add_child(spr)

	var emote := Sprite2D.new()
	var emote_path := "res://assets/2d/hud/emotes/dialogue.png"
	if ResourceLoader.exists(emote_path):
		emote.texture = load(emote_path)
	else:
		var ei := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		ei.fill(Color(0.8, 0.8, 0.6, 0.5))
		emote.texture = ImageTexture.create_from_image(ei)
	emote.position = Vector2(0, -18)
	emote.scale = Vector2(0.6, 0.6)
	emote.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.add_child(emote)

	var lbl := Label.new()
	lbl.text = npc_name
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.position = Vector2(-12, -22)
	lbl.modulate = Color(0.85, 0.9, 0.85, 0.9)
	npc.add_child(lbl)

	npc.add_to_group("interactable")
	npc.add_to_group("npcs")
	return npc

func _make_civilian(pos: Vector2, civ_name: String, color: Color) -> Node2D:
	var civ := CharacterBody2D.new()
	civ.name = civ_name
	civ.position = pos
	civ.collision_layer = 8
	civ.collision_mask = 1
	civ.set_meta("is_civilian", true)
	civ.set_meta("home_pos", pos)
	civ.set_meta("wander_timer", randf_range(2.0, 6.0))
	civ.set_meta("wander_target", pos)
	civ.set_meta("is_moving", false)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	col.shape = shape
	civ.add_child(col)

	var spr := Sprite2D.new()
	var sheet_path := "res://assets/2d/characters/npc_sheet.png"
	if ResourceLoader.exists(sheet_path):
		spr.texture = load(sheet_path)
		spr.hframes = 8
		spr.vframes = 2
		spr.frame = 0
	else:
		spr.texture = _npc_texture(color)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	civ.add_child(spr)

	var lbl := Label.new()
	lbl.text = civ_name
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.position = Vector2(-10, -16)
	lbl.modulate = Color(0.7, 0.75, 0.7, 0.6)
	civ.add_child(lbl)

	civ.add_to_group("civilians")
	civ.add_to_group("npcs")
	civ.add_to_group("interactable")
	return civ

func _update_civilians(delta: float) -> void:
	_civilian_timer -= delta
	if _civilian_timer > 0.0:
		return
	_civilian_timer = 0.5

	for civ in _civilians:
		if not is_instance_valid(civ):
			continue
		var home: Vector2 = civ.get_meta("home_pos", civ.position)
		var wander_target: Vector2 = civ.get_meta("wander_target", home)
		var is_moving: bool = civ.get_meta("is_moving", false)
		var wander_timer: float = civ.get_meta("wander_timer", 3.0)

		wander_timer -= 0.5

		if not is_moving:
			if wander_timer <= 0.0:
				var angle := randf() * TAU
				var dist := randf_range(16.0, 48.0)
				wander_target = home + Vector2(cos(angle), sin(angle)) * dist
				wander_target = wander_target.clamp(Vector2(32, 32), Vector2(80 * T - 32, 60 * T - 32))
				civ.set_meta("wander_target", wander_target)
				civ.set_meta("is_moving", true)
				wander_timer = randf_range(3.0, 7.0)
		else:
			var to_target := wander_target - civ.position
			if to_target.length() < 4.0:
				civ.set_meta("is_moving", false)
				wander_timer = randf_range(2.0, 5.0)
			else:
				var speed := 20.0
				civ.velocity = to_target.normalized() * speed
				civ.move_and_slide()
				var spr: Sprite2D = civ.get_node_or_null("Sprite2D")
				if spr:
					spr.flip_h = civ.velocity.x < 0.0

		civ.set_meta("wander_timer", wander_timer)

func _setup_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HUD"
	hud_layer.layer = 10
	add_child(hud_layer)

	# HP heart icon
	var hp_heart := Sprite2D.new()
	if ResourceLoader.exists("res://assets/2d/hud/hearts/heart_full.png"):
		hp_heart.texture = load("res://assets/2d/hud/hearts/heart_full.png")
		hp_heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hp_heart.scale = Vector2(1.2, 1.2)
	else:
		hp_heart.texture = _placeholder_heart(Color(0.9, 0.2, 0.2))
	hp_heart.position = Vector2(12, 14)
	hud_layer.add_child(hp_heart)

	_hp_bg = ColorRect.new()
	_hp_bg.color = Color(0.08, 0.08, 0.10, 0.7)
	_hp_bg.position = Vector2(22, 10)
	_hp_bg.size = Vector2(64, 8)
	hud_layer.add_child(_hp_bg)

	_hp_bar = ColorRect.new()
	_hp_bar.color = Color(0.80, 0.20, 0.20)
	_hp_bar.position = Vector2(23, 11)
	_hp_bar.size = Vector2(62, 6)
	hud_layer.add_child(_hp_bar)

	# Energy lightning icon
	var en_icon := Sprite2D.new()
	if ResourceLoader.exists("res://assets/2d/hud/hearts/heart_full_blue.png"):
		en_icon.texture = load("res://assets/2d/hud/hearts/heart_full_blue.png")
		en_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		en_icon.scale = Vector2(1.2, 1.2)
	else:
		en_icon.texture = _placeholder_heart(Color(0.3, 0.55, 0.9))
	en_icon.position = Vector2(12, 26)
	hud_layer.add_child(en_icon)

	_en_bg = ColorRect.new()
	_en_bg.color = Color(0.08, 0.08, 0.10, 0.7)
	_en_bg.position = Vector2(22, 22)
	_en_bg.size = Vector2(64, 8)
	hud_layer.add_child(_en_bg)

	_en_bar = ColorRect.new()
	_en_bar.color = Color(0.25, 0.55, 0.85)
	_en_bar.position = Vector2(23, 23)
	_en_bar.size = Vector2(62, 6)
	hud_layer.add_child(_en_bar)

	_weapon_label = Label.new()
	_weapon_label.text = "HUNTER BLADE"
	_weapon_label.add_theme_font_size_override("font_size", 10)
	_weapon_label.position = Vector2(10, 34)
	_weapon_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	hud_layer.add_child(_weapon_label)

	_era_label = Label.new()
	_era_label.text = "MODERN — NIGHT"
	_era_label.add_theme_font_size_override("font_size", 10)
	_era_label.position = Vector2(10, 48)
	_era_label.add_theme_color_override("font_color", Color(0.45, 0.70, 0.55))
	hud_layer.add_child(_era_label)

	_objective_label = Label.new()
	_objective_label.text = "Open Blood Clock (Q) to receive contract"
	_objective_label.add_theme_font_size_override("font_size", 10)
	_objective_label.position = Vector2(10, 62)
	_objective_label.add_theme_color_override("font_color", Color(0.90, 0.85, 0.50))
	hud_layer.add_child(_objective_label)

	_detection_indicator = Label.new()
	_detection_indicator.text = ""
	_detection_indicator.add_theme_font_size_override("font_size", 14)
	_detection_indicator.position = Vector2(640, 10)
	_detection_indicator.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	_detection_indicator.visible = false
	hud_layer.add_child(_detection_indicator)

	# === COMBO HUD (top-right) ===
	_combo_bg = ColorRect.new()
	_combo_bg.color = Color(0.0, 0.0, 0.0, 0.0)
	_combo_bg.position = Vector2(1100, 60)
	_combo_bg.size = Vector2(160, 60)
	_combo_bg.visible = false
	hud_layer.add_child(_combo_bg)

	_combo_label = Label.new()
	_combo_label.text = ""
	_combo_label.add_theme_font_size_override("font_size", 36)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_combo_label.position = Vector2(1100, 55)
	_combo_label.visible = false
	_combo_label.z_index = 2
	hud_layer.add_child(_combo_label)

	_combo_timer_label = Label.new()
	_combo_timer_label.text = ""
	_combo_timer_label.add_theme_font_size_override("font_size", 11)
	_combo_timer_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5, 0.7))
	_combo_timer_label.position = Vector2(1105, 95)
	_combo_timer_label.visible = false
	hud_layer.add_child(_combo_timer_label)

	var hint := Label.new()
	hint.text = "WASD Move | Shift+LMB Dash Attack | 1-4 Weapons | Space Dodge | Q Clock | E Interact"
	hint.add_theme_font_size_override("font_size", 9)
	hint.position = Vector2(10, 700)
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.5))
	hud_layer.add_child(hint)

	_kill_label = Label.new()
	_kill_label.text = "KILLS: 0"
	_kill_label.add_theme_font_size_override("font_size", 10)
	_kill_label.position = Vector2(10, 84)
	_kill_label.add_theme_color_override("font_color", Color(0.85, 0.35, 0.30))
	hud_layer.add_child(_kill_label)

	_xp_bg = ColorRect.new()
	_xp_bg.color = Color(0.08, 0.08, 0.10, 0.7)
	_xp_bg.position = Vector2(10, 98)
	_xp_bg.size = Vector2(64, 5)
	hud_layer.add_child(_xp_bg)

	_xp_bar = ColorRect.new()
	_xp_bar.color = Color(0.3, 0.7, 0.9)
	_xp_bar.position = Vector2(11, 99)
	_xp_bar.size = Vector2(0, 3)
	hud_layer.add_child(_xp_bar)

	_level_label = Label.new()
	_level_label.text = "LV 1"
	_level_label.add_theme_font_size_override("font_size", 9)
	_level_label.position = Vector2(78, 96)
	_level_label.add_theme_color_override("font_color", Color(0.4, 0.75, 0.95))
	hud_layer.add_child(_level_label)

	_currency_label = Label.new()
	_currency_label.text = "$0"
	_currency_label.add_theme_font_size_override("font_size", 10)
	_currency_label.position = Vector2(10, 108)
	_currency_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	hud_layer.add_child(_currency_label)

	_contract_type_label = Label.new()
	_contract_type_label.text = ""
	_contract_type_label.add_theme_font_size_override("font_size", 9)
	_contract_type_label.position = Vector2(10, 122)
	_contract_type_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	hud_layer.add_child(_contract_type_label)

	_target_arrow = Label.new()
	_target_arrow.text = ""
	_target_arrow.add_theme_font_size_override("font_size", 20)
	_target_arrow.position = Vector2(640, 360)
	_target_arrow.visible = false
	_target_arrow.z_index = 15
	hud_layer.add_child(_target_arrow)

	if player:
		player.hp_changed.connect(_on_hp_changed)
		player.energy_changed.connect(_on_energy_changed)
		player.weapon_changed.connect(func(w): if _weapon_label: _weapon_label.text = w.to_upper())

	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.level_up.connect(_on_level_up)

	_on_xp_changed(GameManager.player_xp, GameManager.player_level)
	_on_currency_changed(GameManager.player_currency)

func _on_hp_changed(hp: float, max_hp: float) -> void:
	if _hp_bar:
		var target_w := clampf(hp / max_hp, 0.0, 1.0) * 62.0
		var tw := create_tween()
		tw.tween_property(_hp_bar, "size:x", target_w, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		if hp / max_hp < 0.3:
			_hp_bar.color = Color(0.95, 0.12, 0.12)
		elif hp / max_hp < 0.6:
			_hp_bar.color = Color(0.90, 0.55, 0.15)
		else:
			_hp_bar.color = Color(0.80, 0.20, 0.20)
	# damage vignette flash
	if _damage_vignette and hp < max_hp:
		var flash := create_tween()
		flash.tween_property(_damage_vignette, "color:a", 0.25, 0.08)
		flash.tween_property(_damage_vignette, "color:a", 0.0, 0.35).set_ease(Tween.EASE_OUT)

func _on_energy_changed(energy: float) -> void:
	if _en_bar:
		var target_w := clampf(energy / 100.0, 0.0, 1.0) * 62.0
		var tw := create_tween()
		tw.tween_property(_en_bar, "size:x", target_w, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_xp_changed(xp: float, level: int) -> void:
	if _xp_bar:
		var target_w := clampf(xp / GameManager.xp_to_next_level, 0.0, 1.0) * 62.0
		var tw := create_tween()
		tw.tween_property(_xp_bar, "size:x", target_w, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if _level_label:
		_level_label.text = "LV %d" % level

func _on_currency_changed(amount: int) -> void:
	if _currency_label:
		_currency_label.text = "$%d" % amount

func _on_level_up(new_level: int) -> void:
	if _level_label:
		_level_label.text = "LV %d" % new_level
		_level_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	_show_floating_text("LEVEL UP! LV %d" % new_level, Color(0.2, 0.9, 0.4), Vector2(640, 300))
	AudioLib2D.play("success")
	await get_tree().create_timer(2.0).timeout
	if _level_label:
		_level_label.add_theme_color_override("font_color", Color(0.4, 0.75, 0.95))

func _show_floating_text(text: String, color: Color, pos: Vector2) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = pos
	lbl.z_index = 20
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_layer.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", pos.y - 30.0, 1.0)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	tw.tween_callback(lbl.free)

func _setup_rain() -> void:
	_rain_particles = CPUParticles2D.new()
	_rain_particles.emitting = true
	_rain_particles.amount = 60
	_rain_particles.lifetime = 1.2
	_rain_particles.direction = Vector2(0.2, 1)
	_rain_particles.spread = 8.0
	_rain_particles.initial_velocity_min = 180.0
	_rain_particles.initial_velocity_max = 300.0
	_rain_particles.gravity = Vector2(0, 80)
	_rain_particles.scale_amount_min = 0.15
	_rain_particles.scale_amount_max = 0.4
	_rain_particles.color = Color(0.45, 0.55, 0.75, 0.25)
	_rain_particles.z_index = 100
	add_child(_rain_particles)

func _update_rain() -> void:
	if _rain_particles:
		_rain_particles.global_position = player.global_position if player else Vector2(640, 360)
		_rain_particles.emitting = not _interior_zone

func _setup_lighting() -> void:
	light_layer = CanvasLayer.new()
	light_layer.name = "Lighting"
	light_layer.layer = -1
	add_child(light_layer)

	var darkness := ColorRect.new()
	darkness.color = Color(0.02, 0.02, 0.05, 0.35)
	darkness.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	darkness.name = "Darkness"
	light_layer.add_child(darkness)

	var vignette := ColorRect.new()
	vignette.color = Color(0.0, 0.0, 0.0, 0.4)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.name = "Vignette"
	light_layer.add_child(vignette)

	# damage vignette layer (red overlay, hidden by default)
	_damage_vignette = ColorRect.new()
	_damage_vignette.color = Color(0.6, 0.0, 0.0, 0.0)
	_damage_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_damage_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage_vignette.z_index = 1
	_damage_vignette.name = "DamageVignette"
	light_layer.add_child(_damage_vignette)

func _clock_intro() -> void:
	# Show intro hint as floating text instead of blocking dialogue
	_show_floating_text("Welcome, Hunter. Press Q to open Blood Clock.", Color(0.9, 0.85, 0.5), Vector2(640, 200))

func _on_clock_interaction() -> void:
	if _clock_ui_open:
		_close_clock_ui()
		return
	_open_clock_ui()

func _open_clock_ui() -> void:
	_clock_ui_open = true
	_clock_ui_layer = CanvasLayer.new()
	_clock_ui_layer.layer = 50
	add_child(_clock_ui_layer)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.02, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_clock_ui_layer.add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(700, 500)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_clock_ui_layer.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "BLOOD CLOCK"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.85, 0.25, 0.20))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var clock_img := Sprite2D.new()
	if ResourceLoader.exists("res://assets/2d/clock/clock_face.png"):
		clock_img.texture = load("res://assets/2d/clock/clock_face.png")
	clock_img.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clock_img.scale = Vector2(3, 3)
	vbox.add_child(clock_img)

	var sections := ["CONTRACT", "TARGET", "TIMELINE", "MEMORY", "EQUIPMENT", "MAP"]
	for section in sections:
		var btn := Button.new()
		btn.text = section
		ButtonStyleHelper.apply(btn, Vector2(200, 30))
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_clock_section.bind(section))
		vbox.add_child(btn)

	var ctx := GameManager.get_clock_dialogue_context()
	var dialogue: String = clock_ai.respond_to("time", ctx)
	var dial_label := Label.new()
	dial_label.text = dialogue
	dial_label.add_theme_font_size_override("font_size", 14)
	dial_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.75))
	dial_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(dial_label)

	if GameManager.active_contract.is_empty():
		var contract_btn := Button.new()
		contract_btn.text = ">> ACCEPT CONTRACT <<"
		ButtonStyleHelper.apply(contract_btn, Vector2(200, 30))
		contract_btn.add_theme_font_size_override("font_size", 18)
		contract_btn.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
		contract_btn.pressed.connect(_accept_contract)
		vbox.add_child(contract_btn)
	else:
		var info := Label.new()
		info.text = "Active Contract: %s\nTarget: %s\nEra: %s\nLocation: %s" % [
			GameManager.active_contract.get("id", "???"),
			GameManager.active_contract.get("target_name", "???"),
			GameManager.active_contract.get("era", "???"),
			GameManager.active_contract.get("location", "???")
		]
		info.add_theme_font_size_override("font_size", 14)
		info.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
		vbox.add_child(info)

	var close_btn := Button.new()
	close_btn.text = "[ESC] Close"
	ButtonStyleHelper.apply(close_btn)
	close_btn.pressed.connect(_close_clock_ui)
	vbox.add_child(close_btn)

func _close_clock_ui() -> void:
	_clock_ui_open = false
	if _clock_ui_layer:
		_clock_ui_layer.queue_free()
		_clock_ui_layer = null

func _on_clock_section(section: String) -> void:
	var ctx := GameManager.get_clock_dialogue_context()
	match section:
		"CONTRACT":
			var dial: String = clock_ai.respond_to("who", ctx)
			_show_dialogue("BLOOD CLOCK", dial)
		"TARGET":
			var dial: String = clock_ai.respond_to("target", ctx)
			_show_dialogue("BLOOD CLOCK", dial)
		"TIMELINE":
			var dial: String = clock_ai.respond_to("when", ctx)
			_show_dialogue("BLOOD CLOCK", dial)
		"MEMORY":
			var dial: String = clock_ai.respond_to("you", ctx)
			_show_dialogue("BLOOD CLOCK", dial)
		"EQUIPMENT":
			var equip := GameManager.current_equipment
			_show_dialogue("BLOOD CLOCK", "Weapon: %s\nArmor: %s\nTool: %s" % [
				equip.get("weapon", "none"), equip.get("armor", "none"), equip.get("tool", "none")])
		"MAP":
			_show_dialogue("BLOOD CLOCK", "You are in the city district. Current era: %s." % current_era)

func _accept_contract() -> void:
	var ContractSystemClass = preload("res://contracts/contract_system.gd")
	var contracts: Array = ContractSystemClass.get_available_contracts()
	if contracts.is_empty():
		_show_dialogue("BLOOD CLOCK", "No contracts available. Complete current objectives first.")
		return
	var contract: Dictionary = contracts[0]
	GameManager.start_new_contract(contract)
	_contract_active = true
	_target_name = contract.get("target_name", "???")
	_target_found = false
	_target_defeated = false

	var target_positions := [Vector2(50, 8), Vector2(55, 10), Vector2(48, 12)]
	_target_pos = target_positions[randi() % target_positions.size()] * T

	_objective_label.text = "CONTRACT: Find and neutralize %s" % _target_name

	var msg := "Contract accepted.\n\nTARGET: %s\nERA: %s\nLOCATION: %s\n\n%s" % [
		contract.target_name, contract.era, contract.location,
		clock_ai.respond_to("who", GameManager.get_clock_dialogue_context())]
	_show_dialogue("BLOOD CLOCK", msg)
	_close_clock_ui()
	_spawn_contract_target()

func _show_dialogue(speaker: String, text: String) -> void:
	if _dialogue_layer:
		_dialogue_layer.queue_free()

	_dialogue_layer = CanvasLayer.new()
	_dialogue_layer.layer = 40
	add_child(_dialogue_layer)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.02, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue_layer.add_child(dim)

	var box := PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(500, 200)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	_dialogue_layer.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	box.add_child(vbox)

	var speaker_label := Label.new()
	speaker_label.text = speaker
	speaker_label.add_theme_font_size_override("font_size", 14)
	speaker_label.add_theme_color_override("font_color", Color(0.5, 0.85, 0.7))
	vbox.add_child(speaker_label)

	var text_label := Label.new()
	text_label.text = text
	text_label.add_theme_font_size_override("font_size", 13)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_label.custom_minimum_size = Vector2(450, 0)
	text_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.85))
	vbox.add_child(text_label)

	var hint := Label.new()
	hint.text = "[Press any key or click to close]"
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	vbox.add_child(hint)

	await get_tree().create_timer(0.5).timeout
	var closed := false
	var tree := get_tree()
	if tree:
		var close_fn := func(event: InputEvent):
			if not closed:
				var should_close := false
				if event is InputEventKey and event.pressed:
					should_close = true
				elif event is InputEventMouseButton and event.pressed:
					should_close = true
				if should_close:
					closed = true
					if _dialogue_layer:
						_dialogue_layer.queue_free()
						_dialogue_layer = null
		if tree.has_signal("input_fired"):
			tree.input_fired.connect(close_fn)
		await tree.create_timer(8.0).timeout
		if not closed and tree.has_signal("input_fired") and close_fn.is_valid():
			tree.input_fired.disconnect(close_fn)
	if not closed and _dialogue_layer:
		_dialogue_layer.queue_free()
		_dialogue_layer = null

func _on_player_died() -> void:
	_objective_label.text = "YOU DIED"
	_objective_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.15))
	var existing := get_node_or_null("DeathOverlay")
	if existing:
		existing.queue_free()
	var death_layer := CanvasLayer.new()
	death_layer.name = "DeathOverlay"
	death_layer.layer = 55
	add_child(death_layer)
	# Game over background image
	var go_img := TextureRect.new()
	if ResourceLoader.exists("res://assets/2d/screens/game_over.png"):
		go_img.texture = load("res://assets/2d/screens/game_over.png")
		go_img.stretch_mode = TextureRect.STRETCH_SCALE
		go_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		death_layer.add_child(go_img)
	var death_dim := ColorRect.new()
	death_dim.color = Color(0.10, 0.0, 0.0, 0.50)
	death_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_layer.add_child(death_dim)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	death_layer.add_child(vbox)

	var death_label := Label.new()
	death_label.text = "YOU DIED"
	death_label.add_theme_font_size_override("font_size", 56)
	death_label.add_theme_color_override("font_color", Color(0.9, 0.15, 0.10))
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.z_index = 2
	death_label.modulate.a = 0.0
	vbox.add_child(death_label)

	var elapsed_s := int(Time.get_ticks_msec() / 1000.0)
	var time_str := "%dm %02ds" % [elapsed_s / 60, elapsed_s % 60]
	var stats_text := "Level %d  ·  $%d  ·  %d Kills  ·  %s" % [GameManager.player_level, GameManager.player_currency, _kill_count, time_str]
	var stats_label := Label.new()
	stats_label.text = stats_text
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.modulate.a = 0.0
	vbox.add_child(stats_label)

	# staggered fade-in
	var death_tw := create_tween()
	death_tw.tween_property(death_label, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)
	death_tw.tween_property(stats_label, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)

	var btn_box := HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 30)
	vbox.add_child(btn_box)

	var restart_btn := Button.new()
	restart_btn.text = "RESTART"
	ButtonStyleHelper.apply(restart_btn, Vector2(160, 40))
	restart_btn.pressed.connect(_restart_game)
	btn_box.add_child(restart_btn)

	var quit_btn := Button.new()
	quit_btn.text = "MAIN MENU"
	ButtonStyleHelper.apply(quit_btn, Vector2(160, 40))
	quit_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/2d/start_screen.tscn"))
	btn_box.add_child(quit_btn)

func _toggle_pause() -> void:
	# Don't unpause via shortcut if settings UI is open on top
	if _paused and _is_pause_settings_open():
		return
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		_show_pause_menu()
	else:
		_hide_pause_menu()

func _is_pause_settings_open() -> bool:
	if not _pause_layer:
		return false
	for child in _pause_layer.get_children():
		if child.name == "PauseSettings" and child.visible:
			return true
	return false

func _show_pause_menu() -> void:
	if _pause_layer:
		return
	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 60
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_layer)
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.02, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_layer.add_child(dim)
	if ResourceLoader.exists("res://assets/2d/screens/pause.png"):
		var bg_img := TextureRect.new()
		bg_img.texture = load("res://assets/2d/screens/pause.png")
		bg_img.stretch_mode = TextureRect.STRETCH_SCALE
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.modulate.a = 0.3
		_pause_layer.add_child(bg_img)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(520, 480)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_pause_layer.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	scroll.add_child(box)
	var title := Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.85, 0.9, 0.85))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sep := HSeparator.new()
	box.add_child(sep)
	var ctrl_header := Label.new()
	ctrl_header.text = "CONTROLS"
	ctrl_header.add_theme_font_size_override("font_size", 12)
	ctrl_header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	box.add_child(ctrl_header)
	if Engine.has_singleton("InputManager") or has_node("/root/InputManager"):
		for action in InputManager.ACTIONS:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			box.add_child(row)
			var name_lbl := Label.new()
			name_lbl.text = InputManager.get_display_name(action)
			name_lbl.custom_minimum_size = Vector2(120, 0)
			name_lbl.add_theme_font_size_override("font_size", 11)
			name_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.65))
			row.add_child(name_lbl)
			var key_lbl := Label.new()
			key_lbl.text = InputManager.get_current_binding(action)
			key_lbl.add_theme_font_size_override("font_size", 11)
			key_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5))
			row.add_child(key_lbl)
	var sep2 := HSeparator.new()
	box.add_child(sep2)
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	box.add_child(btn_row)

	var resume_btn := Button.new()
	resume_btn.text = "RESUME"
	ButtonStyleHelper.apply(resume_btn, Vector2(140, 32))
	resume_btn.pressed.connect(_toggle_pause)
	var esc_shortcut := Shortcut.new()
	var esc_event := InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_shortcut.events = [esc_event]
	resume_btn.shortcut = esc_shortcut
	resume_btn.shortcut_feedback = false
	btn_row.add_child(resume_btn)

	var settings_btn := Button.new()
	settings_btn.text = "SETTINGS"
	ButtonStyleHelper.apply(settings_btn, Vector2(140, 32))
	settings_btn.pressed.connect(func():
		# Unpause game but keep pause menu visible behind settings
		get_tree().paused = false
		var SettingsUILoad = preload("res://ui/settings_ui.gd")
		var s := SettingsUILoad.new()
		s.name = "PauseSettings"
		_pause_layer.add_child(s)
		s._opened_from_pause = true
		s.open()
		s.visibility_changed.connect(func():
			if not s.visible:
				s.queue_free()
				# Re-pause after settings closes
				if _paused and not get_tree().paused:
					get_tree().paused = true)
	)
	btn_row.add_child(settings_btn)

	var menu_btn := Button.new()
	menu_btn.text = "MAIN MENU"
	ButtonStyleHelper.apply(menu_btn, Vector2(140, 32))
	menu_btn.pressed.connect(func():
		_toggle_pause()
		get_tree().change_scene_to_file("res://scenes/2d/start_screen.tscn")
	)
	btn_row.add_child(menu_btn)

func _hide_pause_menu() -> void:
	if _pause_layer:
		_pause_layer.queue_free()
		_pause_layer = null

func _update_combo_hud(delta: float) -> void:
	if not player or not player.has_method("get_combo_count"):
		return
	var combo: int = player.get_combo_count()
	if combo <= 0:
		# fade out combo display
		if _combo_label and _combo_label.visible:
			_combo_flash = maxf(0.0, _combo_flash - delta * 4.0)
			if _combo_flash <= 0.0:
				_combo_label.visible = false
				_combo_bg.visible = false
				_combo_timer_label.visible = false
			else:
				_combo_label.modulate.a = _combo_flash
		return

	# show combo
	_combo_flash = 1.0
	_combo_label.visible = true
	_combo_bg.visible = true
	_combo_timer_label.visible = true
	_combo_label.modulate.a = 1.0

	# combo text: x2, x3, etc.
	_combo_label.text = "x%d COMBO" % (combo + 1)

	# color scales with combo: yellow → orange → red → purple
	var colors := [
		Color(1.0, 0.85, 0.2),   # x2 - yellow
		Color(1.0, 0.6, 0.15),   # x3 - orange
		Color(1.0, 0.25, 0.15),  # x4+ - red
	]
	_combo_label.add_theme_color_override("font_color", colors[mini(combo - 1, colors.size() - 1)])

	# font size scales with combo
	var base_size := 30
	var combo_size := base_size + combo * 4
	_combo_label.add_theme_font_size_override("font_size", mini(combo_size, 52))

	# combo timer bar (visual countdown)
	var combo_timer_val: float = player._combo_timer if player.get("_combo_timer") != null else 0.0
	var timer_ratio: float = combo_timer_val / 0.6  # COMBO_WINDOW
	var bar_w := 140.0 * clampf(timer_ratio, 0.0, 1.0)
	_combo_bg.size.x = bar_w
	var bar_color: Color = _combo_label.get_theme_color("font_color")
	_combo_bg.color = Color(bar_color.r, bar_color.g, bar_color.b, 0.3)

	# punch-in scale animation
	var target_scale := 1.0 + combo * 0.08
	_combo_label.scale = Vector2(target_scale, target_scale)
	_combo_label.pivot_offset = _combo_label.get_minimum_size() / 2

	# glow effect on new hits
	if _combo_flash >= 0.9:
		_combo_label.modulate = Color(1.3, 1.3, 1.5)  # white-blue flash
	else:
		_combo_label.modulate = Color.WHITE


func _process(_delta: float) -> void:
	_update_rain()

	_update_civilians(_delta)

	_check_contract_target()

	_update_combo_hud(_delta)

	if player and _detection_indicator:
		var alerting := false
		for e in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(e):
				continue
			if not e.has_method("get"):
				continue
			var s = e.get("state")
			if s == null:
				continue
			var S = e.get("State")
			if not S is Dictionary:
				continue
			for key in ["ALERT", "CHASE", "ATTACK", "CASTING", "SHOOTING", "CHARGE"]:
				if S.has(key) and s == S[key]:
					alerting = true
					break
			if alerting:
				break
		_detection_indicator.visible = alerting
		_detection_indicator.text = "!! DETECTED !!" if alerting else ""

	if _contract_active and _target_npc and is_instance_valid(_target_npc) and player:
		var to_target: Vector2 = _target_npc.global_position - player.global_position
		var dist := to_target.length()
		if dist > 30.0:
			var angle := to_target.angle()
			var arrow_char := "→"
			if angle > -PI / 4 and angle <= PI / 4:
				arrow_char = "→"
			elif angle > PI / 4 and angle <= 3 * PI / 4:
				arrow_char = "↓"
			elif angle > -3 * PI / 4 and angle <= -PI / 4:
				arrow_char = "↑"
			else:
				arrow_char = "←"
			_target_arrow.text = "%s %dm" % [arrow_char, int(dist / 16.0)]
			_target_arrow.visible = true
			var screen_center := Vector2(640, 360)
			var offset_dir := to_target.normalized()
			_target_arrow.position = screen_center + offset_dir * 280
			_target_arrow.position.x = clampf(_target_arrow.position.x, 10, 1220)
			_target_arrow.position.y = clampf(_target_arrow.position.y, 10, 680)
		else:
			_target_arrow.text = "★"
			_target_arrow.visible = true
			_target_arrow.position = Vector2(640, 10)
	elif _target_arrow:
		_target_arrow.visible = false

	if _minimap_ui and player:
		var enemies := get_tree().get_nodes_in_group("enemies")
		var npcs := get_tree().get_nodes_in_group("npcs")
		_minimap_ui.update_minimap(player.global_position, enemies, npcs)

	if _ambient_manager and player:
		_ambient_manager.update(_delta, player.global_position, current_era)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if _clock_ui_open:
					_close_clock_ui()
				elif _inventory_ui and _inventory_ui.visible:
					_inventory_ui.close()
				elif _shop_ui and _shop_ui.visible:
					_shop_ui.close()
				elif _timeline_ui and _timeline_ui.visible:
					_timeline_ui.close()
				else:
					_toggle_pause()
			KEY_R:
				if not player.get("alive"):
					_restart_game()
			KEY_E:
				if player and player.get("alive"):
					_try_interact_or_door()
			KEY_I:
				if player and player.get("alive"):
					if _inventory_ui:
						if _inventory_ui.visible:
							_inventory_ui.close()
						else:
							_inventory_ui.open()
			KEY_T:
				if _timeline_ui and GameManager.can_act():
					if _timeline_ui.visible:
						_timeline_ui.close()
					else:
						_timeline_ui.open()



func _try_door_interaction() -> void:
	if _interior_zone:
		_interior_zone = false
		player.global_position = _interior_exit_pos
		AudioLib2D.play("door")
		return
	var tile_pos := Vector2i(int(player.global_position.x / T), int(player.global_position.y / T))
	for offset in [Vector2i(0, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var check: Vector2i = tile_pos + offset
		if _door_positions.has(check):
			_interior_exit_pos = player.global_position
			player.global_position = _door_positions[check]
			_interior_zone = true
			AudioLib2D.play("door")
			return

func _spawn_contract_target() -> void:
	if _target_npc and is_instance_valid(_target_npc):
		_target_npc.queue_free()
	var npc := _make_npc(_target_pos, _target_name, Color(0.75, 0.25, 0.20))
	npc.set_meta("interact_text", "Confront %s" % _target_name)
	npc.set_meta("is_target", true)
	add_child(npc)
	_target_npc = npc
	_target_found = true
	_objective_label.text = "CONTRACT: Eliminate %s — use compass ↑↓←→" % _target_name
	if _contract_type_label:
		_contract_type_label.text = "TYPE: %s" % GameManager.active_contract.get("type", "KILL_TARGET")

func _on_enemy_killed(enemy: Node2D) -> void:
	_kill_count += 1
	if _kill_label:
		_kill_label.text = "KILLS: %d" % _kill_count
	GameManager.add_clock_memory("player_decisions", {"type": "enemy_killed", "name": enemy.name})

	# Loot drop
	_spawn_loot_drop(enemy.global_position, enemy.enemy_type if enemy.has("enemy_type") else "guard")

	# Kill streak tracking
	_combo_kill_streak += 1
	_combo_kill_total += 1
	if _combo_kill_streak >= 3:
		var streak_bonus := _combo_kill_streak * 5
		GameManager.add_currency(streak_bonus)
		_show_floating_text("KILL STREAK x%d! +$%d" % [_combo_kill_streak, streak_bonus], Color(1.0, 0.5, 0.1), Vector2(640, 140))
		AudioLib2D.play("success")
	# Cancel old streak timer and set new one
	if _streak_timer != null:
		_streak_timer.timeout.disconnect(_on_streak_timeout)
	var streak_timer := get_tree().create_timer(4.0)
	_streak_timer = streak_timer
	streak_timer.timeout.connect(_on_streak_timeout)

func _on_streak_timeout() -> void:
	_combo_kill_streak = 0
	_streak_timer = null

func _spawn_loot_drop(pos: Vector2, enemy_type: String) -> void:
	var drops: Array[Dictionary] = []
	var credits := randi_range(10, 30)
	match enemy_type:
		"heavy": credits = randi_range(25, 60)
		"fast": credits = randi_range(8, 20)
	drops.append({"type": "credits", "amount": credits, "color": Color(0.95, 0.85, 0.2)})
	if randf() < 0.30:
		drops.append({"type": "hp_potion", "amount": 1, "color": Color(0.9, 0.2, 0.2)})
	drops.append({"type": "xp", "amount": randf_range(5.0, 15.0), "color": Color(0.3, 0.7, 0.95)})
	for drop in drops:
		var pickup := Area2D.new()
		pickup.position = pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		pickup.collision_layer = 0
		pickup.collision_mask = 2
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 6.0
		col.shape = shape
		pickup.add_child(col)
		var dot := Sprite2D.new()
		var dot_img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
		for y in range(6):
			for x in range(6):
				if Vector2(x - 2.5, y - 2.5).length() <= 2.5:
					dot_img.set_pixel(x, y, drop["color"])
		dot.texture = ImageTexture.create_from_image(dot_img)
		dot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		dot.z_index = 3
		pickup.add_child(dot)
		var bob_tw := create_tween().set_loops()
		bob_tw.tween_property(dot, "position:y", -3.0, 0.4).set_trans(Tween.TRANS_SINE)
		bob_tw.tween_property(dot, "position:y", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
		var drop_color: Color = drop["color"]
		var drop_type: String = drop["type"]
		var drop_amount: float = drop["amount"]
		pickup.body_entered.connect(func(body):
			if body.is_in_group("player") and body.has_method("take_damage"):
				match drop_type:
					"credits": GameManager.add_currency(int(drop_amount))
					"hp_potion":
						if "hp" in body and "max_hp" in body:
							body.hp = minf(body.max_hp, body.hp + 25.0)
							body.hp_changed.emit(body.hp, body.max_hp)
					"xp": GameManager.add_xp(drop_amount)
				AudioLib2D.play("pickup")
				_show_floating_text("+%s" % drop_type.replace("_", " ").to_upper(), drop_color, pickup.global_position - Vector2(0, 20))
				if is_instance_valid(pickup):
					pickup.free()
		)
		get_parent().add_child(pickup)
		var despawn := get_tree().create_timer(12.0)
		despawn.timeout.connect(func():
			if is_instance_valid(pickup):
				pickup.free()
		)


func _check_contract_target() -> void:
	if not _contract_active or _target_defeated:
		return
	var contract_type: String = GameManager.active_contract.get("type", "KILL_TARGET")
	match contract_type:
		"KILL_TARGET":
			if _target_npc == null or not is_instance_valid(_target_npc):
				_target_defeated = true
				_objective_label.text = "CONTRACT COMPLETE! Return to base."
				_objective_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.3))
				GameManager.complete_contract({"kills": _kill_count})
				AudioLib2D.play("success")
				clock_ai.trust_level += 10
		"KILL_N":
			var target_kills: int = GameManager.active_contract.get("kill_target", 5)
			if _kill_count >= target_kills:
				_target_defeated = true
				_objective_label.text = "CONTRACT COMPLETE! Killed %d/%d." % [_kill_count, target_kills]
				_objective_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.3))
				GameManager.complete_contract({"kills": _kill_count})
				AudioLib2D.play("success")
			else:
				_objective_label.text = "KILL %d/%d enemies" % [_kill_count, target_kills]
		"REACH":
			var reach_pos: Vector2 = GameManager.active_contract.get("reach_position", Vector2(32, 2) * T)
			if player and player.global_position.distance_to(reach_pos) < 32.0:
				_target_defeated = true
				_objective_label.text = "CONTRACT COMPLETE! Location reached."
				_objective_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.3))
				GameManager.complete_contract({"kills": _kill_count})
				AudioLib2D.play("success")
		"SURVIVE":
			var survive_time: float = GameManager.active_contract.get("survive_seconds", 60.0)
			if not _survive_timer_active:
				_survive_timer_active = true
				_survive_remaining = survive_time
			if _survive_remaining > 0.0:
				_survive_remaining -= get_process_delta_time()
				_objective_label.text = "SURVIVE: %.0fs remaining" % maxf(0.0, _survive_remaining)
			if _survive_remaining <= 0.0:
				_target_defeated = true
				_survive_timer_active = false
				_objective_label.text = "CONTRACT COMPLETE! Survived the onslaught!"
				_objective_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.3))
				GameManager.complete_contract({"kills": _kill_count})
				AudioLib2D.play("success")

func _show_contract_list() -> void:
	var contracts := ContractSystem.get_available_contracts()
	if contracts.is_empty():
		_show_dialogue("CONTRACT BOARD", "No contracts available.")
		return
	GameManager.set_game_state(GameManager.GameState.CONTRACT_BOARD)
	AudioLib2D.play("clock_open")
	if _dialogue_layer:
		_dialogue_layer.queue_free()
	_dialogue_layer = CanvasLayer.new()
	_dialogue_layer.layer = 50
	add_child(_dialogue_layer)
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.02, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dialogue_layer.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(550, 400)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_dialogue_layer.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)
	var title := Label.new()
	title.text = "CONTRACT BOARD"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	for contract in contracts:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_lbl := Label.new()
		name_lbl.text = "%s [%s]" % [contract.get("target_name", "???"), contract.get("type", "???")]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
		info_box.add_child(name_lbl)
		var desc_lbl := Label.new()
		desc_lbl.text = contract.get("target_desc", "")
		desc_lbl.add_theme_font_size_override("font_size", 10)
		desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		info_box.add_child(desc_lbl)
		var reward: Dictionary = contract.get("reward", {})
		var reward_lbl := Label.new()
		reward_lbl.text = "Reward: $%d  XP: %d" % [reward.get("credits", 0), int(reward.get("xp", 0))]
		reward_lbl.add_theme_font_size_override("font_size", 10)
		reward_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.5))
		info_box.add_child(reward_lbl)
		row.add_child(info_box)
		var accept_btn := Button.new()
		accept_btn.text = "ACCEPT"
		accept_btn.custom_minimum_size = Vector2(80, 28)
		var c_id: String = contract.get("id", "")
		accept_btn.pressed.connect(_on_accept_contract_from_board.bind(c_id))
		row.add_child(accept_btn)
		vbox.add_child(row)
	var close_btn := Button.new()
	close_btn.text = "[ESC] Close"
	close_btn.pressed.connect(_close_contract_board)
	vbox.add_child(close_btn)

func _on_accept_contract_from_board(contract_id: String) -> void:
	var contract := ContractSystem.get_contract_by_id(contract_id)
	if contract.is_empty():
		return
	GameManager.start_new_contract(contract)
	_contract_active = true
	_target_name = contract.get("target_name", "???")
	var contract_type: String = contract.get("type", "KILL_TARGET")
	match contract_type:
		"KILL_TARGET":
			var target_positions := [Vector2(50, 8), Vector2(55, 10), Vector2(48, 12)]
			_target_pos = target_positions[randi() % target_positions.size()] * T
			_spawn_contract_target()
			_objective_label.text = "CONTRACT: Eliminate %s" % _target_name
		"KILL_N":
			_kill_count = 0
			_objective_label.text = "CONTRACT: Kill %d enemies" % contract.get("kill_target", 5)
		"REACH":
			_target_pos = Vector2(32, 2) * T
			_objective_label.text = "CONTRACT: Reach the clock tower"
		"SURVIVE":
			_survive_timer_active = false
			_survive_remaining = contract.get("survive_seconds", 60.0)
			_kill_count = 0
			_objective_label.text = "CONTRACT: Survive for %d seconds" % int(contract.get("survive_seconds", 60.0))
		"SURVIVE":
			_objective_label.text = "CONTRACT: Survive for %ds" % int(contract.get("survive_seconds", 60))
	_objective_label.add_theme_color_override("font_color", Color(0.90, 0.85, 0.50))
	if _contract_type_label:
		_contract_type_label.text = "TYPE: %s" % contract_type
	_close_contract_board()
	AudioLib2D.play("success")

func _close_contract_board() -> void:
	if _dialogue_layer:
		_dialogue_layer.queue_free()
		_dialogue_layer = null
	GameManager.set_game_state(GameManager.GameState.EXPLORING)

func _on_era_selected(era_id: String) -> void:
	GameManager.start_time_travel(era_id)

func _on_travel_started(from_era: String, to_era: String) -> void:
	_travel_overlay = CanvasLayer.new()
	_travel_overlay.layer = 100
	add_child(_travel_overlay)
	_travel_flash = ColorRect.new()
	_travel_flash.color = Color(0.0, 0.0, 0.0, 0.0)
	_travel_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_travel_overlay.add_child(_travel_flash)
	var tw := create_tween()
	tw.tween_property(_travel_flash, "color:a", 1.0, 0.5)
	tw.tween_callback(_do_era_transition.bind(to_era))

func _do_era_transition(era_id: String) -> void:
	EraSpawner.clear_era_content(self)
	EraEnvironment.apply_era_theme(self, era_id)
	var enemies := EraSpawner.spawn_enemies_for_era(era_id, self)
	for e in enemies:
		e.enemy_died.connect(_on_enemy_killed)
	EraSpawner.spawn_npcs_for_era(era_id, self)
	var tm := _make_npc(Vector2(32, 28) * T, "Time Machine", Color(0.3, 0.6, 0.9))
	tm.set_meta("interact_text", "Use Time Machine")
	tm.set_meta("is_time_machine", true)
	tm.set_meta("dialogue", "Select a destination era.")
	add_child(tm)
	GameManager.complete_time_travel(era_id)
	if _travel_flash:
		var tw2 := create_tween()
		tw2.tween_property(_travel_flash, "color:a", 0.0, 0.5)
		tw2.tween_callback(_cleanup_travel_overlay)

func _cleanup_travel_overlay() -> void:
	if _travel_overlay:
		_travel_overlay.queue_free()
		_travel_overlay = null
		_travel_flash = null
	_spawn_boss_for_era()

func _spawn_boss_for_era() -> void:
	var era_id := GameManager.current_era
	var boss_data := BossData.get_boss_for_era(era_id)
	if boss_data.is_empty():
		return
	var boss_id: String = boss_data.get("id", "")
	if GameManager.is_boss_defeated(boss_id):
		return
	var BossBaseClass = preload("res://ai/boss_base.gd")
	var boss: CharacterBody2D = BossBaseClass.new()
	boss.setup(boss_data)
	boss.position = Vector2(55 + randi_range(-5, 5), 15 + randi_range(-3, 3)) * T
	boss.boss_died.connect(_on_boss_defeated)
	add_child(boss)

func _on_boss_defeated(boss_id: String) -> void:
	GameManager.defeat_boss(boss_id)
	_show_floating_text("BOSS DEFEATED: %s" % boss_id.replace("_", " ").to_upper(), Color(0.9, 0.7, 0.2), Vector2(512, 300))
	GameManager._check_paradox_triggers("defeat_boss_%s" % boss_id)
	AudioLib2D.play("boss_defeated")

func _on_travel_completed(era: String) -> void:
	if _objective_label:
		var era_info := EraData.get_era(era)
		_objective_label.text = "Explore %s — %s" % [era_info.get("name", "???"), era_info.get("description", "")]
		_objective_label.add_theme_color_override("font_color", Color(0.90, 0.85, 0.50))
	AudioLib2D.play("time_travel")

func _restart_game() -> void:
	get_tree().reload_current_scene()


func start_dialogue_for_npc(npc: Node2D) -> void:
	var npc_name: String = npc.get_meta("npc_name", npc.name)
	var dialogue_id: String = DialogueData.NPC_DIALOGUES.get(npc_name, "")
	if dialogue_id != "":
		_dialogue_ui.start_dialogue(dialogue_id)
		GameManager.record_dialogue(npc_name)
		if _tutorial_ui and _tutorial_ui.is_active():
			_tutorial_ui.trigger("first_dialogue")
	else:
		var dlg: String = npc.get_meta("dialogue", "")
		if dlg != "":
			_dialogue_ui.start_dialogue("")
			_show_dialogue(npc_name, dlg)
		else:
			_show_dialogue(npc_name, "...")


func _on_secret_found(secret: Dictionary) -> void:
	var name: String = secret.get("name", "Secret")
	var desc: String = secret.get("description", "")
	_show_floating_text("FOUND: %s" % name, Color(1.0, 0.85, 0.2), Vector2(640, 180))
	if _objective_label:
		_objective_label.text = "%s — %s" % [name, desc]
		_objective_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))

func _on_location_discovered(location: Dictionary) -> void:
	var name: String = location.get("name", "Location")
	var desc: String = location.get("description", "")
	_show_floating_text("DISCOVERED: %s" % name, Color(0.4, 0.8, 0.6), Vector2(640, 160))
	AudioLib2D.play("pickup")


func _try_interact_or_door() -> void:
	for obj in get_tree().get_nodes_in_group("interactable"):
		if player.global_position.distance_to(obj.global_position) < 24.0:
			if _tutorial_ui and _tutorial_ui.is_active():
				_tutorial_ui.trigger("first_interact")
			if obj.get_meta("is_trader", false):
				if _shop_ui:
					_shop_ui.open()
					if _tutorial_ui and _tutorial_ui.is_active():
						_tutorial_ui.trigger("first_shop")
				return
			if obj.get_meta("is_contract_board", false):
				_show_contract_list()
				if _tutorial_ui and _tutorial_ui.is_active():
					_tutorial_ui.trigger("first_contract")
				return
			if obj.get_meta("is_time_machine", false):
				if _era_selection_ui:
					_era_selection_ui.open()
					if _tutorial_ui and _tutorial_ui.is_active():
						_tutorial_ui.trigger("first_time_machine")
				return
			var dlg: String = obj.get_meta("dialogue", "")
			if dlg != "":
				start_dialogue_for_npc(obj)
				return
	_try_door_interaction()

# === NEW MECHANICS TUTORIAL HANDLERS ===

var _swap_tracker: Dictionary = {}  # track first weapon swap

func _on_combo_reached(count: int) -> void:
	if _tutorial_ui and _tutorial_ui.is_active() and count >= 2:
		_tutorial_ui.trigger("combo_reached_2")

func _on_dash_attack_performed() -> void:
	if _tutorial_ui and _tutorial_ui.is_active():
		_tutorial_ui.trigger("first_dash_attack")

func _on_weapon_changed(new_weapon: String) -> void:
	if not _swap_tracker.has(new_weapon):
		_swap_tracker[new_weapon] = true
		if _tutorial_ui and _tutorial_ui.is_active():
			_tutorial_ui.trigger("first_weapon_swap")

func _on_status_effect_applied(effect: String, _duration: float) -> void:
	if _tutorial_ui and _tutorial_ui.is_active():
		_tutorial_ui.trigger("first_status_effect")

func _on_achievement_unlocked(achievement: Dictionary) -> void:
	var name: String = achievement.get("name", "Achievement")
	var desc: String = achievement.get("description", "")
	_show_floating_text("ACHIEVEMENT: %s" % name, Color(1.0, 0.85, 0.2), Vector2(640, 250))
	AudioLib2D.play("success")
