extends CanvasLayer

var _panel: PanelContainer
var _item_list: VBoxContainer
var _currency_label: Label
var _message_label: Label
var _category_tabs: HBoxContainer
var _current_category: int = 0

func _ready() -> void:
	layer = 50
	visible = false

func open() -> void:
	visible = true
	GameManager.set_game_state(GameManager.GameState.SHOP)
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
	dim.color = Color(0.0, 0.0, 0.02, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			close()
	)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(620, 480)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "TRADER"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_currency_label = Label.new()
	_currency_label.text = "CREDITS: $%d" % GameManager.player_currency
	_currency_label.add_theme_font_size_override("font_size", 14)
	_currency_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_currency_label)

	_category_tabs = HBoxContainer.new()
	_category_tabs.add_theme_constant_override("separation", 8)
	vbox.add_child(_category_tabs)

	var categories := ["UPGRADES", "WEAPONS", "CONSUMABLES"]
	for i in range(categories.size()):
		var btn := Button.new()
		btn.text = categories[i]
		ButtonStyleHelper.apply(btn, Vector2(160, 28))
		btn.pressed.connect(_on_category_changed.bind(i))
		_category_tabs.add_child(btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_item_list = VBoxContainer.new()
	_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_item_list)

	_message_label = Label.new()
	_message_label.text = ""
	_message_label.add_theme_font_size_override("font_size", 12)
	_message_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_message_label)

	var close_btn := Button.new()
	close_btn.text = "[ESC] Close"
	ButtonStyleHelper.apply(close_btn)
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)

	_populate_items()

func _on_category_changed(cat: int) -> void:
	_current_category = cat
	_populate_items()

func _populate_items() -> void:
	for child in _item_list.get_children():
		child.queue_free()

	var category: ShopData.ShopCategory = _current_category as ShopData.ShopCategory
	var items := ShopData.get_shop_items(category)

	for item in items:
		var row := _make_item_row(item)
		_item_list.add_child(row)

func _make_item_row(item: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	row.add_child(hbox)

	var item_id: String = item.get("id", "")
	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(28, 28)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var icon_path: String = item.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	elif ResourceLoader.exists("res://assets/2d/items/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/items/%s.png" % item_id)
	elif ResourceLoader.exists("res://assets/2d/weapons/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/weapons/%s.png" % item_id)
	elif ResourceLoader.exists("res://assets/2d/items/equipment/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/items/equipment/%s.png" % item_id)
	elif ResourceLoader.exists("res://assets/2d/items/currency/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/items/currency/%s.png" % item_id)
	hbox.add_child(icon_rect)

	var info_box := VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# name row with rarity color + combo badge
	var name_hbox := HBoxContainer.new()
	name_hbox.add_theme_constant_override("separation", 6)
	info_box.add_child(name_hbox)

	var name_lbl := Label.new()
	name_lbl.text = item.get("name", item.get("id", "???"))
	name_lbl.add_theme_font_size_override("font_size", 13)
	var rarity: String = item.get("rarity", "common")
	match rarity:
		"uncommon": name_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
		"rare": name_lbl.add_theme_color_override("font_color", Color(0.3, 0.5, 0.9))
		"epic": name_lbl.add_theme_color_override("font_color", Color(0.7, 0.3, 0.9))
		_: name_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.7))
	name_hbox.add_child(name_lbl)

	if not item.get("combo_bonuses", {}).is_empty():
		var badge := Label.new()
		badge.text = "COMBO"
		badge.add_theme_font_size_override("font_size", 9)
		badge.add_theme_color_override("font_color", Color(1.0, 0.7, 0.15))
		name_hbox.add_child(badge)

	var desc_lbl := Label.new()
	desc_lbl.text = item.get("description", "")
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
	info_box.add_child(desc_lbl)

	var stats_text := _get_stats_text(item)
	if stats_text != "":
		var stats_lbl := Label.new()
		stats_lbl.text = stats_text
		stats_lbl.add_theme_font_size_override("font_size", 9)
		stats_lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 0.8))
		info_box.add_child(stats_lbl)

	var combo_text := _get_combo_text(item)
	if combo_text != "":
		var combo_lbl := Label.new()
		combo_lbl.text = combo_text
		combo_lbl.add_theme_font_size_override("font_size", 9)
		combo_lbl.add_theme_color_override("font_color", Color(1.0, 0.65, 0.2))
		info_box.add_child(combo_lbl)

	hbox.add_child(info_box)

	var price_box := VBoxContainer.new()
	price_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var price_lbl := Label.new()
	var price: int = item.get("price", 0)
	price_lbl.text = "$%d" % price
	price_lbl.add_theme_font_size_override("font_size", 12)
	price_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_box.add_child(price_lbl)

	var buy_btn := Button.new()
	buy_btn.text = "BUY"
	ButtonStyleHelper.apply(buy_btn, Vector2(70, 24))
	buy_btn.pressed.connect(_on_buy.bind(item_id, price))
	price_box.add_child(buy_btn)

	hbox.add_child(price_box)
	return row

func _get_stats_text(item: Dictionary) -> String:
	var parts: Array[String] = []
	if item.has("damage"):
		parts.append("DMG: %d" % int(item["damage"]))
	if item.has("range"):
		parts.append("RNG: %d" % int(item["range"]))
	if item.has("attack_speed"):
		parts.append("SPD: %.1fx" % item["attack_speed"])
	if item.has("crit_chance"):
		parts.append("CRT: %d%%" % int(item["crit_chance"] * 100))
	if item.has("heal"):
		parts.append("HEAL: %d" % int(item["heal"]))
	if item.has("energy"):
		parts.append("ENERGY: %d" % int(item["energy"]))
	if item.has("value") and item.has("stat"):
		parts.append("%s +%s" % [item["stat"].replace("_", " ").to_upper(), str(item["value"])])
	return " | ".join(parts)


func _get_combo_text(item: Dictionary) -> String:
	var combo: Dictionary = item.get("combo_bonuses", {})
	if combo.is_empty():
		return ""
	var parts: Array[String] = []
	var hit_effect: String = combo.get("hit_effect", "")
	if hit_effect != "":
		var chance: float = combo.get("hit_effect_chance", 1.0)
		if chance >= 1.0:
			parts.append("Hit → %s" % hit_effect.to_upper())
		else:
			parts.append("Hit → %s (%d%%)" % [hit_effect.to_upper(), int(chance * 100)])
	var finisher: String = combo.get("finisher", "")
	if finisher != "":
		parts.append("3rd hit → %s" % finisher.replace("_", " "))
	return " | ".join(parts)

func _on_buy(item_id: String, price: int) -> void:
	if GameManager.buy_item(item_id):
		_show_message("+%s" % item_id.to_upper(), Color(0.3, 0.9, 0.4))
		AudioLib2D.play("success")
		_currency_label.text = "CREDITS: $%d" % GameManager.player_currency
		_populate_items()
	else:
		_show_message("NOT ENOUGH CREDITS", Color(0.9, 0.3, 0.2))
		AudioLib2D.play("enemy_alert")

func _show_message(text: String, color: Color) -> void:
	if _message_label:
		_message_label.text = text
		_message_label.add_theme_color_override("font_color", color)
		await get_tree().create_timer(2.0).timeout
		if _message_label:
			_message_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()
