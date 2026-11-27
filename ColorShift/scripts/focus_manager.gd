extends Node

## Shows the focus only while the menus are used with a controller or the keyboard.
##
## With the mouse, the focused control keeps the focus but hides it, and hovering
## is what highlights the buttons. With a controller or the keyboard it is the
## other way around, so there is never more than one button highlighted.
##
## Registered in project.godot as the "FocusManager" autoload.

const MenuStyle := preload("res://scripts/menu_style.gd")

const NAVIGATION_ACTIONS: Array[StringName] = [
	&"ui_up", &"ui_down", &"ui_left", &"ui_right",
	&"ui_focus_next", &"ui_focus_prev", &"ui_accept",
]
## A stick drifting below this does not count as using the controller.
const STICK_THRESHOLD := 0.5
## Mouse movements shorter than this (in pixels) are ignored.
const MOUSE_THRESHOLD := 1.0
## Resizing the window (full screen) moves the mouse without the player doing it.
const RESIZE_COOLDOWN_MS := 200

var is_focus_shown := false

var _reveal_event: InputEvent
var _last_resize_ms := -RESIZE_COOLDOWN_MS


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# window_input also sees the events that menus consume, such as pause.
	get_window().window_input.connect(_on_window_input)
	get_window().size_changed.connect(_on_window_size_changed)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_set_focus_shown(not Input.get_connected_joypads().is_empty())


func _input(event: InputEvent) -> void:
	# The press that brings the focus back only shows it: it does not move or click.
	if event == _reveal_event:
		_reveal_event = null
		get_viewport().set_input_as_handled()


func _on_window_input(event: InputEvent) -> void:
	if _is_pointer_event(event):
		_set_focus_shown(false)
		return

	var is_navigation := _is_navigation_event(event)
	if is_navigation or _is_controller_event(event):
		if is_navigation and not is_focus_shown and get_viewport().gui_get_focus_owner() != null:
			_reveal_event = event
		_set_focus_shown(true)


func _is_pointer_event(event: InputEvent) -> bool:
	if event is InputEventMouseMotion:
		return event.relative.length() > MOUSE_THRESHOLD \
				and Time.get_ticks_msec() - _last_resize_ms > RESIZE_COOLDOWN_MS
	return (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed


func _is_controller_event(event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		return absf(event.axis_value) >= STICK_THRESHOLD
	return event is InputEventJoypadButton and event.pressed


func _is_navigation_event(event: InputEvent) -> bool:
	return NAVIGATION_ACTIONS.any(func(action: StringName) -> bool:
		return event.is_action_pressed(action))


func _set_focus_shown(shown: bool) -> void:
	is_focus_shown = shown
	MenuStyle.set_hover_highlight(not shown)
	_apply_to(get_viewport().gui_get_focus_owner())


## Menus call grab_focus() when they open: hide that focus if the mouse is in use.
func _on_focus_changed(control: Control) -> void:
	_apply_to.call_deferred(control)


func _apply_to(control: Control) -> void:
	if is_instance_valid(control) and control.has_focus() and control.has_focus(true) != is_focus_shown:
		control.grab_focus(not is_focus_shown)


func _on_window_size_changed() -> void:
	_last_resize_ms = Time.get_ticks_msec()


func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if connected:
		_set_focus_shown(true)
	elif Input.get_connected_joypads().is_empty():
		_set_focus_shown(false)
