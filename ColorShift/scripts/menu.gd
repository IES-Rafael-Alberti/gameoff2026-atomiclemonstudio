extends Control
@onready var options_menu: Control = $OptionsMenu
@onready var v_box_container: VBoxContainer = $VBoxContainer

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
	
	if Input.is_action_just_pressed("pause") and options_menu.visible:
		options_menu.visible = false
		v_box_container.visible = true

func _change_background() -> void:
	current_background_index = (current_background_index + 1) % BACKGROUNDS.size()
	background.texture = BACKGROUNDS[current_background_index]

func _on_play_pressed() -> void:
	SceneManager.change_scene("demo_level")

func _on_quit_pressed() -> void:
	SceneManager.change_scene("credits")

func _on_options_menu_pressed() -> void:
	if options_menu:
		v_box_container.visible = !v_box_container.visible
		options_menu.visible = !options_menu.visible
