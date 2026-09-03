extends CanvasLayer
class_name HudMVP

var _hp_bg: ColorRect
var _hp_bar: ColorRect
var _hp_label: Label
var _xp_bar_bg: ColorRect
var _xp_bar: ColorRect
var _level_label: Label
var _weapon_label: Label
var _objective_label: Label
var _combo_label: Label
var _kill_label: Label
var _era_label: Label


func _ready():
	layer = 10
	_build()


func _build():
	# ── HP bar ────────────────────────────────────────────────────────────
	_hp_bg = _make_rect(Vector2(12, 10), Vector2(140, 14), Color(0.06, 0.06, 0.08, 0.85))
	_hp_bar = _make_rect(Vector2(13, 11), Vector2(138, 12), Color(0.85, 0.12, 0.12))
	add_child(_hp_bg)
	add_child(_hp_bar)
	_hp_label = Label.new()
	_hp_label.text = "HP 100/100"
	_hp_label.add_theme_font_size_override("font_size", 9)
	_hp_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.9))
	_hp_label.position = Vector2(16, 11)
	add_child(_hp_label)

	# ── XP bar ────────────────────────────────────────────────────────────
	_xp_bar_bg = _make_rect(Vector2(12, 28), Vector2(140, 6), Color(0.06, 0.06, 0.08, 0.7))
	_xp_bar = _make_rect(Vector2(13, 29), Vector2(138, 4), Color(0.30, 0.80, 0.30))
	add_child(_xp_bar_bg)
	add_child(_xp_bar)

	# ── Level ─────────────────────────────────────────────────────────────
	_level_label = Label.new()
	_level_label.text = "LV 1"
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.25))
	_level_label.position = Vector2(160, 8)
	add_child(_level_label)

	# ── Weapon ────────────────────────────────────────────────────────────
	_weapon_label = Label.new()
	_weapon_label.text = "⚔ Combat Knife"
	_weapon_label.add_theme_font_size_override("font_size", 10)
	_weapon_label.add_theme_color_override("font_color", Color(0.70, 0.75, 0.85))
	_weapon_label.position = Vector2(12, 42)
	add_child(_weapon_label)

	# ── Era indicator ─────────────────────────────────────────────────────
	_era_label = Label.new()
	_era_label.text = "● PRESENT"
	_era_label.add_theme_font_size_override("font_size", 11)
	_era_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	_era_label.position = Vector2(12, 58)
	add_child(_era_label)

	# ── Kill counter ──────────────────────────────────────────────────────
	_kill_label = Label.new()
	_kill_label.text = "Kills: 0"
	_kill_label.add_theme_font_size_override("font_size", 10)
	_kill_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_kill_label.position = Vector2(12, 74)
	add_child(_kill_label)

	# ── Objective (bottom) ────────────────────────────────────────────────
	_objective_label = Label.new()
	_objective_label.text = ""
	_objective_label.add_theme_font_size_override("font_size", 12)
	_objective_label.add_theme_color_override("font_color", Color(0.85, 0.80, 0.45))
	_objective_label.position = Vector2(12, 695)
	add_child(_objective_label)

	# ── Combo display (top right) ─────────────────────────────────────────
	_combo_label = Label.new()
	_combo_label.add_theme_font_size_override("font_size", 28)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_combo_label.position = Vector2(1060, 10)
	_combo_label.visible = false
	add_child(_combo_label)


func _make_rect(pos: Vector2, sz: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.position = pos
	r.size = sz
	return r


func update_hp(hp: float, max_hp_val: float):
	var frac := clampf(hp / max_hp_val, 0.0, 1.0)
	_hp_bar.size.x = frac * 138.0
	_hp_label.text = "HP %d/%d" % [int(hp), int(max_hp_val)]
	if frac < 0.25:
		_hp_bar.color = Color(0.9, 0.1, 0.1)
	elif frac < 0.50:
		_hp_bar.color = Color(0.9, 0.5, 0.1)
	else:
		_hp_bar.color = Color(0.85, 0.12, 0.12)


func update_xp(xp: float, xp_to_next: float):
	if xp_to_next > 0.0:
		_xp_bar.size.x = clampf(xp / xp_to_next, 0.0, 1.0) * 138.0


func update_level(lvl: int):
	_level_label.text = "LV %d" % lvl


func update_weapon(weapon_name: String):
	match weapon_name:
		"blood_scythe":
			_weapon_label.text = "⚔ Blood Scythe"
			_weapon_label.add_theme_color_override("font_color", Color(0.7, 0.3, 0.9))
		_:
			_weapon_label.text = "⚔ Combat Knife"
			_weapon_label.add_theme_color_override("font_color", Color(0.70, 0.75, 0.85))


func update_objective(text: String):
	_objective_label.text = text


func update_era(era: String):
	match era:
		"past":
			_era_label.text = "● PAST"
			_era_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.3))
		_:
			_era_label.text = "● PRESENT"
			_era_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))


func update_kills(kills: int):
	_kill_label.text = "Kills: %d" % kills


func show_combo(count: int):
	_combo_label.visible = count > 0
	_combo_label.text = "%d HIT" % count


func hide_combo():
	_combo_label.visible = false
