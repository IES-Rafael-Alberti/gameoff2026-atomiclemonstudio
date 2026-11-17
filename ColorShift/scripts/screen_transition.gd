extends CanvasLayer
## Capa de transicion tipo limpiaparabrisas (shader color-change.gdshader).
## El brazo pivota en la esquina inferior derecha y barre de vertical a horizontal.
##
## Se usa en el cambio de color con Shift (ver color_shift_controller.gd):
##   ScreenTransition.shift_color()
## tapa la pantalla con el color nuevo, cambia el color en el juego mientras esta tapada
## y destapa con otro barrido.

signal transition_finished

const COVER_TIME := 0.2
const REVEAL_TIME := 0.25

# Tinte del barrido segun el color al que se cambia.
const COLOR_TINTS := {
	"GREY": Color(0.5, 0.5, 0.5),
	"RED": Color(0.9, 0.2, 0.2),
	"BLUE": Color(0.2, 0.4, 0.95),
	"YELLOW": Color(0.97, 0.85, 0.2),
}

@onready var _rect: ColorRect = $ColorRect
@onready var _material: ShaderMaterial = _rect.material

var _tween: Tween
var _busy: bool = false


func _ready() -> void:
	# Debe seguir funcionando aunque el juego este en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# En reposo la capa esta transparente (progress 1, sin invertir) y no bloquea el raton.
	_material.set_shader_parameter("invert", false)
	_material.set_shader_parameter("progress", 1.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_busy() -> bool:
	return _busy


## Cambio de color con barrido: tapa, cambia el color del juego y destapa.
func shift_color() -> void:
	if _busy:
		return
	_busy = true
	var keys := GameManager.Colors.keys()
	var next_name: String = keys[(GameManager.actual_color_index + 1) % keys.size()]
	_rect.color = COLOR_TINTS.get(next_name, Color.BLACK)

	await wipe_in(COVER_TIME)
	GameManager.change_color()
	await wipe_out(REVEAL_TIME)
	_busy = false


## La zona barrida pasa a opaca: al terminar la pantalla queda tapada.
func wipe_in(duration: float = 0.6) -> void:
	await _play(true, duration)


## La zona barrida pasa a transparente: al terminar la pantalla queda visible.
func wipe_out(duration: float = 0.6) -> void:
	await _play(false, duration)


func _play(cover: bool, duration: float) -> void:
	if _tween:
		_tween.kill()
	# invert = true  -> progress 0 transparente, 1 opaco (tapar).
	# invert = false -> progress 0 opaco, 1 transparente (destapar).
	_material.set_shader_parameter("invert", cover)
	_material.set_shader_parameter("progress", 0.0)
	_tween = create_tween()
	_tween.tween_method(_set_progress, 0.0, 1.0, duration)
	await _tween.finished
	transition_finished.emit()


func _set_progress(value: float) -> void:
	_material.set_shader_parameter("progress", value)
