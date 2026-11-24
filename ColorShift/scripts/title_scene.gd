extends Node2D
## Pantalla de arranque: reproduce el logo animado del estudio y pasa al menú.

@onready var _logo_player: AnimationPlayer = $LogoAnimated/AnimatedSprite2D/AnimationPlayer

var _leaving := false


func _ready() -> void:
	_logo_player.play("default")
	await _logo_player.animation_finished
	_go_to_menu()


# Cualquier tecla o botón salta la intro
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		_go_to_menu()


func _go_to_menu() -> void:
	if _leaving:
		return
	_leaving = true
	SceneManager.change_scene("main_menu")
