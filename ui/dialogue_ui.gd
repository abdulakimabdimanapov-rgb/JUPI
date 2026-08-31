extends CanvasLayer

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)
signal choice_made(choice_index: int, choice: Dictionary)

var _dialogue_id: String = ""
var _current_node_id: String = ""
var _panel: PanelContainer
var _speaker_label: Label
var _text_label: Label
var _choices_vbox: VBoxContainer
var _hint_label: Label
var _dim: ColorRect
var _typing := false
var _full_text := ""
var _char_index := 0
var _type_timer := 0.0
var _type_speed := 0.03
var _active := false

func _ready():
	layer = 45
	visible = false

func open():
	visible = true
	_active = true
	_build_ui()

func close():
	visible = false
	_active = false
	_dialogue_id = ""
	_current_node_id = ""
	if _panel:
		_panel.queue_free()
		_panel = null

func start_dialogue(dialogue_id, start_node = "start"):
	_dialogue_id = start_node
	var dialogue: Dictionary = DialogueData.get_dialogue(dialogue_id)
	if dialogue.is_empty():
		return
	_dialogue_id = dialogue_id
	_current_node_id = start_node
	open()
	_show_node(start_node)
	dialogue_started.emit(dialogue_id)

func start_npc_dialogue(npc_name):
	var dialogue: Dictionary = DialogueData.get_npc_dialogue(npc_name)
	if dialogue.is_empty():
		start_dialogue("")
		_set_text("Hello there.")
		return
	var d_id: String = DialogueData.NPC_DIALOGUES.get(npc_name, "")
	if d_id != "":
		start_dialogue(d_id)

func _build_ui():
	_dim = ColorRect.new()
	_dim.color = Color(0.0, 0.0, 0.02, 0.55)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(580, 220)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 14)
	_speaker_label.add_theme_color_override("font_color", Color(0.5, 0.85, 0.7))
	vbox.add_child(_speaker_label)

	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 13)
	_text_label.add_theme_color_override("font_color", Color(0.88, 0.9, 0.85))
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.custom_minimum_size = Vector2(520, 0)
	vbox.add_child(_text_label)

	_choices_vbox = VBoxContainer.new()
	_choices_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_choices_vbox)

	_hint_label = Label.new()
	_hint_label.text = "[SPACE to continue]"
	_hint_label.add_theme_font_size_override("font_size", 10)
	_hint_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	vbox.add_child(_hint_label)

func _show_node(node_id):
	if not _active:
		return
	var dialogue: Dictionary = DialogueData.get_dialogue(_dialogue_id)
	var nodes: Dictionary = dialogue.get("nodes", {})
	var node: Dictionary = nodes.get(node_id, {})
	if node.is_empty():
		close()
		return

	_current_node_id = node_id

	var speaker: String = dialogue.get("speaker", "")
	_speaker_label.text = speaker

	var req_flag: String = node.get("require_flag", "")
	if req_flag != "" and not GameManager.world_flags.get(req_flag, false):
		close()
		return

	var text: String = node.get("text", "")
	_set_text(text)

	var effects: Dictionary = node.get("effects", {})
	DialogueData.apply_effects(effects, GameManager)

	var choices: Array = node.get("choices", [])
	var next_node: String = node.get("next", "")

	for child in _choices_vbox.get_children():
		child.queue_free()

	if not choices.is_empty():
		_hint_label.text = ""
		var filtered := DialogueData.filter_choices(choices, GameManager.world_flags)
		for i in range(filtered.size()):
			var choice: Dictionary = filtered[i]
			var btn := Button.new()
			btn.text = "> %s" % choice.get("text", "...")
			btn.add_theme_font_size_override("font_size", 12)
			btn.add_theme_color_override("font_color", Color(0.8, 0.85, 0.75))
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_choice_pressed.bind(i, choice))
			ButtonStyleHelper.apply(btn)
			_choices_vbox.add_child(btn)
	elif next_node != "":
		_hint_label.text = "[SPACE to continue]"
	else:
		_hint_label.text = "[SPACE to close]"

func _set_text(text):
	_full_text = text
	_char_index = 0
	_typing = true
	_text_label.text = ""

func _process(delta):
	if not _active or not _typing:
		return
	_type_timer += delta
	while _type_timer >= _type_speed and _char_index < _full_text.length():
		_char_index += 1
		_text_label.text = _full_text.substr(0, _char_index)
		_type_timer -= _type_speed
	if _char_index >= _full_text.length():
		_typing = false

func _unhandled_input(event):
	if not _active:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			if _typing:
				_typing = false
				_char_index = _full_text.length()
				_text_label.text = _full_text
				return
			var node := DialogueData.get_dialogue_node(_dialogue_id, _current_node_id)
			var choices: Array = node.get("choices", [])
			var next_node: String = node.get("next", "")
			if not choices.is_empty():
				return
			if next_node != "":
				_show_node(next_node)
			else:
				_end_dialogue()
		elif event.keycode == KEY_ESCAPE:
			_end_dialogue()
			get_viewport().set_input_as_handled()

func _on_choice_pressed(index, choice):
	choice_made.emit(index, choice)
	var flag: String = choice.get("flag", "")
	if flag != "":
		GameManager.set_world_flag(flag, true)
	var next_node: String = choice.get("next", "")
	if next_node != "":
		_show_node(next_node)
	else:
		_end_dialogue()

func _end_dialogue():
	var d_id := _dialogue_id
	close()
	dialogue_ended.emit(d_id)

func is_open():
	return _active
