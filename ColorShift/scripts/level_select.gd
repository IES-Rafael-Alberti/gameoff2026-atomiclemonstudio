extends Control

## Level select shown after finishing a level. Add a level here when its
## scene is registered in SceneManager.SCENES; the rest stay locked.
## The last card (BOSS_SLOT) is reserved for the boss level: add it to LEVELS
## once its scene is registered.
const LEVELS := {
	1: "level_1",
	2: "level_2",
	3: "level_3",
	4: "level_4",
	5: "level_5",
	6: "level_6",
	7: "level_7",
}
const LEVEL_COUNT := 8
const BOSS_SLOT := 8
## Cards shown at once, in a single row; < and > turn the page.
const PAGE_SIZE := 4
## 16:9 like the main menu, so the row of cards and both arrows fit. The game
## size is restored on exit.
const SELECT_CONTENT_SIZE := Vector2i(1366, 768)
const MenuStyle := preload("res://scripts/menu_style.gd")
const DOOR := preload("res://assets/sprites/scenary/door.png")
const DOOR_SIZE := Vector2(64, 96)
# One thumbnail per level (reused cyclically if there are more levels than art).
const THUMBNAILS: Array[Texture2D] = [
	preload("res://assets/level-selection/select-lvl1.png"),
	preload("res://assets/level-selection/select-lvl2.png"),
	preload("res://assets/level-selection/select-lvl3.png"),
	preload("res://assets/level-selection/select-lvl4.png"),
	preload("res://assets/level-selection/select-lvl5.png"),
	preload("res://assets/level-selection/select-lvl6.png")
]

@onready var grid: GridContainer = $Panel/VBoxContainer/Pages/GridContainer
@onready var prev_button: Button = $Panel/VBoxContainer/Pages/Prev
@onready var next_button: Button = $Panel/VBoxContainer/Pages/Next

var _page := 0
var _original_content_size := Vector2i.ZERO

func _ready() -> void:
	theme = MenuStyle.get_theme()
	var window := get_window()
	_original_content_size = window.content_scale_size
	window.content_scale_size = SELECT_CONTENT_SIZE
	for n in range(1, LEVEL_COUNT + 1):
		grid.add_child(_make_button(n))
	for arrow: Button in [prev_button, next_button]:
		_style_arrow(arrow)
	prev_button.pressed.connect(_turn_page.bind(-1))
	next_button.pressed.connect(_turn_page.bind(1))
	_show_page(0)
	grid.get_child(0).grab_focus()


func _exit_tree() -> void:
	if _original_content_size != Vector2i.ZERO:
		get_window().content_scale_size = _original_content_size


func _turn_page(step: int) -> void:
	_show_page(_page + step)
	# At the first or last page the arrow is disabled: go to the first card.
	if (prev_button if step < 0 else next_button).disabled:
		grid.get_child(_page * PAGE_SIZE).grab_focus()


func _show_page(page: int) -> void:
	var last := (LEVEL_COUNT - 1) / PAGE_SIZE
	_page = clampi(page, 0, last)
	for i in grid.get_child_count():
		grid.get_child(i).visible = i / PAGE_SIZE == _page
	_set_arrow_enabled(prev_button, _page > 0)
	_set_arrow_enabled(next_button, _page < last)


func _set_arrow_enabled(arrow: Button, enabled: bool) -> void:
	arrow.disabled = not enabled
	arrow.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


## Big < and > in the title font, without the button art.
func _style_arrow(arrow: Button) -> void:
	arrow.flat = true
	arrow.custom_minimum_size = Vector2(64, 96)
	arrow.add_theme_font_override("font", MenuStyle.PIXEL_FONT)
	arrow.add_theme_font_size_override("font_size", 72)
	arrow.add_theme_constant_override("outline_size", 16)
	arrow.add_theme_color_override("font_outline_color", MenuStyle.INK)
	for color in ["font_color", "font_pressed_color"]:
		arrow.add_theme_color_override(color, MenuStyle.PAPER)
	for color in ["font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		arrow.add_theme_color_override(color, MenuStyle.FOCUS)
	arrow.add_theme_color_override("font_disabled_color", Color(MenuStyle.PAPER, 0.25))
	arrow.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _make_button(n: int) -> Button:
	var button := Button.new()
	button.theme_type_variation = &"LevelCard"
	button.custom_minimum_size = MenuStyle.CARD_REGION.size * MenuStyle.CARD_SCALE

	var thumb := TextureRect.new()
	thumb.texture = THUMBNAILS[(n - 1) % THUMBNAILS.size()]
	thumb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.clip_contents = true
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Behind the card, so the frame of its window stays on top of the picture.
	thumb.show_behind_parent = true
	_place_on_card(thumb, MenuStyle.CARD_ART)
	button.add_child(thumb)

	var label := Label.new()
	label.text = "BOSS" if n == BOSS_SLOT else "LEVEL %d" % n
	label.theme_type_variation = &"CardLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_on_card(label, MenuStyle.CARD_TEXT)
	button.add_child(label)

	if LEVELS.has(n):
		button.pressed.connect(SceneManager.change_scene.bind(LEVELS[n]))
	else:
		# Locked: dimmed thumbnail with a door on top.
		button.disabled = true
		thumb.modulate = Color(0.35, 0.35, 0.35)
		label.modulate = Color(1, 1, 1, 0.5)
		var door := TextureRect.new()
		door.texture = DOOR
		door.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		door.mouse_filter = Control.MOUSE_FILTER_IGNORE
		door.position = MenuStyle.CARD_ART.get_center() * MenuStyle.CARD_SCALE - DOOR_SIZE / 2.0
		door.size = DOOR_SIZE
		button.add_child(door)
	return button


## Puts a node over an area of the card, given in pixels of the card art.
func _place_on_card(node: Control, area: Rect2) -> void:
	node.position = area.position * MenuStyle.CARD_SCALE
	node.size = area.size * MenuStyle.CARD_SCALE


func _on_back_pressed() -> void:
	SceneManager.change_scene("main_menu")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
