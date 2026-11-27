extends Control

signal back_requested

const MenuStyle := preload("res://scripts/menu_style.gd")

@onready var remap_menu: Control = $RemapMenu
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer
@onready var remap_menu_button: Button = $Panel/VBoxContainer/RemapMenuButton
@onready var back_button: Button = $Panel/VBoxContainer/NavigationButtons/BackButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = MenuStyle.get_options_theme()
	# The big title needs a thicker outline than the rest of the text.
	$Panel/VBoxContainer/Label.add_theme_constant_override("outline_size", 14)
	remap_menu.visible = false
	remap_menu.back_pressed.connect(_on_remap_menu_back_pressed)
	remap_menu_button.pressed.connect(_on_controls_button_pressed)
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	# Panel art behind the column of options; hidden while the remap menu is open.
	$Panel.draw.connect(_draw_background)
	v_box_container.item_rect_changed.connect($Panel.queue_redraw)
	v_box_container.visibility_changed.connect($Panel.queue_redraw)


func _draw_background() -> void:
	if v_box_container.visible:
		var rect := v_box_container.get_rect().grow_individual(40, 24, 40, 48)
		MenuStyle.get_panel_box(MenuStyle.OPTIONS_PANEL).draw($Panel.get_canvas_item(), rect)


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
	remap_menu_button.grab_focus()


func _on_back_pressed() -> void:
	back_requested.emit()
	
func _is_back_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")
	
func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		$Panel/VBoxContainer/FullScreenControl.grab_focus()
