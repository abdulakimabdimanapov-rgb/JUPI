extends RefCounted
class_name EraSpawner


const T := 16

static var ENEMY_TYPES := {
	"guard": {"hp": 50.0, "damage": 12.0, "speed": 45.0, "chase_speed": 75.0, "detection": 90.0, "attack_cd": 1.0, "xp": 25.0, "color": Color(0.5, 0.35, 0.3)},
	"dumbler": {"hp": 150.0, "damage": 25.0, "speed": 25.0, "chase_speed": 35.0, "detection": 80.0, "attack_cd": 2.0, "xp": 50.0, "color": Color(0.45, 0.35, 0.25)},
	"sniper": {"hp": 30.0, "damage": 35.0, "speed": 35.0, "chase_speed": 50.0, "detection": 150.0, "attack_cd": 2.5, "xp": 40.0, "color": Color(0.3, 0.35, 0.4)},
	"mage": {"hp": 40.0, "damage": 20.0, "speed": 40.0, "chase_speed": 55.0, "detection": 130.0, "attack_cd": 1.8, "xp": 45.0, "color": Color(0.4, 0.2, 0.5)},
	"fast": {"hp": 25.0, "damage": 8.0, "speed": 70.0, "chase_speed": 110.0, "detection": 100.0, "attack_cd": 0.6, "xp": 20.0, "color": Color(0.3, 0.45, 0.3)},
	"heavy": {"hp": 100.0, "damage": 20.0, "speed": 30.0, "chase_speed": 50.0, "detection": 70.0, "attack_cd": 1.5, "xp": 40.0, "color": Color(0.45, 0.40, 0.35)},
	"soldier": {"hp": 45.0, "damage": 10.0, "speed": 40.0, "chase_speed": 65.0, "detection": 80.0, "attack_cd": 1.2, "xp": 30.0, "color": Color(0.55, 0.45, 0.3)},
	"hunter": {"hp": 35.0, "damage": 15.0, "speed": 55.0, "chase_speed": 90.0, "detection": 110.0, "attack_cd": 0.8, "xp": 35.0, "color": Color(0.4, 0.5, 0.3)},
	"heavy_knight": {"hp": 120.0, "damage": 25.0, "speed": 25.0, "chase_speed": 40.0, "detection": 60.0, "attack_cd": 2.0, "xp": 50.0, "color": Color(0.4, 0.38, 0.35)},
	"drone": {"hp": 20.0, "damage": 10.0, "speed": 80.0, "chase_speed": 130.0, "detection": 120.0, "attack_cd": 0.5, "xp": 30.0, "color": Color(0.2, 0.5, 0.8)},
	"android": {"hp": 80.0, "damage": 18.0, "speed": 50.0, "chase_speed": 80.0, "detection": 95.0, "attack_cd": 0.8, "xp": 45.0, "color": Color(0.3, 0.4, 0.6)},
	"plasma_guard": {"hp": 150.0, "damage": 30.0, "speed": 35.0, "chase_speed": 55.0, "detection": 80.0, "attack_cd": 1.8, "xp": 60.0, "color": Color(0.1, 0.6, 0.9)},
	"mutant": {"hp": 60.0, "damage": 22.0, "speed": 60.0, "chase_speed": 95.0, "detection": 100.0, "attack_cd": 0.7, "xp": 50.0, "color": Color(0.5, 0.3, 0.2)},
	"rogue_machine": {"hp": 100.0, "damage": 28.0, "speed": 45.0, "chase_speed": 70.0, "detection": 85.0, "attack_cd": 1.0, "xp": 60.0, "color": Color(0.3, 0.3, 0.35)},
	"elite_hunter": {"hp": 200.0, "damage": 35.0, "speed": 40.0, "chase_speed": 65.0, "detection": 75.0, "attack_cd": 1.5, "xp": 80.0, "color": Color(0.4, 0.2, 0.15)},

	# === ERA ENEMIES: PAST (Medieval) ===
	"paladin": {"hp": 90.0, "damage": 18.0, "speed": 35.0, "chase_speed": 55.0, "detection": 85.0, "attack_cd": 1.2, "xp": 55.0, "color": Color(0.7, 0.65, 0.3), "era": "past"},
	"necromancer": {"hp": 35.0, "damage": 25.0, "speed": 30.0, "chase_speed": 45.0, "detection": 140.0, "attack_cd": 2.0, "xp": 60.0, "color": Color(0.3, 0.15, 0.4), "era": "past"},
	"skeleton": {"hp": 30.0, "damage": 10.0, "speed": 50.0, "chase_speed": 80.0, "detection": 90.0, "attack_cd": 0.8, "xp": 20.0, "color": Color(0.85, 0.82, 0.75), "era": "past"},
	"draugr": {"hp": 80.0, "damage": 22.0, "speed": 25.0, "chase_speed": 40.0, "detection": 70.0, "attack_cd": 1.8, "xp": 45.0, "color": Color(0.35, 0.4, 0.35), "era": "past"},

	# === ERA ENEMIES: FUTURE (Cyberpunk) ===
	"mech_suit": {"hp": 180.0, "damage": 35.0, "speed": 30.0, "chase_speed": 45.0, "detection": 90.0, "attack_cd": 1.5, "xp": 70.0, "color": Color(0.25, 0.35, 0.5), "era": "future"},
	"hacker_drone": {"hp": 15.0, "damage": 8.0, "speed": 90.0, "chase_speed": 140.0, "detection": 130.0, "attack_cd": 0.4, "xp": 25.0, "color": Color(0.0, 0.9, 0.6), "era": "future"},
	"sentinel": {"hp": 120.0, "damage": 28.0, "speed": 40.0, "chase_speed": 60.0, "detection": 100.0, "attack_cd": 1.0, "xp": 55.0, "color": Color(0.15, 0.4, 0.7), "era": "future"},
	"ai_overlord": {"hp": 250.0, "damage": 40.0, "speed": 25.0, "chase_speed": 35.0, "detection": 160.0, "attack_cd": 2.5, "xp": 100.0, "color": Color(0.0, 0.7, 1.0), "era": "future"},

	# === ERA ENEMIES: COLLAPSED (Ruins) ===
	"abomination": {"hp": 150.0, "damage": 30.0, "speed": 35.0, "chase_speed": 55.0, "detection": 80.0, "attack_cd": 1.5, "xp": 65.0, "color": Color(0.55, 0.25, 0.2), "era": "collapsed"},
	"swarm": {"hp": 10.0, "damage": 5.0, "speed": 85.0, "chase_speed": 120.0, "detection": 110.0, "attack_cd": 0.3, "xp": 10.0, "color": Color(0.4, 0.35, 0.2), "era": "collapsed"},
	"stalker": {"hp": 70.0, "damage": 28.0, "speed": 55.0, "chase_speed": 90.0, "detection": 120.0, "attack_cd": 0.8, "xp": 50.0, "color": Color(0.3, 0.2, 0.15), "era": "collapsed"},
	"war_golem": {"hp": 300.0, "damage": 45.0, "speed": 20.0, "chase_speed": 30.0, "detection": 60.0, "attack_cd": 2.5, "xp": 120.0, "color": Color(0.4, 0.35, 0.3), "era": "collapsed"},
}

