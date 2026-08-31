extends Control

var _idx = 0
var _items: Array[Label] = []
var _transitioning := false
var _settings_open := false
var _settings_panel: PanelContainer
var _settings_dim: ColorRect
var _cursor: Label
var _start_time := 0.0

# Menu elements (hidden when settings open)
var _menu_title: Label
var _menu_subtitle: Label
var _menu_glow: Label
var _menu_hint: Label
var _menu_version: Label

# settings state (mirrors in-game settings_ui.gd)
var _settings := {
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"brightness": 1.0,
	"show_damage_numbers": true,
	"show_minimap": true,
	"screen_shake": true,
	"auto_save": true,
	"fullscreen": false,
	"vsync": true,
}

func _ready():
	_load_settings()
	_apply_settings()

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var clock_spr := Sprite2D.new()
	if ResourceLoader.exists("res://assets/2d/clock/clock_face.png"):
		clock_spr.texture = load("res://assets/2d/clock/clock_face.png")
	else:
		clock_spr.texture = _placeholder_clock()
	clock_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clock_spr.scale = Vector2(5, 5)
	clock_spr.position = Vector2(640, 200)
	clock_spr.modulate = Color(0.6, 0.5, 0.3, 0.3)
	add_child(clock_spr)
	var t := create_tween().set_loops()
	t.tween_property(clock_spr, "modulate:a", 0.15, 2.0).set_trans(Tween.TRANS_SINE)
	t.tween_property(clock_spr, "modulate:a", 0.35, 2.0).set_trans(Tween.TRANS_SINE)

	var rain := CPUParticles2D.new()
	rain.emitting = true
	rain.amount = 80
	rain.lifetime = 1.5
	rain.direction = Vector2(0.3, 1)
	rain.spread = 10.0
	rain.initial_velocity_min = 200.0
	rain.initial_velocity_max = 350.0
	rain.gravity = Vector2(0, 100)
	rain.scale_amount_min = 0.2
	rain.scale_amount_max = 0.5
	rain.color = Color(0.5, 0.6, 0.8, 0.3)
	rain.position = Vector2(640, -20)
	rain.z_index = 1
	add_child(rain)

	# firefly / dust particles
	var fireflies := CPUParticles2D.new()
	fireflies.emitting = true
	fireflies.amount = 20
	fireflies.lifetime = 4.0
	fireflies.direction = Vector2(0, -0.3)
	fireflies.spread = 180.0
	fireflies.initial_velocity_min = 5.0
	fireflies.initial_velocity_max = 15.0
	fireflies.gravity = Vector2(0, -8)
	fireflies.scale_amount_min = 0.15
	fireflies.scale_amount_max = 0.4
	fireflies.color = Color(0.95, 0.85, 0.4, 0.5)
	fireflies.position = Vector2(640, 500)
	fireflies.z_index = 1
	add_child(fireflies)

	_menu_title = Label.new()
	_menu_title.text = "JUPI"
	_menu_title.add_theme_font_size_override("font_size", 96)
	_menu_title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.25))
	_menu_title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_menu_title.anchor_top = 0.10
	_menu_title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_title.z_index = 2
	add_child(_menu_title)

	_menu_subtitle = Label.new()
	_menu_subtitle.text = "THE BLOOD CLOCK"
	_menu_subtitle.add_theme_font_size_override("font_size", 22)
	_menu_subtitle.add_theme_color_override("font_color", Color(0.65, 0.40, 0.30))
	_menu_subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_menu_subtitle.anchor_top = 0.24
	_menu_subtitle.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_subtitle.z_index = 2
	add_child(_menu_subtitle)

	# breathing glow behind title
	_menu_glow = Label.new()
	_menu_glow.text = "JUPI"
	_menu_glow.add_theme_font_size_override("font_size", 96)
	_menu_glow.add_theme_color_override("font_color", Color(0.95, 0.75, 0.20, 0.25))
	_menu_glow.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_menu_glow.anchor_top = 0.10
	_menu_glow.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_glow.z_index = 1
	add_child(_menu_glow)
	var glow_tw := create_tween().set_loops()
	glow_tw.tween_property(_menu_glow, "modulate:a", 0.1, 2.5).set_trans(Tween.TRANS_SINE)
	glow_tw.tween_property(_menu_glow, "modulate:a", 0.45, 2.5).set_trans(Tween.TRANS_SINE)

	# Title entrance animation
	_menu_title.modulate.a = 0.0
	_menu_title.position.y -= 20
	_menu_subtitle.modulate.a = 0.0
	var entrance := create_tween()
	entrance.tween_property(_menu_title, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)
	entrance.parallel().tween_property(_menu_title, "position:y", _menu_title.position.y + 20, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	entrance.tween_property(_menu_subtitle, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)

	# Menu items: NEW GAME, CONTINUE (locked), SETTINGS, QUIT
	var cursor := Label.new()
	cursor.text = ">"
	cursor.add_theme_font_size_override("font_size", 24)
	cursor.add_theme_color_override("font_color", Color(0.95, 0.80, 0.25))
	cursor.z_index = 3
	cursor.visible = false
	add_child(cursor)
	# breathing glow on cursor
	var cursor_tw := create_tween().set_loops()
	cursor_tw.tween_property(cursor, "modulate:a", 0.4, 0.8).set_trans(Tween.TRANS_SINE)
	cursor_tw.tween_property(cursor, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

	for item in [["NEW GAME", true], ["CONTINUE", false], ["SETTINGS", true], ["QUIT", true]]:
		var l := Label.new()
		if item[1]:
			l.text = item[0]
		else:
			l.text = item[0] + "  (coming soon)"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 22 if item[1] else 14)
		l.set_anchors_preset(Control.PRESET_CENTER)
		l.anchor_top = 0.50 + _items.size() * 0.08
		l.anchor_bottom = l.anchor_top
		l.grow_horizontal = Control.GROW_DIRECTION_BOTH
		l.mouse_filter = Control.MOUSE_FILTER_STOP if item[1] else Control.MOUSE_FILTER_IGNORE
		l.z_index = 2
		l.modulate.a = 0.0
		if item[1]:
			l.gui_input.connect(_on_item_input.bind(_items.size()))
		add_child(l)
		_items.append(l)
	# stagger menu entrance
	for i in range(_items.size()):
		var tw := create_tween()
		tw.tween_interval(0.4 + i * 0.08)
		tw.tween_property(_items[i], "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)

	_cursor = cursor
	_refresh()

	_menu_hint = Label.new()
	_menu_hint.text = "W/S — select    ENTER — confirm    Mouse — click"
	_menu_hint.add_theme_font_size_override("font_size", 14)
	_menu_hint.modulate = Color(1, 1, 1, 0.35)
	_menu_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_menu_hint.anchor_top = 0.92
	_menu_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_hint.z_index = 2
	add_child(_menu_hint)

	_menu_version = Label.new()
	_menu_version.text = "v1.0"
	_menu_version.add_theme_font_size_override("font_size", 10)
	_menu_version.modulate = Color(1, 1, 1, 0.20)
	_menu_version.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_menu_version.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_menu_version.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_menu_version.z_index = 2
	add_child(_menu_version)

# ─── SOUND HELPERS ─────────────────────────────────────────────────────────────

func _play_menu(cue: String) -> void:
	var vol := remap(_settings["sfx_volume"], 0.0, 1.0, -30.0, -4.0)
	AudioLib2D.play(cue, vol)


# ─── SETTINGS PANEL ───────────────────────────────────────────────────────────

func _open_settings():
	_settings_open = true
	_play_menu("menu_open")

	# Hide all main menu elements
	_menu_title.visible = false
	_menu_subtitle.visible = false
	_menu_glow.visible = false
	_menu_hint.visible = false
	_menu_version.visible = false
	_cursor.visible = false
	for item in _items:
		item.visible = false

	# Full-screen dim overlay (blocks clicks behind)
	_settings_dim = ColorRect.new()
	_settings_dim.color = Color(0.0, 0.0, 0.02, 0.85)
	_settings_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_dim.z_index = 19
	_settings_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_dim)

	# Settings panel — larger, centered
	_settings_panel = PanelContainer.new()
	_settings_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_settings_panel.custom_minimum_size = Vector2(560, 500)
	_settings_panel.size = Vector2(560, 500)
	_settings_panel.z_index = 20
	_settings_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_settings_panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.04, 0.09, 0.97)
	style.border_color = Color(0.6, 0.5, 0.2)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	_settings_panel.add_theme_stylebox_override("panel", style)
	add_child(_settings_panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_settings_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	# ── Title ──
	var title := Label.new()
	title.text = "⚙  SETTINGS"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.85, 0.80, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# ── Sound section ──
	var sound_header := Label.new()
	sound_header.text = "SOUND"
	sound_header.add_theme_font_size_override("font_size", 13)
	sound_header.add_theme_color_override("font_color", Color(0.55, 0.65, 0.80))
	vbox.add_child(sound_header)

	var music_row := HBoxContainer.new()
	music_row.add_theme_constant_override("separation", 10)
	vbox.add_child(music_row)

	var music_label := Label.new()
	music_label.text = "Music"
	music_label.custom_minimum_size = Vector2(80, 0)
	music_label.add_theme_font_size_override("font_size", 13)
	music_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	music_row.add_child(music_label)

	var music_slider := HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = _settings["music_volume"]
	music_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_slider.value_changed.connect(func(val): _settings["music_volume"] = val)
	music_row.add_child(music_slider)

	var music_pct := Label.new()
	music_pct.text = "%d%%" % int(_settings["music_volume"] * 100)
	music_pct.custom_minimum_size = Vector2(40, 0)
	music_pct.add_theme_font_size_override("font_size", 12)
	music_pct.add_theme_color_override("font_color", Color(0.60, 0.62, 0.60))
	music_pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	music_row.add_child(music_pct)
	music_slider.value_changed.connect(func(val): music_pct.text = "%d%%" % int(val * 100))

	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 10)
	vbox.add_child(sfx_row)

	var sfx_label := Label.new()
	sfx_label.text = "SFX"
	sfx_label.custom_minimum_size = Vector2(80, 0)
	sfx_label.add_theme_font_size_override("font_size", 13)
	sfx_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	sfx_row.add_child(sfx_label)

	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = _settings["sfx_volume"]
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_slider.value_changed.connect(func(val): _settings["sfx_volume"] = val)
	sfx_row.add_child(sfx_slider)

	var sfx_pct := Label.new()
	sfx_pct.text = "%d%%" % int(_settings["sfx_volume"] * 100)
	sfx_pct.custom_minimum_size = Vector2(40, 0)
	sfx_pct.add_theme_font_size_override("font_size", 12)
	sfx_pct.add_theme_color_override("font_color", Color(0.60, 0.62, 0.60))
	sfx_pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sfx_row.add_child(sfx_pct)
	sfx_slider.value_changed.connect(func(val): sfx_pct.text = "%d%%" % int(val * 100))

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# ── Display section ──
	var display_header := Label.new()
	display_header.text = "DISPLAY"
	display_header.add_theme_font_size_override("font_size", 13)
	display_header.add_theme_color_override("font_color", Color(0.55, 0.65, 0.80))
	vbox.add_child(display_header)

	var fullscreen_row := HBoxContainer.new()
	fullscreen_row.add_theme_constant_override("separation", 12)
	vbox.add_child(fullscreen_row)

	var fs_label := Label.new()
	fs_label.text = "Fullscreen"
	fs_label.custom_minimum_size = Vector2(120, 0)
	fs_label.add_theme_font_size_override("font_size", 13)
	fs_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	fullscreen_row.add_child(fs_label)

	var fs_toggle := CheckBox.new()
	fs_toggle.button_pressed = _settings["fullscreen"]
	fs_toggle.text = ""
	fs_toggle.toggled.connect(func(val): _settings["fullscreen"] = val)
	fullscreen_row.add_child(fs_toggle)

	var fs_hint := Label.new()
	fs_hint.text = "(applied on restart)"
	fs_hint.add_theme_font_size_override("font_size", 10)
	fs_hint.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	fullscreen_row.add_child(fs_hint)

	var vsync_row := HBoxContainer.new()
	vsync_row.add_theme_constant_override("separation", 12)
	vbox.add_child(vsync_row)

	var vsync_label := Label.new()
	vsync_label.text = "VSync"
	vsync_label.custom_minimum_size = Vector2(120, 0)
	vsync_label.add_theme_font_size_override("font_size", 13)
	vsync_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	vsync_row.add_child(vsync_label)

	var vsync_toggle := CheckBox.new()
	vsync_toggle.button_pressed = _settings["vsync"]
	vsync_toggle.text = ""
	vsync_toggle.toggled.connect(func(val): _settings["vsync"] = val)
	vsync_row.add_child(vsync_toggle)

	var sep3 := HSeparator.new()
	vbox.add_child(sep3)

	# ── Gameplay section ──
	var gameplay_header := Label.new()
	gameplay_header.text = "GAMEPLAY"
	gameplay_header.add_theme_font_size_override("font_size", 13)
	gameplay_header.add_theme_color_override("font_color", Color(0.55, 0.65, 0.80))
	vbox.add_child(gameplay_header)

	var shake_row := HBoxContainer.new()
	shake_row.add_theme_constant_override("separation", 12)
	vbox.add_child(shake_row)

	var shake_label := Label.new()
	shake_label.text = "Screen Shake"
	shake_label.custom_minimum_size = Vector2(120, 0)
	shake_label.add_theme_font_size_override("font_size", 13)
	shake_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	shake_row.add_child(shake_label)

	var shake_toggle := CheckBox.new()
	shake_toggle.button_pressed = _settings["screen_shake"]
	shake_toggle.text = ""
	shake_toggle.toggled.connect(func(val): _settings["screen_shake"] = val)
	shake_row.add_child(shake_toggle)

	var dmg_row := HBoxContainer.new()
	dmg_row.add_theme_constant_override("separation", 12)
	vbox.add_child(dmg_row)

	var dmg_label := Label.new()
	dmg_label.text = "Damage Numbers"
	dmg_label.custom_minimum_size = Vector2(120, 0)
	dmg_label.add_theme_font_size_override("font_size", 13)
	dmg_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	dmg_row.add_child(dmg_label)

	var dmg_toggle := CheckBox.new()
	dmg_toggle.button_pressed = _settings["show_damage_numbers"]
	dmg_toggle.text = ""
	dmg_toggle.toggled.connect(func(val): _settings["show_damage_numbers"] = val)
	dmg_row.add_child(dmg_toggle)

	var autosave_row := HBoxContainer.new()
	autosave_row.add_theme_constant_override("separation", 12)
	vbox.add_child(autosave_row)

	var autosave_label := Label.new()
	autosave_label.text = "Auto Save"
	autosave_label.custom_minimum_size = Vector2(120, 0)
	autosave_label.add_theme_font_size_override("font_size", 13)
	autosave_label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.70))
	autosave_row.add_child(autosave_label)

	var autosave_toggle := CheckBox.new()
	autosave_toggle.button_pressed = _settings["auto_save"]
	autosave_toggle.text = ""
	autosave_toggle.toggled.connect(func(val): _settings["auto_save"] = val)
	autosave_row.add_child(autosave_toggle)

	var sep4 := HSeparator.new()
	vbox.add_child(sep4)

	# ── Buttons ──
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 30)
	vbox.add_child(btn_row)

	var apply_btn := Button.new()
	apply_btn.text = "APPLY"
	apply_btn.custom_minimum_size = Vector2(120, 36)
	apply_btn.pressed.connect(_apply_and_save)
	ButtonStyleHelper.apply(apply_btn, Vector2(120, 36))
	btn_row.add_child(apply_btn)

	var reset_btn := Button.new()
	reset_btn.text = "RESET DEFAULT"
	reset_btn.custom_minimum_size = Vector2(140, 36)
	reset_btn.pressed.connect(_reset_defaults)
	ButtonStyleHelper.apply(reset_btn, Vector2(140, 36))
	btn_row.add_child(reset_btn)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(100, 36)
	back_btn.pressed.connect(_close_settings)
	ButtonStyleHelper.apply(back_btn, Vector2(100, 36))
	btn_row.add_child(back_btn)

	var esc_hint := Label.new()
	esc_hint.text = "[ESC] to close"
	esc_hint.add_theme_font_size_override("font_size", 10)
	esc_hint.add_theme_color_override("font_color", Color(0.40, 0.40, 0.42))
	esc_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(esc_hint)


