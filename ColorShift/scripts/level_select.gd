extends Control

## Level select shown after finishing a level. Add a level here when its
## scene is registered in SceneManager.SCENES; the rest stay locked.
const LEVELS := {
	1: "level_1",
	2: "level_2",
	3: "level_3",
	4: "level_4",
	5: "level_5",
}
const LEVEL_COUNT := 6
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

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer

func _ready() -> void:
	theme = MenuStyle.get_theme()
	for n in range(1, LEVEL_COUNT + 1):
		grid.add_child(_make_button(n))
	grid.get_child(0).grab_focus()

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
	label.text = "LEVEL %d" % n
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
