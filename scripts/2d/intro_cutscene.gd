extends Control
## Cinematic intro — typewriter text that fades through story beats.

var _lines: Array[Dictionary] = [
	{"text": "The year is unknown.", "color": Color(0.6, 0.7, 0.9), "duration": 2.5},
	{"text": "The Blood Clock ticks endlessly...", "color": Color(0.9, 0.2, 0.15), "duration": 3.0},
	{"text": "Once a timepiece of creation,\nit became the instrument of unraveling.", "color": Color(0.7, 0.6, 0.5), "duration": 3.5},
	{"text": "Eras bleed into one another.\nPast, present, future — broken.", "color": Color(0.5, 0.8, 0.6), "duration": 3.0},
	{"text": "You are a Hunter.\nBound to the Clock's will.", "color": Color(0.95, 0.85, 0.3), "duration": 3.0},
	{"text": "Accept its contracts.\nTravel through time.\nRestore what was broken.", "color": Color(0.8, 0.7, 0.5), "duration": 3.5},
	{"text": "Or be consumed by the paradox.", "color": Color(0.9, 0.1, 0.1), "duration": 2.5},
]

var _current_line := 0
var _skip := false
var _label: Label
var _subtitle_label: Label
var _skip_hint: Label
var _done := false

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.01, 0.03)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Subtle vignette overlay
	var vig := ColorRect.new()
	vig.color = Color(0.0, 0.0, 0.0, 0.5)
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vig)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.set_anchors_preset(Control.PRESET_CENTER)
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	_label.custom_minimum_size = Vector2(900, 200)
	_label.add_theme_font_size_override("font_size", 28)
	_label.z_index = 2
	add_child(_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = "JUPI — THE BLOOD CLOCK"
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.set_anchors_preset(Control.PRESET_CENTER)
	_subtitle_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_subtitle_label.anchor_top = 0.82
	_subtitle_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_subtitle_label.add_theme_font_size_override("font_size", 14)
	_subtitle_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3, 0.5))
	_subtitle_label.z_index = 2
	add_child(_subtitle_label)

	_skip_hint = Label.new()
	_skip_hint.text = "Press ENTER or click to skip..."
	_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skip_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_skip_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_skip_hint.anchor_top = 0.92
	_skip_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_skip_hint.add_theme_font_size_override("font_size", 12)
	_skip_hint.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35, 0.5))
	_skip_hint.z_index = 2
	add_child(_skip_hint)

	# Fade in skip hint
	var hint_tw := create_tween().set_loops()
	hint_tw.tween_property(_skip_hint, "modulate:a", 0.15, 1.5).set_trans(Tween.TRANS_SINE)
	hint_tw.tween_property(_skip_hint, "modulate:a", 0.5, 1.5).set_trans(Tween.TRANS_SINE)

	_play_line(0)


func _play_line(idx: int) -> void:
	if idx >= _lines.size():
		_finish()
		return
	if _skip:
		_finish()
		return

	_current_line = idx
	var line_data: Dictionary = _lines[idx]
	var full_text: String = line_data["text"]
	var color: Color = line_data.get("color", Color(0.7, 0.7, 0.7))
	var dur: float = line_data.get("duration", 2.5)

	_label.add_theme_color_override("font_color", color)
	_label.modulate.a = 0.0

	# Fade in
	var fade_in := create_tween()
	fade_in.tween_property(_label, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)

	# Typewriter effect
	_label.text = ""
	var chars := full_text.length()
	var type_speed := dur / maxf(chars, 1)
	var char_idx := 0

	while char_idx < chars:
		if _skip:
			_label.text = full_text
			_finish()
			return
		_label.text = full_text.substr(0, char_idx + 1)
		char_idx += 1
		await get_tree().create_timer(type_speed).timeout

	# Hold
	await get_tree().create_timer(dur * 0.5).timeout

	# Fade out
	var fade_out := create_tween()
	fade_out.tween_property(_label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	await fade_out.finished

	_play_line(idx + 1)


func _finish() -> void:
	if _done:
		return
	_done = true
	_skip = true

	# Quick fade to black and load game
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	add_child(overlay)

	var tw := create_tween()
	tw.tween_property(overlay, "color:a", 1.0, 0.4)
	tw.tween_callback(func() -> void:
		get_tree().change_scene_to_file("res://scenes/2d/game_main.tscn")
	)


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_SPACE]:
			_skip = true
			_finish()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		_skip = true
		_finish()
		get_viewport().set_input_as_handled()
