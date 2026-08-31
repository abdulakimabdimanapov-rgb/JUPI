extends CanvasLayer


var _panel: PanelContainer
var _content: VBoxContainer
var _era_containers: Dictionary = {}
var _visible := false

func _ready() -> void:
	layer = 15
	visible = false
	_build_ui()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(600, 500)
	_panel.size = Vector2(600, 500)
	_panel.position = (Vector2(1024, 600) - Vector2(600, 500)) / 2.0
	_panel.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.03, 0.08, 0.95)
	style.border_color = Color(0.4, 0.2, 0.6)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 8)
	_panel.add_child(_content)

	var title := Label.new()
	title.text = "══════════ TIMELINE ══════════"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.7, 0.5, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(title)

	var eras := ["past", "present", "future", "collapsed"]
	var era_names := {"past": "PAST", "present": "PRESENT", "future": "FUTURE", "collapsed": "COLLAPSED"}
	var era_colors := {
		"past": Color(0.8, 0.6, 0.3),
		"present": Color(0.5, 0.6, 0.8),
		"future": Color(0.3, 0.7, 0.9),
		"collapsed": Color(0.8, 0.3, 0.3),
	}

	for era in eras:
		var era_box := VBoxContainer.new()
		era_box.add_theme_constant_override("separation", 4)
		_content.add_child(era_box)

		var era_label := Label.new()
		era_label.text = "▸ %s" % era_names[era]
		era_label.add_theme_font_size_override("font_size", 14)
		era_label.add_theme_color_override("font_color", era_colors[era])
		era_box.add_child(era_label)

		var events_container := VBoxContainer.new()
		events_container.name = "Events_%s" % era
		era_box.add_child(events_container)
		_era_containers[era] = events_container

		if era != "collapsed":
			var arrow := Label.new()
			arrow.text = "     ↓"
			arrow.add_theme_font_size_override("font_size", 14)
			arrow.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			_content.add_child(arrow)

	var close_label := Label.new()
	close_label.text = "[T] Close Timeline"
	close_label.add_theme_font_size_override("font_size", 11)
	close_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	close_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(close_label)

func open() -> void:
	_visible = true
	visible = true
	_panel.visible = true
	_refresh()
	GameManager.set_game_state(GameManager.GameState.TIMELINE)

func close() -> void:
	_visible = false
	visible = false
	_panel.visible = false
	GameManager.set_game_state(GameManager.GameState.EXPLORING)

func _refresh() -> void:
	var events := ParadoxData.get_paradox_events()
	var world_flags := GameManager.world_flags if GameManager else {}

	for era in _era_containers:
		for child in _era_containers[era].get_children():
			child.queue_free()

	for event in events:
		var source_era: String = event.get("source_era", "present")
		if _era_containers.has(source_era):
			var event_label := Label.new()
			var flag_name: String = event.get("world_flag", "")
			var triggered: bool = world_flags.get(flag_name, false)

			if triggered:
				event_label.text = "  ◆ %s [CHANGED]" % event.get("name", "???")
				event_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
			else:
				event_label.text = "  ○ %s [UNKNOWN]" % event.get("name", "???")
				event_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

			event_label.add_theme_font_size_override("font_size", 11)
			_era_containers[source_era].add_child(event_label)

			if triggered:
				var consequences: Dictionary = event.get("consequences", {})
				for target_era in consequences:
					var cons: Dictionary = consequences[target_era]
					var desc: String = cons.get("description", "")
					if desc != "":
						var desc_label := Label.new()
						desc_label.text = "    → %s: %s" % [target_era.to_upper(), desc]
						desc_label.add_theme_font_size_override("font_size", 9)
						desc_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.6))
						_era_containers[source_era].add_child(desc_label)

func _input(event: InputEvent) -> void:
	if not _visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T, KEY_ESCAPE:
				close()
				get_viewport().set_input_as_handled()
