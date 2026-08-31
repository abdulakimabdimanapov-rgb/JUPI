extends CanvasLayer

signal era_selected(era_id: String)
signal travel_cancelled()

var _panel: PanelContainer
var _era_list: VBoxContainer
var _info_label: Label
var _confirm_panel: PanelContainer

func _ready() -> void:
	layer = 60
	visible = false

func open() -> void:
	visible = true
	GameManager.set_game_state(GameManager.GameState.DIALOGUE)
	AudioLib2D.play("clock_open")
	_build_ui()

func close() -> void:
	visible = false
	GameManager.set_game_state(GameManager.GameState.EXPLORING)
	AudioLib2D.play("door")

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.05, 0.85)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(650, 500)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "TIME MACHINE"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 0.8, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Select destination era"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.6, 0.65))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	var current_lbl := Label.new()
	current_lbl.text = "Current Era: %s" % GameManager.current_era.to_upper()
	current_lbl.add_theme_font_size_override("font_size", 11)
	current_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.4))
	current_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(current_lbl)

	vbox.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_era_list = VBoxContainer.new()
	_era_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_era_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_era_list)

	_populate_eras()

	_info_label = Label.new()
	_info_label.text = ""
	_info_label.add_theme_font_size_override("font_size", 11)
	_info_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.75))
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_info_label)

	var close_btn := Button.new()
	close_btn.text = "[ESC] Cancel"
	close_btn.pressed.connect(close)
	ButtonStyleHelper.apply(close_btn)
	vbox.add_child(close_btn)

func _populate_eras() -> void:
	for child in _era_list.get_children():
		child.queue_free()

	var all_eras := EraData.get_all_eras()
	var unlocked: Array = GameManager.unlocked_eras

	for era in all_eras:
		var era_id: String = era.get("id", "present")
		var is_unlocked: bool = unlocked.has(era_id)
		var is_current: bool = GameManager.current_era == era_id
		var row := _make_era_row(era, is_unlocked, is_current)
		_era_list.add_child(row)

func _make_era_row(era: Dictionary, is_unlocked: bool, is_current: bool) -> PanelContainer:
	var row := PanelContainer.new()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)

	var info_box := VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	var era_name: String = era.get("name", "???")
	if is_current:
		era_name += " [CURRENT]"
	name_lbl.text = era_name
	name_lbl.add_theme_font_size_override("font_size", 16)
	var accent: Color = era.get("accent_color", Color(0.7, 0.7, 0.7))
	if not is_unlocked:
		name_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35))
	else:
		name_lbl.add_theme_color_override("font_color", accent)
	info_box.add_child(name_lbl)

	if is_unlocked:
		var desc_lbl := Label.new()
		desc_lbl.text = era.get("description", "")
		desc_lbl.add_theme_font_size_override("font_size", 10)
		desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		info_box.add_child(desc_lbl)

		var meta_lbl := Label.new()
		meta_lbl.text = "Danger: %s | Rec. Level: %d" % [era.get("danger", "???"), era.get("recommended_level", 1)]
		meta_lbl.add_theme_font_size_override("font_size", 9)
		var danger: String = era.get("danger", "LOW")
		match danger:
			"LOW": meta_lbl.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
			"MEDIUM": meta_lbl.add_theme_color_override("font_color", Color(0.8, 0.7, 0.2))
			"HIGH": meta_lbl.add_theme_color_override("font_color", Color(0.8, 0.4, 0.2))
			"EXTREME": meta_lbl.add_theme_color_override("font_color", Color(0.9, 0.2, 0.15))
		info_box.add_child(meta_lbl)
	else:
		var lock_lbl := Label.new()
		lock_lbl.text = "LOCKED — %s" % _get_unlock_text(era.get("unlock_condition", ""))
		lock_lbl.add_theme_font_size_override("font_size", 10)
		lock_lbl.add_theme_color_override("font_color", Color(0.5, 0.3, 0.3))
		info_box.add_child(lock_lbl)

	hbox.add_child(info_box)

	if is_unlocked and not is_current:
		var travel_btn := Button.new()
		travel_btn.text = "TRAVEL"
		travel_btn.custom_minimum_size = Vector2(90, 32)
		var era_id: String = era.get("id", "present")
		travel_btn.pressed.connect(_on_travel_pressed.bind(era_id, era.get("name", "???")))
		ButtonStyleHelper.apply(travel_btn, Vector2(90, 32))
		hbox.add_child(travel_btn)
	elif is_current:
		var current_lbl := Label.new()
		current_lbl.text = "HERE"
		current_lbl.add_theme_font_size_override("font_size", 12)
		current_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.4))
		hbox.add_child(current_lbl)
	else:
		var lock_icon := Label.new()
		lock_icon.text = "🔒"
		lock_icon.add_theme_font_size_override("font_size", 16)
		hbox.add_child(lock_icon)

	return row

func _get_unlock_text(condition: String) -> String:
	match condition:
		"complete_any_contract": return "Complete any contract"
		"player_level_5": return "Reach Level 5"
		"complete_3_contracts": return "Complete 3 contracts"
		"": return ""
	return condition

func _on_travel_pressed(era_id: String, era_name: String) -> void:
	_show_confirmation(era_id, era_name)

func _show_confirmation(era_id: String, era_name: String) -> void:
	_confirm_panel = PanelContainer.new()
	_confirm_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_confirm_panel.custom_minimum_size = Vector2(400, 200)
	_confirm_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_confirm_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_confirm_panel.z_index = 5
	add_child(_confirm_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	_confirm_panel.add_child(vbox)

	var msg := Label.new()
	msg.text = "Travel to %s?\n\nThis will consume time energy." % era_name
	msg.add_theme_font_size_override("font_size", 14)
	msg.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(msg)

	var btn_box := HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_box)

	var confirm_btn := Button.new()
	confirm_btn.text = "CONFIRM"
	confirm_btn.custom_minimum_size = Vector2(120, 32)
	confirm_btn.pressed.connect(_on_confirm_travel.bind(era_id))
	ButtonStyleHelper.apply(confirm_btn, Vector2(120, 32))
	btn_box.add_child(confirm_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "CANCEL"
	cancel_btn.custom_minimum_size = Vector2(120, 32)
	cancel_btn.pressed.connect(_on_cancel_travel)
	ButtonStyleHelper.apply(cancel_btn, Vector2(120, 32))
	btn_box.add_child(cancel_btn)

func _on_confirm_travel(era_id: String) -> void:
	if _confirm_panel:
		_confirm_panel.queue_free()
		_confirm_panel = null

	close()

	era_selected.emit(era_id)

func _on_cancel_travel() -> void:
	if _confirm_panel:
		_confirm_panel.queue_free()
		_confirm_panel = null

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if _confirm_panel:
				_on_cancel_travel()
			else:
				close()
			get_viewport().set_input_as_handled()
