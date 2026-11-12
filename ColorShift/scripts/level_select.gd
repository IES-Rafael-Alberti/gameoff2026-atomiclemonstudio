extends Control

## Level select shown after finishing a level. Add a level here when its
## scene is registered in SceneManager.SCENES.
const LEVELS := {
	1: "demo_level",
}
const LEVEL_COUNT := 8 # See planning/wiki/Levels.md

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer


func _ready() -> void:
	for n in range(1, LEVEL_COUNT + 1):
		var button := Button.new()
		button.text = "LEVEL %d" % n
		button.custom_minimum_size = Vector2(0, 64)
		button.add_theme_font_size_override("font_size", 32)
		for style in ["normal", "disabled"]:
			button.add_theme_stylebox_override(style, preload("res://shader/button_style.tres"))
		button.add_theme_stylebox_override("pressed", preload("res://shader/button_pressed_style.tres"))
		button.add_theme_stylebox_override("hover", preload("res://shader/button_hover_style.tres"))
		button.disabled = not LEVELS.has(n)
		if not button.disabled:
			button.pressed.connect(SceneManager.change_scene.bind(LEVELS[n]))
		grid.add_child(button)


func _on_back_pressed() -> void:
	SceneManager.change_scene("main_menu")
