extends Control


var _scroll: ScrollContainer
var _grid: GridContainer
var _info_label: Label
var _filter_input: LineEdit
var _filter := ""

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 40
	top_bar.add_theme_constant_override("separation", 12)
	add_child(top_bar)

	var title := Label.new()
	title.text = "  ASSET GALLERY"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
	top_bar.add_child(title)

	_filter_input = LineEdit.new()
	_filter_input.placeholder_text = "Filter assets..."
	_filter_input.custom_minimum_size = Vector2(200, 28)
	_filter_input.text_changed.connect(_on_filter_changed)
	top_bar.add_child(_filter_input)

	var reload_btn := Button.new()
	reload_btn.text = "RELOAD"
	reload_btn.pressed.connect(_populate_grid)
	top_bar.add_child(reload_btn)

	_info_label = Label.new()
	_info_label.text = ""
	_info_label.add_theme_font_size_override("font_size", 11)
	_info_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
	top_bar.add_child(_info_label)

	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.offset_top = 44
	add_child(_scroll)

	_grid = GridContainer.new()
	_grid.columns = 8
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	_scroll.add_child(_grid)

	_populate_grid()

func _on_filter_changed(text: String) -> void:
	_filter = text.to_lower()
	_populate_grid()

func _populate_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()

	var count := 0
	var categories := {
		"PROJECT ASSETS": "res://assets/2d",
		"AI GENERATED": "res://tools/ai/generated",
	}

	for cat_name in categories:
		var dir_path: String = categories[cat_name]
		if not ResourceLoader.exists(dir_path):
			continue

		var header := Label.new()
		header.text = "\n%s" % cat_name
		header.add_theme_font_size_override("font_size", 14)
		header.add_theme_color_override("font_color", Color(0.7, 0.75, 0.65))
		header.custom_minimum_size = Vector2(800, 24)
		_grid.add_child(header)

		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") and not file_name.begins_with("."):
				if _filter != "" and not file_name.to_lower().contains(_filter):
					file_name = dir.get_next()
					continue
				_add_asset_card(dir_path.path_join(file_name), file_name)
				count += 1
			file_name = dir.get_next()
		dir.list_dir_end()

	_info_label.text = "%d assets loaded" % count

func _add_asset_card(res_path: String, file_name: String) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(100, 130)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)

	var tex_rect := TextureRect.new()
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2(80, 80)
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists(res_path):
		tex_rect.texture = load(res_path)
	vbox.add_child(tex_rect)

	var name_label := Label.new()
	name_label.text = file_name
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.custom_minimum_size = Vector2(96, 0)
	vbox.add_child(name_label)

	if ResourceLoader.exists(res_path):
		var tex: Texture2D = load(res_path)
		if tex:
			var size_label := Label.new()
			size_label.text = "%dx%d" % [tex.get_width(), tex.get_height()]
			size_label.add_theme_font_size_override("font_size", 7)
			size_label.add_theme_color_override("font_color", Color(0.45, 0.5, 0.55))
			vbox.add_child(size_label)

	_grid.add_child(card)
