extends Control

const BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/menu_background.jpg"),
	preload("res://assets/menu_background_2.jpg"),
	preload("res://assets/menu_background_3.jpg"),
	preload("res://assets/menu_background_4.jpg"),
]

@onready var background: TextureRect = $TextureRect

var current_background_index := -1

func _ready() -> void:
	_change_background()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shift"):
		_change_background()


func _change_background() -> void:
	current_background_index = (current_background_index + 1) % BACKGROUNDS.size()
	background.texture = BACKGROUNDS[current_background_index]


func _on_play_pressed() -> void:
	SceneManager.change_scene("demo_level")


func _on_quit_pressed() -> void:
	SceneManager.change_scene("credits")
