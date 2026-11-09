extends Control

func pause():
	get_tree().paused =! get_tree().paused
	visible = get_tree().paused

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
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