static func get_enemy_stats(enemy_type: String, era_id: String) -> Dictionary:
	var base: Dictionary = ENEMY_TYPES.get(enemy_type, ENEMY_TYPES["guard"]).duplicate()
	var modifiers := EraData.apply_era_modifiers(base["hp"], base["damage"], era_id)
	base["hp"] = modifiers["hp"]
	base["damage"] = modifiers["damage"]
	base["speed"] *= modifiers["speed_mult"]
	base["chase_speed"] *= modifiers["speed_mult"]
	base["xp"] *= modifiers["xp_mult"]
	return base

static func get_enemy_color(enemy_type: String) -> Color:
	return ENEMY_TYPES.get(enemy_type, ENEMY_TYPES["guard"]).get("color", Color(0.5, 0.5, 0.5))

static func spawn_enemies_for_era(era_id: String, world: Node2D) -> Array:
	var era := EraData.get_era(era_id)
	var enemy_types: Array = era.get("enemies", ["guard"])
	var enemies_spawned: Array = []
	var enemy_script = preload("res://ai/enemy_base.gd")

	var spawn_configs := [
		{"pos": Vector2(48, 8), "patrol": [Vector2(48, 8), Vector2(55, 8), Vector2(55, 13), Vector2(48, 13)]},
		{"pos": Vector2(10, 40), "patrol": [Vector2(10, 40), Vector2(15, 40), Vector2(15, 45), Vector2(10, 45)]},
		{"pos": Vector2(60, 28), "patrol": [Vector2(60, 28), Vector2(68, 28), Vector2(68, 30)]},
		{"pos": Vector2(60, 40), "patrol": [Vector2(60, 40), Vector2(70, 40), Vector2(70, 50), Vector2(60, 50)]},
		{"pos": Vector2(20, 42), "patrol": [Vector2(20, 42), Vector2(28, 42), Vector2(28, 48), Vector2(20, 48)]},
	]

	for i in range(min(spawn_configs.size(), enemy_types.size())):
		var config: Dictionary = spawn_configs[i]
		var etype: String = enemy_types[i % enemy_types.size()]
		var stats := get_enemy_stats(etype, era_id)

		var e := enemy_script.new()
		e.name = "%s_%d" % [etype.capitalize(), i]
		e.enemy_type = etype
		e.patrol_points = config["patrol"]
		e.position = config["pos"] * T
		e.hp = stats["hp"]
		e.max_hp = stats["hp"]
		e.damage = stats["damage"]
		e.speed = stats["speed"]
		e.chase_speed = stats["chase_speed"]
		e.detection_range = stats["detection"]
		e.attack_cd = stats["attack_cd"]
		e.xp_reward = stats["xp"]
		world.add_child(e)
		enemies_spawned.append(e)

	return enemies_spawned

