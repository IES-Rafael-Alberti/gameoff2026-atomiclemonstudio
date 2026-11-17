extends Control
@onready var options_menu: Control = $PanelContainer/OptionsMenu
@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and options_menu.visible:
		options_menu.visible = false
		v_box_container.visible = true

func pause():
	get_tree().paused =! get_tree().paused
	visible = get_tree().paused

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !options_menu.visible:
		pause()

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
