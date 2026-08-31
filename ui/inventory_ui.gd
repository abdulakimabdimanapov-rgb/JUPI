extends CanvasLayer

var _panel: PanelContainer
var _item_list: VBoxContainer
var _stats_label: Label
var _equipped_label: Label

func _ready() -> void:
	layer = 50
	visible = false

func open() -> void:
	visible = true
	GameManager.set_game_state(GameManager.GameState.INVENTORY)
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
	_panel.custom_minimum_size = Vector2(500, 400)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "INVENTORY"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.75))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_equipped_label = Label.new()
	var equipped_id := GameManager.inventory.get_equipped_weapon()
	var weapon_info := WeaponData.get_weapon(equipped_id)
	_equipped_label.text = "EQUIPPED: %s" % weapon_info.get("name", equipped_id)
	_equipped_label.add_theme_font_size_override("font_size", 14)
	_equipped_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	_equipped_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_equipped_label)

	_stats_label = Label.new()
	_update_stats_text()
	vbox.add_child(_stats_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var items_header := Label.new()
	items_header.text = "ITEMS"
	items_header.add_theme_font_size_override("font_size", 14)
	items_header.add_theme_color_override("font_color", Color(0.7, 0.75, 0.65))
	vbox.add_child(items_header)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_item_list = VBoxContainer.new()
	_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_list.add_theme_constant_override("separation", 3)
	scroll.add_child(_item_list)
	_populate_items()

	var close_btn := Button.new()
	close_btn.text = "[ESC] Close"
	ButtonStyleHelper.apply(close_btn)
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)

func _update_stats_text() -> void:
	var stats: Dictionary = GameManager.get_statistics()
	var weapon_info := WeaponData.get_weapon(stats["weapon"])
	var text := "LV %d  |  XP: %d/%d  |  $%d\n" % [
		stats["level"], int(stats["xp"]), int(stats["xp_to_next"]), stats["currency"]
	]
	text += "HP: %d  |  DMG Bonus: +%d  |  Weapon: %s\n" % [
		int(stats["max_hp"]), int(stats["damage_bonus"]), weapon_info.get("name", "?")
	]
	text += "CRT: %d%%  |  Kills: %d  |  Contracts: %d/%d" % [
		int(weapon_info.get("crit_chance", 0.15) * 100),
		stats["total_kills"], stats["contracts_completed"], stats["contracts_failed"]
	]
	if _stats_label:
		_stats_label.text = text
		_stats_label.add_theme_font_size_override("font_size", 11)
		_stats_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
		_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD

func _populate_items() -> void:
	for child in _item_list.get_children():
		child.queue_free()

	var items := GameManager.inventory.get_all_items()
	if items.is_empty():
		var empty := Label.new()
		empty.text = "  (empty)"
		empty.add_theme_font_size_override("font_size", 12)
		empty.add_theme_color_override("font_color", Color(0.4, 0.42, 0.45))
		_item_list.add_child(empty)
		return

	for item in items:
		var row := _make_item_row(item)
		_item_list.add_child(row)

func _make_item_row(item: Dictionary) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var item_id: String = item.get("id", "")

	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(20, 20)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var icon_path: String = item.get("icon", "")
	if icon_path == "" and WeaponData.WEAPONS.has(item_id):
		icon_path = WeaponData.WEAPONS[item_id].get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	elif ResourceLoader.exists("res://assets/2d/items/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/items/%s.png" % item_id)
	elif ResourceLoader.exists("res://assets/2d/weapons/%s.png" % item_id):
		icon_rect.texture = load("res://assets/2d/weapons/%s.png" % item_id)
	hbox.add_child(icon_rect)

	var name_lbl := Label.new()
	var item_name: String = item.get("name", item.get("id", "???"))
	var count: int = item.get("count", 1)
	name_lbl.text = "%s x%d" % [item_name, count]
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.7))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_lbl)

	if GameManager.inventory.is_consumable(item_id):
		var use_btn := Button.new()
		use_btn.text = "USE"
		ButtonStyleHelper.apply(use_btn, Vector2(50, 22))
		use_btn.pressed.connect(_on_use_item.bind(item_id))
		hbox.add_child(use_btn)

	if GameManager.inventory.is_upgrade(item_id):
		var owned_lbl := Label.new()
		owned_lbl.text = "OWNED"
		owned_lbl.add_theme_font_size_override("font_size", 10)
		owned_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.4))
		hbox.add_child(owned_lbl)

	if WeaponData.WEAPONS.has(item_id):
		var equipped := GameManager.inventory.get_equipped_weapon() == item_id
		if equipped:
			var eq_lbl := Label.new()
			eq_lbl.text = "EQUIPPED"
			eq_lbl.add_theme_font_size_override("font_size", 10)
			eq_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
			hbox.add_child(eq_lbl)
		else:
			var equip_btn := Button.new()
			equip_btn.text = "EQUIP"
			ButtonStyleHelper.apply(equip_btn, Vector2(60, 22))
			equip_btn.pressed.connect(_on_equip_weapon.bind(item_id))
			hbox.add_child(equip_btn)

	return hbox

func _on_use_item(item_id: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and GameManager.inventory.use_consumable(item_id, player):
		AudioLib2D.play("success")
		_populate_items()

func _on_equip_weapon(weapon_id: String) -> void:
	GameManager.inventory.equip_weapon(weapon_id)
	GameManager.current_equipment["weapon"] = weapon_id
	AudioLib2D.play("equip")
	_populate_items()
	var weapon_info := WeaponData.get_weapon(weapon_id)
	if _equipped_label:
		_equipped_label.text = "EQUIPPED: %s" % weapon_info.get("name", weapon_id)
	_update_stats_text()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close()
			get_viewport().set_input_as_handled()
