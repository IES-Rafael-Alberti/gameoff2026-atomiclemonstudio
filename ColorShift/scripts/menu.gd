extends Control

func _on_play_pressed() -> void:
	SceneManager.change_scene("demo_level")


func _on_quit_pressed() -> void:
	SceneManager.change_scene("credits")
