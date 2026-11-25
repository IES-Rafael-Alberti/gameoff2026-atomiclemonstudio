extends Node2D
## Pantalla de arranque: reproduce el logo animado del estudio y pasa al menú.

# Tamaño lógico 16:9 solo para esta pantalla. El juego sigue en 1024x768 (4:3).
const TITLE_CONTENT_SIZE := Vector2i(1366, 768)

@onready var _logo_player: AnimationPlayer = $LogoAnimated/AnimatedSprite2D/AnimationPlayer

var _leaving := false
var _original_content_size := Vector2i.ZERO


func _ready() -> void:
	var window := get_window()
	_original_content_size = window.content_scale_size
	window.content_scale_size = TITLE_CONTENT_SIZE

	_logo_player.play("default")
	await _logo_player.animation_finished
	_go_to_menu()


# Se ejecuta cuando la escena se libera, ya con la pantalla en negro por el fundido
func _exit_tree() -> void:
	if _original_content_size != Vector2i.ZERO:
		get_window().content_scale_size = _original_content_size


# Cualquier tecla o botón salta la intro
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		_go_to_menu()


func _go_to_menu() -> void:
	if _leaving:
		return
	_leaving = true
	SceneManager.change_scene("main_menu")