static func spawn_npcs_for_era(era_id: String, world: Node2D) -> Array:
	var era := EraData.get_era(era_id)
	var npc_data: Array = era.get("npcs", [])
	var npcs_spawned: Array = []

	var npc_positions := [
		Vector2(15, 16),
		Vector2(25, 27),
		Vector2(42, 27),
	]

	for i in range(min(npc_data.size(), npc_positions.size())):
		var nd: Dictionary = npc_data[i]
		var pos: Vector2 = npc_positions[i] * T
		var npc_name: String = nd.get("name", "NPC")
		var color: Color = nd.get("color", Color(0.5, 0.5, 0.5))
		var dialogue: String = nd.get("dialogue", "")

		var npc := StaticBody2D.new()
		npc.name = npc_name
		npc.position = pos
		npc.collision_layer = 8
		npc.collision_mask = 1
		npc.set_meta("dialogue", dialogue)
		npc.set_meta("interact_text", "Talk to %s" % npc_name)

		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 5.0
		col.shape = shape
		npc.add_child(col)

		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		for x in range(5, 11): for y in range(0, 4): img.set_pixel(x, y, color.lightened(0.1))
		for x in range(4, 12): for y in range(4, 11): img.set_pixel(x, y, color)
		for x in range(5, 7): for y in range(11, 16): img.set_pixel(x, y, color.darkened(0.15))
		for x in range(9, 11): for y in range(11, 16): img.set_pixel(x, y, color.darkened(0.15))

		var spr := Sprite2D.new()
		spr.texture = ImageTexture.create_from_image(img)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		npc.add_child(spr)

		var lbl := Label.new()
		lbl.text = npc_name
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.position = Vector2(-12, -18)
		lbl.modulate = Color(0.8, 0.85, 0.8, 0.8)
		npc.add_child(lbl)

		npc.add_to_group("interactable")
		world.add_child(npc)
		npcs_spawned.append(npc)

	return npcs_spawned

static func clear_era_content(world: Node2D) -> void:
	for e in world.get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	for child in world.get_children():
		if child is StaticBody2D and child.is_in_group("interactable"):
			child.queue_free()
		if child is CharacterBody2D and child.is_in_group("civilians"):
			child.queue_free()

static func apply_era_colors(world: Node2D, era_id: String) -> void:
	var era := EraData.get_era(era_id)
	if world.has_method("get") and "ground_layer" in world:
		pass
