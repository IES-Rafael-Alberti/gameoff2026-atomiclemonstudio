extends Control

const MenuStyle := preload("res://scripts/menu_style.gd")

@onready var options_menu: Control = $OptionsMenu
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var title: TextureRect = $Title

const BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/general/castle-background.png"),
]

@onready var background: TextureRect = $TextureRect

## El menú va en 16:9 para que castle-background.png ocupe todo el ancho.
## El juego sigue en 4:3: el tamaño original se recupera al salir.
const MENU_CONTENT_SIZE := Vector2i(1366, 768)

var current_background_index := -1
var _original_content_size := Vector2i.ZERO

func _ready() -> void:
	theme = MenuStyle.get_theme()
	var window := get_window()
	_original_content_size = window.content_scale_size
	window.content_scale_size = MENU_CONTENT_SIZE

	_change_background()
	options_menu.back_requested.connect(_on_options_back_requested)
	$VBoxContainer/Play.grab_focus() # Pilla el input con el que estés tocando. Hace saltos entre ellos.

func _exit_tree() -> void:
	if _original_content_size != Vector2i.ZERO:
		get_window().content_scale_size = _original_content_size

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
		title.visible = v_box_container.visible
		options_menu.visible = !options_menu.visible

func _on_options_back_requested() -> void:
	options_menu.visible = false
	v_box_container.visible = true
	title.visible = true
	$VBoxContainer/Play.grab_focus() # Pilla el input con el que estés tocando. Hace saltos entre ellos.
