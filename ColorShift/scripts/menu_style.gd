extends RefCounted
## Look and feel shared by every menu.
##
## The theme is built at runtime. Usage:
##   const MenuStyle := preload("res://scripts/menu_style.gd")
##   theme = MenuStyle.get_theme()

#const PIXEL_FONT := preload("res://assets/fonts/PressStart2P-Regular.ttf") #Pixel art
const PIXEL_FONT := preload("res://assets/fonts/DynaPuff-Medium.ttf") #Muy gorda
#const BODY_FONT := preload("res://assets/fonts/VT323-Regular.ttf")
const BODY_FONT := preload("res://assets/fonts/DynaPuff-Regular.ttf") #Muy delgada en comparación
const BUTTON_NORMAL := preload("res://assets/ui/button_normal.PNG")
const BUTTON_PRESSED := preload("res://assets/ui/button_pressed.PNG")
const CARD_NORMAL := preload("res://assets/ui/level-selection/Card1.PNG")
const CARD_SELECTED := preload("res://assets/ui/level-selection/Card1-2.png")

## Level cards ("LevelCard" buttons). The art has a transparent margin, so only
## CARD_REGION is drawn. CARD_ART and CARD_TEXT are the window for the picture and
## the strip for the name under it, in pixels of that region.
const CARD_REGION := Rect2(4, 4, 120, 120)
const CARD_ART := Rect2(8, 9, 104, 82)
const CARD_TEXT := Rect2(8, 92, 104, 22)
const CARD_SCALE := 2

## Buttons are whole multiples of the 80x16 art, so its pixels stay square.
## BUTTON_SIZE is the normal button; "BigButton" ones are 320x64.
const BUTTON_SIZE := Vector2(240, 48)

const INK := Color(0.09, 0.09, 0.11)
const PAPER := Color(0.97, 0.97, 0.97)
const MUTED := Color(0.68, 0.7, 0.74)
const AQUA := Color(0.74, 0.97, 0.98)
const FOCUS := Color(1.0, 0.82, 0.15)

## Black outline around the text of the options menus.
const TEXT_OUTLINE_SIZE := 8
## Thickness of the focus ring: 2 px black, 4 px yellow, 2 px black.
const FOCUS_RING_SIZE := 8

static var _theme: Theme
static var _options_theme: Theme
static var _focus_box: StyleBoxTexture
static var _hover_boxes: Array[StyleBoxTexture] = []
static var _hover_highlight := true


static func get_theme() -> Theme:
	if _theme == null:
		_theme = _build_theme()
	return _theme


## Same theme, with the text outlined to read it over the light background.
## Button text is left as it is.
static func get_options_theme() -> Theme:
	if _options_theme == null:
		_options_theme = _build_theme()
		for type in [&"Label", &"CheckButton"]:
			_options_theme.set_color("font_outline_color", type, Color.BLACK)
			_options_theme.set_constant("outline_size", type, TEXT_OUTLINE_SIZE)
		for color in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color",
				"font_hover_pressed_color"]:
			_options_theme.set_color(color, &"CheckButton", PAPER)
	return _options_theme


## Ring around the selected control, for the controls without the button art.
## It is drawn outside the rectangle of the control.
static func get_focus_box() -> StyleBoxTexture:
	if _focus_box == null:
		var image := Image.create_empty(24, 24, false, Image.FORMAT_RGBA8)
		image.fill(Color.BLACK)
		image.fill_rect(Rect2i(2, 2, 20, 20), FOCUS)
		image.fill_rect(Rect2i(6, 6, 12, 12), Color.BLACK)
		image.fill_rect(Rect2i(8, 8, 8, 8), Color.TRANSPARENT)
		_focus_box = StyleBoxTexture.new()
		_focus_box.texture = ImageTexture.create_from_image(image)
		_focus_box.set_texture_margin_all(FOCUS_RING_SIZE)
		_focus_box.set_expand_margin_all(FOCUS_RING_SIZE)
		_focus_box.draw_center = false
	return _focus_box


## Turned off while a controller or the keyboard is in use, so a button left
## under the mouse cursor does not look selected.
static func set_hover_highlight(enabled: bool) -> void:
	_hover_highlight = enabled
	var key := &"selected_texture" if enabled else &"normal_texture"
	for box in _hover_boxes:
		box.texture = box.get_meta(key)


static func _build_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = BODY_FONT
	theme.default_font_size = 20
	_add_labels(theme)
	_add_buttons(theme)
	return theme


static func _add_buttons(theme: Theme) -> void:
	_style_button(theme, &"Button", 3, 16)
	theme.set_type_variation(&"BigButton", &"Button")
	_style_button(theme, &"BigButton", 4, 24)
	_style_button(theme, &"OptionButton", 3, 16)
	theme.set_constant("modulate_arrow", "OptionButton", 1)
	theme.set_type_variation(&"LevelCard", &"Button")
	_set_button_boxes(theme, &"LevelCard", _card_box(CARD_NORMAL), _card_box(CARD_SELECTED))
	_keep_default_look(theme, &"CheckButton")
	theme.set_stylebox("focus", &"CheckButton", get_focus_box())


## Draws a button type with the art at `art_scale` times its size.
static func _style_button(theme: Theme, type: StringName, art_scale: int, font_size: int) -> void:
	var selected := _button_box(BUTTON_PRESSED, art_scale)
	_set_button_boxes(theme, type, _button_box(BUTTON_NORMAL, art_scale), selected)
	theme.set_stylebox("disabled", type, selected)
	for color in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color",
			"font_hover_pressed_color", "font_disabled_color"]:
		theme.set_color(color, type, INK)
	theme.set_font("font", type, PIXEL_FONT)
	theme.set_font_size("font_size", type, font_size)


## Gives a button type its look: `selected` is used when hovered, focused or pressed.
static func _set_button_boxes(theme: Theme, type: StringName, normal: StyleBoxTexture,
		selected: StyleBoxTexture) -> void:
	# The hover box has its own copy, so set_hover_highlight() can change it.
	var hover := selected.duplicate() as StyleBoxTexture
	hover.set_meta(&"normal_texture", normal.texture)
	hover.set_meta(&"selected_texture", selected.texture)
	hover.texture = selected.texture if _hover_highlight else normal.texture
	_hover_boxes.append(hover)
	theme.set_stylebox("normal", type, normal)
	theme.set_stylebox("hover", type, hover)
	theme.set_stylebox("disabled", type, normal)
	for state in ["focus", "pressed", "hover_pressed"]:
		theme.set_stylebox(state, type, selected)


static func _card_box(texture: Texture2D) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture
	box.region_rect = CARD_REGION
	return box


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
	theme.set_font_size("font_size", &"TitleLabel", 50) #Titulo
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
