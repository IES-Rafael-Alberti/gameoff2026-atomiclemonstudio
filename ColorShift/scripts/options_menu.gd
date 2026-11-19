extends Control

signal back_requested

@onready var remap_menu: Control = $RemapMenu
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer
@onready var remap_menu_button: Button = $Panel/VBoxContainer/RemapMenuButton
@onready var back_button: Button = $Panel/VBoxContainer/NavigationButtons/BackButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	remap_menu.visible = false
	remap_menu.back_pressed.connect(_on_remap_menu_back_pressed)
	remap_menu_button.pressed.connect(_on_controls_button_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _is_back_event(event):
		return

	get_viewport().set_input_as_handled()
	if remap_menu.visible:
		_on_remap_menu_back_pressed()
	else:
		back_requested.emit()

func _on_controls_button_pressed() -> void:
	if remap_menu and v_box_container:
		v_box_container.visible = !v_box_container.visible
		remap_menu.visible = !remap_menu.visible

func _on_remap_menu_back_pressed() -> void:
	remap_menu.visible = false
	v_box_container.visible = true

func _on_back_pressed() -> void:
	back_requested.emit()

func _is_back_event(event: InputEvent) -> bool:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return false
	return event.physical_keycode == KEY_ESCAPE or event.physical_keycode == KEY_P
