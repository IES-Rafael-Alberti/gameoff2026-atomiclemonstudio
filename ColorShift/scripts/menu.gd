extends Control
@onready var options_menu: Control = $OptionsMenu
@onready var v_box_container: VBoxContainer = $VBoxContainer

const BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/general/castle-background.png"),
]

@onready var background: TextureRect = $TextureRect

var current_background_index := -1

func _ready() -> void:
	_change_background()
	options_menu.back_requested.connect(_on_options_back_requested)
	$VBoxContainer/Play.grab_focus() # Pilla el input con el que estés tocando. Hace saltos entre ellos.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shift"):
		_change_background()

func _change_background() -> void:
	current_background_index = (current_background_index + 1) % BACKGROUNDS.size()
	background.texture = BACKGROUNDS[current_background_index]

func _on_play_pressed() -> void:
	SceneManager.change_scene("level_select")

func _on_quit_pressed() -> void:
	SceneManager.change_scene("credits")

func _on_options_menu_pressed() -> void:
	if options_menu:
		v_box_container.visible = !v_box_container.visible
		options_menu.visible = !options_menu.visible

func _on_options_back_requested() -> void:
	options_menu.visible = false
	v_box_container.visible = true
	$VBoxContainer/Play.grab_focus() # Pilla el input con el que estés tocando. Hace saltos entre ellos.
