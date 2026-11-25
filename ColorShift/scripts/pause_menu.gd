extends Control

const MenuStyle := preload("res://scripts/menu_style.gd")

@onready var options_menu: Control = $PanelContainer/OptionsMenu
@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer

func _ready() -> void:
	theme = MenuStyle.get_theme()
	options_menu.back_requested.connect(_on_options_back_requested)

func pause():
	get_tree().paused =! get_tree().paused
	visible = get_tree().paused
	if visible:
		$PanelContainer/VBoxContainer/Continue.grab_focus()

func _input(event: InputEvent) -> void:
	if options_menu.visible:
		return
	if event.is_action_pressed("pause") or (visible and event.is_action_pressed("ui_cancel")):
		pause()
		get_viewport().set_input_as_handled()

func _on_continue_pressed() -> void:
	pause()

func _on_reset_level_pressed() -> void:
	get_tree().paused = false
	SceneManager.reload_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene("main_menu")

func _on_quit_game_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene("credits")

func _on_options_menu_pressed() -> void:
	if options_menu and v_box_container:
		v_box_container.visible = !v_box_container.visible
		options_menu.visible = !options_menu.visible

func _on_options_back_requested() -> void:
	options_menu.visible = false
	v_box_container.visible = true
	$PanelContainer/VBoxContainer/OptionsMenu.grab_focus()
