class_name ButtonStyleHelper
extends RefCounted

## Applies a consistent dark cyberpunk style to a Button with hover/pressed effects.
## Usage: ButtonStyleHelper.apply(button)

const BG_NORMAL := Color(0.08, 0.06, 0.12, 0.9)
const BG_HOVER := Color(0.15, 0.12, 0.22, 0.95)
const BG_PRESSED := Color(0.05, 0.04, 0.08, 1.0)
const BG_DISABLED := Color(0.06, 0.05, 0.08, 0.6)
const BORDER_NORMAL := Color(0.35, 0.30, 0.45, 0.6)
const BORDER_HOVER := Color(0.85, 0.75, 0.25, 0.9)
const BORDER_PRESSED := Color(0.95, 0.80, 0.25, 1.0)
const BORDER_DISABLED := Color(0.2, 0.2, 0.25, 0.4)
const TEXT_NORMAL := Color(0.75, 0.78, 0.80)
const TEXT_HOVER := Color(0.95, 0.90, 0.55)
const TEXT_PRESSED := Color(1.0, 0.95, 0.65)
const TEXT_DISABLED := Color(0.35, 0.35, 0.40)
const CORNER_RADIUS := 4
const BORDER_WIDTH := 1


static func apply(btn: Button, custom_min_size: Vector2 = Vector2.ZERO) -> void:
	if custom_min_size != Vector2.ZERO:
		btn.custom_minimum_size = custom_min_size
	btn.add_theme_font_size_override("font_size", 13)

	# Normal style
	var normal := StyleBoxFlat.new()
	normal.bg_color = BG_NORMAL
	normal.border_color = BORDER_NORMAL
	normal.set_border_width_all(BORDER_WIDTH)
	normal.set_corner_radius_all(CORNER_RADIUS)
	normal.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", normal)

	# Hover style
	var hover := StyleBoxFlat.new()
	hover.bg_color = BG_HOVER
	hover.border_color = BORDER_HOVER
	hover.set_border_width_all(BORDER_WIDTH)
	hover.set_corner_radius_all(CORNER_RADIUS)
	hover.set_content_margin_all(8)
	hover.shadow_color = Color(0.95, 0.80, 0.25, 0.15)
	hover.shadow_size = 2
	hover.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("hover", hover)

	# Hover + Focus (keyboard nav)
	var hover_focus := hover.duplicate()
	btn.add_theme_stylebox_override("hover_focus", hover_focus)

	# Pressed style
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = BG_PRESSED
	pressed.border_color = BORDER_PRESSED
	pressed.set_border_width_all(BORDER_WIDTH + 1)
	pressed.set_corner_radius_all(CORNER_RADIUS)
	pressed.set_content_margin_all(8)
	pressed.shadow_color = Color(0.95, 0.80, 0.25, 0.3)
	pressed.shadow_size = 4
	pressed.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Focus style (keyboard)
	var focus := StyleBoxFlat.new()
	focus.bg_color = BG_NORMAL
	focus.border_color = BORDER_HOVER
	focus.set_border_width_all(BORDER_WIDTH + 1)
	focus.set_corner_radius_all(CORNER_RADIUS)
	focus.set_content_margin_all(8)
	btn.add_theme_stylebox_override("focus", focus)

	# Disabled style
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = BG_DISABLED
	disabled.border_color = BORDER_DISABLED
	disabled.set_border_width_all(BORDER_WIDTH)
	disabled.set_corner_radius_all(CORNER_RADIUS)
	disabled.set_content_margin_all(8)
	btn.add_theme_stylebox_override("disabled", disabled)

	# Text colors
	btn.add_theme_color_override("font_color", TEXT_NORMAL)
	btn.add_theme_color_override("font_hover_color", TEXT_HOVER)
	btn.add_theme_color_override("font_pressed_color", TEXT_PRESSED)
	btn.add_theme_color_override("font_disabled_color", TEXT_DISABLED)
	btn.add_theme_color_override("font_focus_color", TEXT_HOVER)
