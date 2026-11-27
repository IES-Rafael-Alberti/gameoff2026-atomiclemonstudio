@tool
extends Node2D

## Tick "Preview 16 9" in the inspector to see and edit the main menu in the
## editor at the size it has in game (1366x768).
##
## It only stretches the parent menu while ticked: other scenes and the project
## settings are not touched, the stretched size is never saved, and it does
## nothing while playing.

const Menu := preload("res://scripts/menu.gd")
const FRAME_COLOR := Color(1.0, 0.85, 0.2)

# PROPERTY_USAGE_EDITOR without storage: the check is not written to the scene.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR) var preview_16_9 := false:
	set(value):
		preview_16_9 = value and _is_edited_menu()
		if Engine.is_editor_hint() and get_parent() is Control:
			_stretch_menu(preview_16_9)


func _notification(what: int) -> void:
	if not preview_16_9:
		return
	# Save the menu with its real size, then bring the preview back.
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_stretch_menu(false)
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_stretch_menu(true)


func _draw() -> void:
	if preview_16_9:
		draw_rect(Rect2(Vector2.ZERO, Vector2(Menu.MENU_CONTENT_SIZE)), FRAME_COLOR, false, 2.0)


# True only while main_menu.tscn itself is the scene being edited.
func _is_edited_menu() -> bool:
	return Engine.is_editor_hint() and is_inside_tree() \
			and get_parent() is Control and get_tree().edited_scene_root == get_parent()


func _stretch_menu(stretched: bool) -> void:
	var menu := get_parent() as Control
	var base_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	menu.offset_right = Menu.MENU_CONTENT_SIZE.x - base_width if stretched else 0.0
	queue_redraw()
