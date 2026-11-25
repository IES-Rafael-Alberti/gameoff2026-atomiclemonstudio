extends RefCounted
## Look and feel shared by every menu.
##
## The theme is built at runtime. Usage:
##   const MenuStyle := preload("res://scripts/menu_style.gd")
##   theme = MenuStyle.get_theme()

const PIXEL_FONT := preload("res://assets/fonts/PressStart2P-Regular.ttf")
const BODY_FONT := preload("res://assets/fonts/VT323-Regular.ttf")
const BUTTON_NORMAL := preload("res://assets/ui/button_normal.PNG")
const BUTTON_PRESSED := preload("res://assets/ui/button_pressed.PNG")

## Buttons are whole multiples of the 80x16 art, so its pixels stay square.
## BUTTON_SIZE is the normal button; "BigButton" ones are 320x64.
const BUTTON_SIZE := Vector2(240, 48)

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
	_add_buttons(theme)
	return theme


static func _add_buttons(theme: Theme) -> void:
	_style_button(theme, &"Button", 3, 16)
	theme.set_type_variation(&"BigButton", &"Button")
	_style_button(theme, &"BigButton", 4, 24)
	_style_button(theme, &"OptionButton", 3, 16)
	theme.set_constant("modulate_arrow", "OptionButton", 1)
	_keep_default_look(theme, &"CheckButton")


## Draws a button type with the art at `art_scale` times its size.
static func _style_button(theme: Theme, type: StringName, art_scale: int, font_size: int) -> void:
	var normal := _button_box(BUTTON_NORMAL, art_scale)
	var selected := _button_box(BUTTON_PRESSED, art_scale)
	theme.set_stylebox("normal", type, normal)
	for state in ["hover", "focus", "pressed", "hover_pressed", "disabled"]:
		theme.set_stylebox(state, type, selected)
	for color in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color",
			"font_hover_pressed_color", "font_disabled_color"]:
		theme.set_color(color, type, INK)
	theme.set_font("font", type, PIXEL_FONT)
	theme.set_font_size("font_size", type, font_size)


static func _button_box(texture: Texture2D, art_scale: int) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture
	# Centres the text on the face of the button, above its thicker bottom edge.
	box.content_margin_left = 2 * art_scale
	box.content_margin_right = 2 * art_scale
	box.content_margin_top = 3 * art_scale
	box.content_margin_bottom = 5 * art_scale
	return box


## Subclasses of Button would otherwise inherit the button art.
static func _keep_default_look(theme: Theme, type: StringName) -> void:
	var base := ThemeDB.get_default_theme()
	for style in base.get_stylebox_list(type):
		theme.set_stylebox(style, type, base.get_stylebox(style, type))
	for color in base.get_color_list(type):
		theme.set_color(color, type, base.get_color(color, type))


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
