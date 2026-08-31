extends RefCounted
class_name EraEnvironment


static func apply_era_theme(world: Node2D, era_id: String) -> void:
	var era := EraData.get_era(era_id)

	if "light_layer" in world and world.light_layer:
		for child in world.light_layer.get_children():
			if child.name == "Darkness":
				var bg: Color = era.get("bg_color", Color(0.04, 0.03, 0.06))
				child.color = Color(bg.r, bg.g, bg.b, 0.35)
			elif child.name == "Vignette":
				var bg: Color = era.get("bg_color", Color(0.04, 0.03, 0.06))
				child.color = Color(bg.r * 0.5, bg.g * 0.5, bg.b * 0.5, 0.4)

	if "rain_particles" in world and world._rain_particles:
		var era_id_actual: String = era.get("id", "present")
		match era_id_actual:
			"present":
				world._rain_particles.emitting = true
				world._rain_particles.color = Color(0.45, 0.55, 0.75, 0.25)
				world._rain_particles.amount = 60
			"past":
				world._rain_particles.emitting = false
			"future":
				world._rain_particles.emitting = true
				world._rain_particles.color = Color(0.2, 0.6, 0.9, 0.2)
				world._rain_particles.amount = 40
			"collapsed":
				world._rain_particles.emitting = true
				world._rain_particles.color = Color(0.6, 0.3, 0.2, 0.3)
				world._rain_particles.amount = 30

	if "_era_label" in world and world._era_label:
		world._era_label.text = "%s — %s" % [era.get("name", "???"), _get_era_time(era_id)]
		world._era_label.add_theme_color_override("font_color", era.get("accent_color", Color(0.45, 0.70, 0.55)))

	# Era-specific ambient particles
	spawn_era_ambient(world, era_id)

	# Era-specific environment decorations
	spawn_era_buildings(world, era_id)


static func spawn_era_ambient(world: Node2D, era_id: String) -> void:
	match era_id:
		"present":
			# Neon signs flicker
			var neon := CPUParticles2D.new()
			neon.emitting = true
			neon.amount = 15
			neon.lifetime = 2.0
			neon.direction = Vector2(0, -1)
			neon.spread = 30.0
			neon.gravity = Vector2(0, -5)
			neon.scale_amount_min = 0.1
			neon.scale_amount_max = 0.3
			neon.color = Color(0.9, 0.25, 0.35, 0.4)
			neon.position = Vector2(640, 400)
			neon.z_index = 8
			world.add_child(neon)

		"past":
			# Firefly particles
			var fireflies := CPUParticles2D.new()
			fireflies.emitting = true
			fireflies.amount = 20
			fireflies.lifetime = 4.0
			fireflies.direction = Vector2(0, -0.5)
			fireflies.spread = 180.0
			fireflies.gravity = Vector2(0, -3)
			fireflies.scale_amount_min = 0.05
			fireflies.scale_amount_max = 0.15
			fireflies.color = Color(0.95, 0.85, 0.3, 0.5)
			fireflies.position = Vector2(640, 360)
			fireflies.z_index = 8
			world.add_child(fireflies)

		"future":
			# Holographic data streams
			var holo := CPUParticles2D.new()
			holo.emitting = true
			holo.amount = 25
			holo.lifetime = 1.5
			holo.direction = Vector2(0, 1)
			holo.spread = 5.0
			holo.gravity = Vector2(0, 20)
			holo.scale_amount_min = 0.05
			holo.scale_amount_max = 0.1
			holo.color = Color(0.0, 0.8, 1.0, 0.3)
			holo.position = Vector2(640, -10)
			holo.z_index = 8
			world.add_child(holo)

		"collapsed":
			# Ash / embers
			var embers := CPUParticles2D.new()
			embers.emitting = true
			embers.amount = 30
			embers.lifetime = 3.0
			embers.direction = Vector2(0.3, -1)
			embers.spread = 40.0
			embers.gravity = Vector2(0, 15)
			embers.scale_amount_min = 0.05
			embers.scale_amount_max = 0.15
			embers.color = Color(0.8, 0.3, 0.1, 0.5)
			embers.position = Vector2(640, -10)
			embers.z_index = 8
			world.add_child(embers)


