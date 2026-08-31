extends CanvasLayer


signal tutorial_step_completed(step: int)
signal tutorial_completed()

var _tutorial: TutorialManager
var _step_label: Label
var _title_label: Label
var _text_label: Label
var _progress_label: Label
var _panel: PanelContainer
var _active := false
var _display_timer := 0.0
var _display_duration := 4.0
var _fade_alpha := 0.0

func _ready() -> void:
	layer = 42
	visible = false
	_tutorial = TutorialManager.new()

func start_tutorial() -> void:
	_active = true
	_tutorial.start()
	visible = true
	_build_ui()
	_show_current_step()

func stop_tutorial() -> void:
	_active = false
	_tutorial.stop()
	visible = false

func is_active() -> bool:
	return _active

func get_tutorial() -> TutorialManager:
	return _tutorial

func trigger(trigger_name: String) -> Dictionary:
	var result := _tutorial.trigger(trigger_name)
	if not result.is_empty():
		_show_step(result)
		tutorial_step_completed.emit(_tutorial.current_step)
		if _tutorial.is_active():
			_display_duration = result.get("duration", 4.0)
			_display_timer = 0.0
			_fade_alpha = 1.0
		else:
			_show_completion()
			tutorial_completed.emit()
	return result

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_panel.offset_top = 60
	_panel.offset_left = 250
	_panel.offset_right = 1030
	_panel.offset_bottom = 170
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.modulate.a = 0.0
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.65))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title_label)

	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 12)
	_text_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.82))
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.custom_minimum_size = Vector2(700, 0)
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_text_label)

	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 9)
	_progress_label.add_theme_color_override("font_color", Color(0.4, 0.45, 0.4))
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_progress_label)

func _show_current_step() -> void:
	var step := _tutorial.get_current_step()
	if step == TutorialManager.Step.NONE:
		return
	var data := _tutorial.get_step_data(step)
	_show_step(data)

func _show_step(data: Dictionary) -> void:
	if _title_label:
		_title_label.text = "TUTORIAL: %s" % data.get("title", "")
	if _text_label:
		_text_label.text = data.get("text", "")
	if _progress_label:
		var remaining := _tutorial.get_remaining_steps()
		_progress_label.text = "%d steps remaining" % remaining
	_display_timer = 0.0
	_fade_alpha = 1.0

func _show_completion() -> void:
	if _title_label:
		_title_label.text = "TUTORIAL COMPLETE"
		_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	if _text_label:
		_text_label.text = "You've learned all the basics. The city awaits, Hunter."
	if _progress_label:
		_progress_label.text = ""
	_display_timer = 0.0
	_display_duration = 5.0
	_fade_alpha = 1.0

func _process(delta: float) -> void:
	if not _active or _panel == null:
		return
	_display_timer += delta
	if _display_timer < 0.3:
		_fade_alpha = minf(_fade_alpha + delta / 0.3, 1.0)
	elif _display_timer > _display_duration - 0.5:
		_fade_alpha = maxf(_fade_alpha - delta / 0.5, 0.0)
	_panel.modulate.a = _fade_alpha

func is_tutorial_open() -> bool:
	return _active and _panel != null and _fade_alpha > 0.0

func get_save_data() -> Dictionary:
	return _tutorial.get_save_data()

func load_save_data(data: Dictionary) -> void:
	_tutorial.load_save_data(data)
