extends RefCounted
## Look and feel shared by every menu.
##
## The theme is built at runtime. Usage:
##   const MenuStyle := preload("res://scripts/menu_style.gd")
##   theme = MenuStyle.get_theme()

const PIXEL_FONT := preload("res://assets/fonts/PressStart2P-Regular.ttf")
const BODY_FONT := preload("res://assets/fonts/VT323-Regular.ttf")

const INK := Color(0.09, 0.09, 0.11)
const PAPER := Color(0.97, 0.97, 0.97)
const MUTED := Color(0.68, 0.7, 0.74)
const AQUA := Color(0.74, 0.97, 0.98)

static var _theme: Theme


static func get_theme() -> Theme:
	if _theme == null:
		_theme = _build_theme()
	return _theme


static func _build_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = BODY_FONT
	theme.default_font_size = 30
	_add_labels(theme)
	theme.set_font("font", "Button", PIXEL_FONT)
	theme.set_font_size("font_size", "Button", 16)
	return theme


static func _add_labels(theme: Theme) -> void:
	theme.set_color("font_color", "Label", PAPER)

	theme.set_type_variation(&"TitleLabel", &"Label")
	theme.set_font("font", &"TitleLabel", PIXEL_FONT)
	theme.set_font_size("font_size", &"TitleLabel", 40)
	theme.set_color("font_outline_color", &"TitleLabel", INK)
	theme.set_constant("outline_size", &"TitleLabel", 16)
	theme.set_color("font_shadow_color", &"TitleLabel", Color(0, 0, 0, 0.45))
	theme.set_constant("shadow_offset_x", &"TitleLabel", 0)
	theme.set_constant("shadow_offset_y", &"TitleLabel", 8)
	theme.set_constant("shadow_outline_size", &"TitleLabel", 16)

	theme.set_type_variation(&"ColumnLabel", &"Label")
	theme.set_color("font_color", &"ColumnLabel", AQUA)
	theme.set_font_size("font_size", &"ColumnLabel", 26)

	theme.set_type_variation(&"HintLabel", &"Label")
	theme.set_color("font_color", &"HintLabel", MUTED)
	theme.set_font_size("font_size", &"HintLabel", 24)

	theme.set_type_variation(&"CardLabel", &"Label")
	theme.set_font("font", &"CardLabel", PIXEL_FONT)
	theme.set_font_size("font_size", &"CardLabel", 16)
	theme.set_color("font_color", &"CardLabel", INK)