static func spawn_era_buildings(world: Node2D, era_id: String) -> void:
	var T := 16
	match era_id:
		"present":
			# Modern neon signs
			var signs := [
				{"pos": Vector2(8, 5) * T, "text": "HOTEL", "color": Color(0.9, 0.25, 0.35)},
				{"pos": Vector2(48, 5) * T, "text": "WORKSHOP", "color": Color(0.2, 0.6, 0.9)},
				{"pos": Vector2(52, 40) * T, "text": "BAR", "color": Color(0.9, 0.7, 0.2)},
				{"pos": Vector2(24, 44) * T, "text": "INN", "color": Color(0.3, 0.8, 0.4)},
				{"pos": Vector2(32, 2) * T, "text": "CLOCK TOWER", "color": Color(0.8, 0.6, 0.2)},
				{"pos": Vector2(65, 5) * T, "text": "ARMORY", "color": Color(0.6, 0.3, 0.2)},
			]
			for s in signs:
				var lbl := Label.new()
				lbl.text = s.text
				lbl.add_theme_font_size_override("font_size", 10)
				lbl.add_theme_color_override("font_color", s.color)
				lbl.position = s.pos
				lbl.z_index = 3
				world.add_child(lbl)
			# Traffic cones, dumpsters
			var modern_props := [
				{"pos": Vector2(20, 29) * T, "color": Color(0.9, 0.5, 0.0), "w": 4, "h": 4},
				{"pos": Vector2(50, 31) * T, "color": Color(0.9, 0.5, 0.0), "w": 4, "h": 4},
				{"pos": Vector2(40, 33) * T, "color": Color(0.2, 0.25, 0.2), "w": 8, "h": 6},
			]
			for mp in modern_props:
				var prop := ColorRect.new()
				prop.color = mp.color
				prop.position = mp.pos
				prop.size = Vector2(mp.w, mp.h)
				prop.z_index = 2
				world.add_child(prop)

		"past":
			# Medieval torches and banners
			var torches := [
				Vector2(5, 4) * T, Vector2(18, 4) * T,
				Vector2(45, 4) * T, Vector2(56, 4) * T,
				Vector2(5, 38) * T, Vector2(16, 38) * T,
			]
			for tp in torches:
				var fire := CPUParticles2D.new()
				fire.emitting = true
				fire.amount = 8
				fire.lifetime = 0.5
				fire.direction = Vector2(0, -1)
				fire.spread = 20.0
				fire.gravity = Vector2(0, -10)
				fire.scale_amount_min = 0.08
				fire.scale_amount_max = 0.2
				fire.color = Color(1.0, 0.6, 0.1, 0.7)
				fire.position = tp
				fire.z_index = 3
				world.add_child(fire)
			# Medieval banners
			var banners := [
				{"pos": Vector2(10, 3) * T, "color": Color(0.7, 0.15, 0.1)},
				{"pos": Vector2(50, 3) * T, "color": Color(0.15, 0.3, 0.6)},
			]
			for b in banners:
				var flag := ColorRect.new()
				flag.color = b.color
				flag.position = b.pos
				flag.size = Vector2(8, 14)
				flag.z_index = 3
				world.add_child(flag)

		"future":
			# Holographic displays
			var holo_signs := [
				{"pos": Vector2(8, 5) * T, "text": "CYBER INN", "color": Color(0.0, 0.8, 1.0)},
				{"pos": Vector2(48, 5) * T, "text": "TECH LAB", "color": Color(0.2, 0.6, 0.9)},
				{"pos": Vector2(52, 40) * T, "text": "NEON BAR", "color": Color(0.8, 0.0, 0.9)},
				{"pos": Vector2(32, 2) * T, "text": "TIME NEXUS", "color": Color(0.0, 1.0, 0.8)},
				{"pos": Vector2(65, 5) * T, "text": "WEAPON FORGE", "color": Color(0.9, 0.4, 0.0)},
			]
			for s in holo_signs:
				var lbl := Label.new()
				lbl.text = s.text
				lbl.add_theme_font_size_override("font_size", 10)
				lbl.add_theme_color_override("font_color", s.color)
				lbl.position = s.pos
				lbl.z_index = 3
				lbl.modulate.a = 0.7
				world.add_child(lbl)
			# Drone patrol paths
			var drones := [Vector2(30, 20) * T, Vector2(50, 25) * T, Vector2(70, 15) * T]
			for dp in drones:
				var drone_spr := Sprite2D.new()
				var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
				for x in range(6): for y in range(6):
					if Vector2(x - 2.5, y - 2.5).length() <= 2.5:
						img.set_pixel(x, y, Color(0.2, 0.5, 0.8, 0.6))
				drone_spr.texture = ImageTexture.create_from_image(img)
				drone_spr.position = dp
				drone_spr.z_index = 6
				world.add_child(drone_spr)
			# Holographic data pillars
			var pillars := [
				{"pos": Vector2(15, 15) * T, "color": Color(0.0, 0.6, 0.9)},
				{"pos": Vector2(60, 20) * T, "color": Color(0.8, 0.0, 0.9)},
				{"pos": Vector2(40, 45) * T, "color": Color(0.0, 0.9, 0.5)},
			]
			for p in pillars:
				var pillar := ColorRect.new()
				pillar.color = Color(p.color.r, p.color.g, p.color.b, 0.3)
				pillar.position = p.pos
				pillar.size = Vector2(3, 20)
				pillar.z_index = 2
				world.add_child(pillar)
			# Charging stations
			var stations := [Vector2(25, 30) * T, Vector2(55, 35) * T]
			for st in stations:
				var station := ColorRect.new()
				station.color = Color(0.1, 0.3, 0.5)
				station.position = st
				station.size = Vector2(8, 8)
				station.z_index = 2
				world.add_child(station)

		"collapsed":
			# Ruined buildings (cracks, rubble)
			var ruins := [
				{"pos": Vector2(10, 8) * T, "w": 24, "h": 16},
				{"pos": Vector2(50, 6) * T, "w": 20, "h": 14},
				{"pos": Vector2(8, 40) * T, "w": 22, "h": 12},
			]
			for r in ruins:
				var rubble := ColorRect.new()
				rubble.color = Color(0.3, 0.25, 0.2, 0.5)
				rubble.position = r.pos
				rubble.size = Vector2(r.w, r.h)
				rubble.z_index = 2
				world.add_child(rubble)
				# Crack lines
				for ci in range(3):
					var crack := ColorRect.new()
					crack.color = Color(0.15, 0.12, 0.1, 0.6)
					crack.position = r.pos + Vector2(randf_range(2, r.w - 4), randf_range(0, r.h - 2))
					crack.size = Vector2(randf_range(4, 10), 1)
					crack.z_index = 2
					world.add_child(crack)
			# Fires in ruins
			var ruin_fires := [Vector2(15, 10) * T, Vector2(55, 8) * T, Vector2(12, 42) * T]
			for rf in ruin_fires:
				var fire := CPUParticles2D.new()
				fire.emitting = true
				fire.amount = 12
				fire.lifetime = 0.6
				fire.direction = Vector2(0, -1)
				fire.spread = 25.0
				fire.gravity = Vector2(0, -15)
				fire.scale_amount_min = 0.1
				fire.scale_amount_max = 0.3
				fire.color = Color(0.9, 0.4, 0.1, 0.6)
				fire.position = rf
				fire.z_index = 3
				world.add_child(fire)

static func _get_era_time(era_id: String) -> String:
	match era_id:
		"present": return "NIGHT"
		"past": return "DUSK"
		"future": return "MIDNIGHT"
		"collapsed": return "ETERNAL TWILIGHT"
	return "UNKNOWN"

static func generate_era_tiles(era_id: String, ground_layer: TileMapLayer, map_w: int, map_h: int) -> void:
	var era := EraData.get_era(era_id)
	var ground_color: Color = era.get("ground_color", Color(0.18, 0.18, 0.20))
	var wall_color: Color = era.get("wall_color", Color(0.42, 0.32, 0.28))

	var img := Image.create(128, 80, false, Image.FORMAT_RGBA8)
	for x in range(8):
		var cell_color := ground_color.darkened(float(x) * 0.02)
		for cy in range(16):
			for cx in range(16):
				img.set_pixel(x * 16 + cx, cy, cell_color)
	for x in range(4):
		for cy in range(16):
			for cx in range(16):
				img.set_pixel(x * 16 + cx, 16 + cy, wall_color)

	var tex := ImageTexture.create_from_image(img)

	if ground_layer and ground_layer.tile_set:
		var src: TileSetAtlasSource = ground_layer.tile_set.get_source(0)
		if src:
			src.texture = tex
