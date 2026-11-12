extends Control

## Level select shown after finishing a level. Add a level here when its
## scene is registered in SceneManager.SCENES; the rest stay locked.
const LEVELS := {
	1: "demo_level",
}
const LEVEL_COUNT := 6
const DOOR := preload("res://assets/sprites/scenary/door.png")
# Placeholder thumbnails, reused cyclically until each level has its own art.
const THUMBNAILS: Array[Texture2D] = [
	preload("res://assets/menu_background.jpg"),
	preload("res://assets/menu_background_2.jpg"),
	preload("res://assets/menu_background_3.jpg"),
	preload("res://assets/menu_background_4.jpg"),
]

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer


func _ready() -> void:
	for n in range(1, LEVEL_COUNT + 1):
		grid.add_child(_make_button(n))


func _make_button(n: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(220, 170)
	for style in ["normal", "disabled"]:
		button.add_theme_stylebox_override(style, preload("res://shader/button_style.tres"))
	button.add_theme_stylebox_override("pressed", preload("res://shader/button_pressed_style.tres"))
	button.add_theme_stylebox_override("hover", preload("res://shader/button_hover_style.tres"))

	var thumb := TextureRect.new()
	thumb.texture = THUMBNAILS[(n - 1) % THUMBNAILS.size()]
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.clip_contents = true
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	thumb.offset_left = 8
	thumb.offset_top = 8
	thumb.offset_right = -8
	thumb.offset_bottom = -44
	button.add_child(thumb)

	var label := Label.new()
	label.text = "LEVEL %d" % n
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_top = -44
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
		door.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		door.offset_left = -32
		door.offset_right = 32
		door.offset_top = -66
		door.offset_bottom = 30
		button.add_child(door)
	return button


func _on_back_pressed() -> void:
	SceneManager.change_scene("main_menu")
