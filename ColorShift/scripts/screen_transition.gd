extends CanvasLayer
## Barra de escobilla del cambio de color (wiper_bar.gdshader).
## Pivota en la esquina inferior derecha y gira de vertical a horizontal.
##
## Se usa en el cambio de color con Shift (ver color_shift_controller.gd):
##   ScreenTransition.shift_color(1)  # Rueda principal
##   ScreenTransition.shift_color(2)  # Rueda secundaria
## Cambia el color en GameManager al empezar y los TileMapLayer reciben
## sweep_started/sweep_finished para revelar sus capas de color con
## tile_wiper_reveal.gdshader (ver tile_map_manager.gd).

signal sweep_started(old_color: String, new_color: String)
signal sweep_finished

## Sonido del barrido (asignalo en screen_transition.tscn). Vacio = sin sonido.
@export var sweep_sound: AudioStream

const SWEEP_TIME := 0.35
const SHAKE_PX := 4.0
const SHAKE_STEPS := 6

# Tinte de la barra segun el color al que se cambia.
const COLOR_TINTS := {
	"GREY": Color(0.5, 0.5, 0.5),
	"RED": Color(0.9, 0.2, 0.2),
	"BLUE": Color(0.2, 0.4, 0.95),
	"YELLOW": Color(0.97, 0.85, 0.2),
	"ORANGE": Color(1.0, 0.55, 0.1),
	"PURPLE": Color(0.65, 0.25, 0.85),
	"GREEN": Color(0.25, 0.75, 0.35),
}

@onready var _material: ShaderMaterial = $ColorRect.material

# 0 = barra vertical, 1 = horizontal. 1 en reposo. Tambien es el shader global wiper_progress.
var progress: float = 1.0
var _tween: Tween
var _busy: bool = false
var _sound_player: AudioStreamPlayer


func _ready() -> void:
	# Debe seguir funcionando aunque el juego este en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_progress(1.0)

	_sound_player = AudioStreamPlayer.new()
	_sound_player.bus = "SFX"
	add_child(_sound_player)


func is_busy() -> bool:
	return _busy


## Cambio de color: la barra barre la pantalla y los tiles se actualizan a su paso.
func shift_color(wheel: int) -> void:
	sweep(GameManager.change_color.bind(wheel))


## Barrido que aplica `change` (un cambio de color en GameManager) al empezar.
func sweep(change: Callable) -> void:
	if _busy:
		return
	_busy = true
	var old_name: String = GameManager.get_color_name()

	_play_sweep_sound()
	_set_progress(0.0)
	# El barrido dispara el cambio: la colision cambia ya y el shader revela los tiles.
	change.call()
	var new_name: String = GameManager.get_color_name()
	_material.set_shader_parameter("tint", COLOR_TINTS.get(new_name, Color.WHITE))
	sweep_started.emit(old_name, new_name)
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_method(_set_progress, 0.0, 1.0, SWEEP_TIME)
	await _tween.finished
	_set_progress(1.0)
	_shake()

	# Free first, so whoever waits for sweep_finished can sweep again.
	_busy = false
	sweep_finished.emit()


func _set_progress(value: float) -> void:
	progress = value
	RenderingServer.global_shader_parameter_set("wiper_progress", value)


# Pequeno temblor de la camara al terminar el barrido.
func _shake() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var shake := create_tween()
	for i in SHAKE_STEPS:
		var strength := SHAKE_PX * (1.0 - float(i) / SHAKE_STEPS)
		shake.tween_property(camera, "offset", Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength, 0.03)
	shake.tween_property(camera, "offset", Vector2.ZERO, 0.03)


func _play_sweep_sound() -> void:
	if sweep_sound == null:
		return
	_sound_player.stream = sweep_sound
	_sound_player.play()
