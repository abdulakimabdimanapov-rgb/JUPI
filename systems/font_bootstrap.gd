extends Node
## Sets the project-wide fallback font so all Labels are visible.

func _ready() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "Helvetica", "DejaVu Sans", "Noto Sans"])

	# Apply to the global theme
	var theme := ThemeDB.fallback_font
	ThemeDB.fallback_font = font
	ThemeDB.fallback_font_size = 16
  