func _close_settings():
	_settings_open = false
	_play_menu("menu_back")
	if _settings_panel:
		_settings_panel.queue_free()
		_settings_panel = null
	if _settings_dim:
		_settings_dim.queue_free()
		_settings_dim = null

	# Show all main menu elements
	_menu_title.visible = true
	_menu_subtitle.visible = true
	_menu_glow.visible = true
	_menu_hint.visible = true
	_menu_version.visible = true
	for item in _items:
		item.visible = true
	_refresh()


func _apply_and_save():
	_play_menu("menu_select")
	_save_settings()
	_apply_settings()


func _reset_defaults():
	_play_menu("menu_select")
	_settings = {
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"brightness": 1.0,
		"show_damage_numbers": true,
		"show_minimap": true,
		"screen_shake": true,
		"auto_save": true,
		"fullscreen": false,
		"vsync": true,
	}
	_save_settings()
	_apply_settings()
	# rebuild sliders to reflect new values
	if _settings_panel:
		_close_settings()
		_open_settings()


func _apply_settings():
	# fullscreen
	if _settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# vsync
	if _settings["vsync"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _save_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_settings, "\t"))
		file.close()


func _load_settings():
	if FileAccess.file_exists("user://settings.json"):
		var file = FileAccess.open("user://settings.json", FileAccess.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(text) == OK:
				var loaded = json.data
				if loaded is Dictionary:
					for key in loaded:
						_settings[key] = loaded[key]


# ─── MENU LOGIC ───────────────────────────────────────────────────────────────

func _placeholder_clock():
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	_disc(img, 16, 16, 14.0, Color(0.20, 0.18, 0.15))
	_disc(img, 16, 16, 10.0, Color(0.30, 0.27, 0.22))
	_disc(img, 16, 16, 8.0, Color(0.85, 0.80, 0.70))
	_disc(img, 16, 16, 1.0, Color(0.80, 0.20, 0.15))
	return ImageTexture.create_from_image(img)

func _disc(img, cx, cy, r, c):
	for y in range(int(cy - r) - 1, int(cy + r) + 2):
		for x in range(int(cx - r) - 1, int(cx + r) + 2):
			if Vector2(x - cx, y - cy).length() <= r:
				if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
					img.set_pixel(x, y, c)

func _refresh():
	for i in range(_items.size()):
		_items[i].add_theme_color_override("font_color",
			Color(0.95, 0.85, 0.55) if i == _idx else Color(0.40, 0.42, 0.45))
	if _cursor and _idx < _items.size():
		_cursor.visible = true
		_cursor.position.x = _items[_idx].position.x - _items[_idx].get_minimum_size().x / 2.0 - 20
		_cursor.position.y = _items[_idx].position.y

func _unhandled_input(event):
	if _transitioning:
		return
	if _settings_open:
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				_close_settings()
				get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W, KEY_UP:
				if _idx > 0:
					_play_menu("menu_navigate")
				_idx = maxi(0, _idx - 1)
				_refresh()
			KEY_S, KEY_DOWN:
				if _idx < _items.size() - 1:
					_play_menu("menu_navigate")
				_idx = mini(_items.size() - 1, _idx + 1)
				_refresh()
			KEY_ENTER, KEY_KP_ENTER:
				_play_menu("menu_select")
				_activate(_idx)
			KEY_ESCAPE:
				get_tree().quit()

func _on_item_input(event, idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_menu("menu_select")
		_idx = idx
		_refresh()
		_activate(idx)

func _activate(idx):
	if _transitioning or _settings_open:
		return
	match idx:
		0:  # NEW GAME
			_transitioning = true
			var fade := ColorRect.new()
			fade.color = Color(0.0, 0.0, 0.0, 0.0)
			fade.set_anchors_preset(Control.PRESET_FULL_RECT)
			fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fade.z_index = 10
			add_child(fade)
			var tw := create_tween()
			tw.tween_property(fade, "color:a", 1.0, 0.5)
			tw.tween_callback(func() -> void:
				get_tree().change_scene_to_file("res://scenes/2d/game_main.tscn"))
		1:  # CONTINUE (locked)
			pass
		2:  # SETTINGS
			_play_menu("menu_open")
			_open_settings()
		3:  # QUIT
			_play_menu("menu_back")
			get_tree().quit()
