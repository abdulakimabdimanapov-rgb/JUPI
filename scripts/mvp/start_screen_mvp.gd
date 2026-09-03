extends Control

var _title_label: Label
var _subtitle_label: Label
var _time := 0.0


func _ready():
	_build_ui()


func _build_ui():
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative top line
	var top_line := ColorRect.new()
	top_line.color = Color(0.6, 0.15, 0.1, 0.4)
	top_line.position = Vector2(0, 0)
	top_line.size = Vector2(1280, 2)
	add_child(top_line)

	# Title
	_title_label = Label.new()
	_title_label.text = "J U P I"
	_title_label.add_theme_font_size_override("font_size", 72)
	_title_label.add_theme_color_override("font_color", Color(0.85, 0.2, 0.15))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.set_anchors_preset(Control.PRESET_CENTER)
	_title_label.position = Vector2(0, -100)
	_title_label.position.x = -_title_label.size.x / 2.0
	add_child(_title_label)

	# Subtitle
	_subtitle_label = Label.new()
	_subtitle_label.text = "S T A R D A N C E"
	_subtitle_label.add_theme_font_size_override("font_size", 22)
	_subtitle_label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.set_anchors_preset(Control.PRESET_CENTER)
	_subtitle_label.position = Vector2(0, -30)
	_subtitle_label.position.x = -_subtitle_label.size.x / 2.0
	add_child(_subtitle_label)

	# Separator line
	var sep := ColorRect.new()
	sep.color = Color(0.3, 0.25, 0.2, 0.3)
	sep.size = Vector2(200, 1)
	sep.set_anchors_preset(Control.PRESET_CENTER)
	sep.position = Vector2(-100, 10)
	add_child(sep)

	# Description
	var desc := Label.new()
	desc.text = "A time-travel action RPG\nTravel between eras. Change history. Face the consequences."
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.40, 0.42, 0.48))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.set_anchors_preset(Control.PRESET_CENTER)
	desc.position = Vector2(0, 40)
	add_child(desc)

	# Start button
	var start_btn := Button.new()
	start_btn.text = "▶  START GAME"
	start_btn.custom_minimum_size = Vector2(220, 48)
	start_btn.set_anchors_preset(Control.PRESET_CENTER)
	start_btn.position = Vector2(-110, 110)
	start_btn.pressed.connect(_on_start)
	add_child(start_btn)

	# Controls section
	var controls_title := Label.new()
	controls_title.text = "CONTROLS"
	controls_title.add_theme_font_size_override("font_size", 11)
	controls_title.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
	controls_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_title.set_anchors_preset(Control.PRESET_CENTER)
	controls_title.position = Vector2(0, 185)
	add_child(controls_title)

	var controls := Label.new()
	controls.text = "WASD Move  ·  Space Dodge  ·  LMB Attack\nE Interact  ·  Q Blood Clock  ·  1-2 Weapons"
	controls.add_theme_font_size_override("font_size", 11)
	controls.add_theme_color_override("font_color", Color(0.30, 0.32, 0.36))
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.set_anchors_preset(Control.PRESET_CENTER)
	controls.position = Vector2(0, 205)
	add_child(controls)

	# Version
	var version := Label.new()
	version.text = "MVP v0.2"
	version.add_theme_font_size_override("font_size", 9)
	version.add_theme_color_override("font_color", Color(0.2, 0.2, 0.22))
	version.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	version.position = Vector2(-80, -30)
	add_child(version)


func _process(delta: float):
	_time += delta
	if _title_label:
		_title_label.modulate = Color(1.0, 0.95 + sin(_time * 1.5) * 0.05, 0.9 + sin(_time * 2.0) * 0.1)
	if _subtitle_label:
		_subtitle_label.modulate = Color(1.0, 1.0, 1.0, 0.6 + sin(_time * 1.2) * 0.15)


func _on_start():
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://scenes/2d/game_mvp.tscn")


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_on_start()
