extends CanvasLayer

signal settings_changed()

var _panel: PanelContainer
var _music_slider: HSlider
var _sfx_slider: HSlider
var _show_damage_numbers: CheckBox
var _show_minimap: CheckBox
var _screen_shake: CheckBox
var _auto_save: CheckBox
var _keybind_rows: Dictionary = {}  # action -> {label, button}
var _rebind_prompt: Label
var _opened_from_pause := false
var _previous_state: int = -1

var settings = {
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
	layer = 55
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	if InputManager:
		InputManager.binding_changed.connect(_on_binding_changed)

func open():
	visible = true
	_load_settings()
	_build_ui()
	_previous_state = GameManager.current_game_state
	GameManager.set_game_state(GameManager.GameState.DIALOGUE)

func close():
	visible = false
	_save_settings()
	_apply_display_settings()
	settings_changed.emit()
	# Restore previous state or default to exploring
	if _previous_state >= 0:
		GameManager.set_game_state(_previous_state)
	else:
		GameManager.set_game_state(GameManager.GameState.EXPLORING)

func _build_ui():
	for child in get_children():
		child.queue_free()

	var dim = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.02, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			close()
	)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(500, 500)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	var title = Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# ── SOUND ──
	var sound_header = Label.new()
	sound_header.text = "SOUND"
	sound_header.add_theme_font_size_override("font_size", 13)
	sound_header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(sound_header)

	var music_row = HBoxContainer.new()
	music_row.add_theme_constant_override("separation", 8)
	vbox.add_child(music_row)
	var music_label = Label.new()
	music_label.text = "Music"
	music_label.custom_minimum_size = Vector2(80, 0)
	music_label.add_theme_font_size_override("font_size", 12)
	music_row.add_child(music_label)
	_music_slider = HSlider.new()
	_music_slider.min_value = 0.0
	_music_slider.max_value = 1.0
	_music_slider.value = settings["music_volume"]
	_music_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_music_slider.value_changed.connect(func(val): settings["music_volume"] = val)
	music_row.add_child(_music_slider)

	var sfx_row = HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 8)
	vbox.add_child(sfx_row)
	var sfx_label = Label.new()
	sfx_label.text = "SFX"
	sfx_label.custom_minimum_size = Vector2(80, 0)
	sfx_label.add_theme_font_size_override("font_size", 12)
	sfx_row.add_child(sfx_label)
	_sfx_slider = HSlider.new()
	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 1.0
	_sfx_slider.value = settings["sfx_volume"]
	_sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sfx_slider.value_changed.connect(func(val): settings["sfx_volume"] = val)
	sfx_row.add_child(_sfx_slider)

	var sep2 = HSeparator.new()
	vbox.add_child(sep2)

	# ── DISPLAY ──
	var display_header = Label.new()
	display_header.text = "DISPLAY"
	display_header.add_theme_font_size_override("font_size", 13)
	display_header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(display_header)

	var fs_row = HBoxContainer.new()
	fs_row.add_theme_constant_override("separation", 10)
	vbox.add_child(fs_row)
	var fs_label = Label.new()
	fs_label.text = "Fullscreen"
	fs_label.custom_minimum_size = Vector2(100, 0)
	fs_label.add_theme_font_size_override("font_size", 12)
	fs_row.add_child(fs_label)
	var fs_toggle = CheckBox.new()
	fs_toggle.button_pressed = settings["fullscreen"]
	fs_toggle.toggled.connect(func(val): settings["fullscreen"] = val)
	fs_row.add_child(fs_toggle)

	var vsync_row = HBoxContainer.new()
	vsync_row.add_theme_constant_override("separation", 10)
	vbox.add_child(vsync_row)
	var vsync_label = Label.new()
	vsync_label.text = "VSync"
	vsync_label.custom_minimum_size = Vector2(100, 0)
	vsync_label.add_theme_font_size_override("font_size", 12)
	vsync_row.add_child(vsync_label)
	var vsync_toggle = CheckBox.new()
	vsync_toggle.button_pressed = settings["vsync"]
	vsync_toggle.toggled.connect(func(val): settings["vsync"] = val)
	vsync_row.add_child(vsync_toggle)

	var sep3 = HSeparator.new()
	vbox.add_child(sep3)

	# ── GAMEPLAY ──
	var gp_header = Label.new()
	gp_header.text = "GAMEPLAY"
	gp_header.add_theme_font_size_override("font_size", 13)
	gp_header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(gp_header)

	_show_damage_numbers = CheckBox.new()
	_show_damage_numbers.text = "Damage Numbers"
	_show_damage_numbers.add_theme_font_size_override("font_size", 12)
	_show_damage_numbers.button_pressed = settings["show_damage_numbers"]
	_show_damage_numbers.toggled.connect(func(val): settings["show_damage_numbers"] = val)
	vbox.add_child(_show_damage_numbers)

	_screen_shake = CheckBox.new()
	_screen_shake.text = "Screen Shake"
	_screen_shake.add_theme_font_size_override("font_size", 12)
	_screen_shake.button_pressed = settings["screen_shake"]
	_screen_shake.toggled.connect(func(val): settings["screen_shake"] = val)
	vbox.add_child(_screen_shake)

	_auto_save = CheckBox.new()
	_auto_save.text = "Auto Save"
	_auto_save.add_theme_font_size_override("font_size", 12)
	_auto_save.button_pressed = settings["auto_save"]
	_auto_save.toggled.connect(func(val): settings["auto_save"] = val)
	vbox.add_child(_auto_save)

	var sep4 = HSeparator.new()
	vbox.add_child(sep4)

	# ── KEYBOARD / KEYBINDS ──
	var kb_header = Label.new()
	kb_header.text = "KEYBOARD CONTROLS"
	kb_header.add_theme_font_size_override("font_size", 13)
	kb_header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(kb_header)

	_rebind_prompt = Label.new()
	_rebind_prompt.text = ""
	_rebind_prompt.add_theme_font_size_override("font_size", 11)
	_rebind_prompt.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_rebind_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_rebind_prompt)

	_keybind_rows.clear()
	for action in InputManager.ACTIONS:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vbox.add_child(row)

		var name_lbl = Label.new()
		name_lbl.text = InputManager.get_display_name(action)
		name_lbl.custom_minimum_size = Vector2(140, 0)
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(0.7, 0.72, 0.7))
		row.add_child(name_lbl)

		var bind_btn = Button.new()
		bind_btn.text = InputManager.get_current_binding(action)
		bind_btn.custom_minimum_size = Vector2(100, 24)
		bind_btn.add_theme_font_size_override("font_size", 11)
		bind_btn.pressed.connect(_on_rebind_pressed.bind(action))
		ButtonStyleHelper.apply(bind_btn, Vector2(100, 24))
		row.add_child(bind_btn)

		_keybind_rows[action] = {"label": name_lbl, "button": bind_btn}

	var reset_btn = Button.new()
	reset_btn.text = "RESET KEYS TO DEFAULT"
	reset_btn.custom_minimum_size = Vector2(200, 28)
	reset_btn.add_theme_font_size_override("font_size", 11)
	reset_btn.pressed.connect(_on_reset_keys)
	ButtonStyleHelper.apply(reset_btn, Vector2(200, 28))
	vbox.add_child(reset_btn)

	var sep5 = HSeparator.new()
	vbox.add_child(sep5)

	var close_btn = Button.new()
	close_btn.text = "[ESC] Close"
	close_btn.pressed.connect(close)
	ButtonStyleHelper.apply(close_btn)
	vbox.add_child(close_btn)

func _on_rebind_pressed(action: String) -> void:
	_rebind_prompt.text = "Press a key for: %s (ESC to cancel)" % InputManager.get_display_name(action)
	if _keybind_rows.has(action):
		_keybind_rows[action]["button"].text = "..."
	InputManager.start_rebind(action)

func _on_binding_changed(action: String, _event: InputEvent) -> void:
	_rebind_prompt.text = ""
	# Refresh all keybind buttons
	for act in _keybind_rows:
		_keybind_rows[act]["button"].text = InputManager.get_current_binding(act)

func _on_reset_keys() -> void:
	InputManager.reset_to_defaults()
	_rebind_prompt.text = "Keys reset to defaults!"
	for act in _keybind_rows:
		_keybind_rows[act]["button"].text = InputManager.get_current_binding(act)

func _save_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))
		file.close()

func _apply_display_settings():
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if settings["vsync"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

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
						settings[key] = loaded[key]

func get_setting(key):
	return settings.get(key)

func set_setting(key, value):
	settings[key] = value

func _unhandled_input(event):
	if not visible:
		return
	# Don't handle ESC if we're rebinding
	if InputManager.is_rebinding():
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()
