extends CanvasLayer
## Barra de escobilla del cambio de color (wiper_bar.gdshader).
## Pivota en la esquina inferior derecha y gira de vertical a horizontal.
##
## Se usa en el cambio de color con Shift (ver color_shift_controller.gd):
##   ScreenTransition.shift_color()
## La barra solo se dibuja; el cambio de color de los tiles lo hace cada capa con
## tile_wiper_reveal.gdshader al recibir sweep_started (ver tile_map_manager.gd).

signal sweep_started(old_color: String, new_color: String)
signal sweep_finished

const SWEEP_TIME := 0.35

# Tinte de la barra segun el color al que se cambia.
const COLOR_TINTS := {
	"GREY": Color(0.5, 0.5, 0.5),
	"RED": Color(0.9, 0.2, 0.2),
	"BLUE": Color(0.2, 0.4, 0.95),
	"YELLOW": Color(0.97, 0.85, 0.2),
}

@onready var _material: ShaderMaterial = $ColorRect.material

# 0 = barra vertical, 1 = horizontal. 1 en reposo. Tambien es el shader global wiper_progress.
var progress: float = 1.0
var _tween: Tween
var _busy: bool = false


func _ready() -> void:
	# Debe seguir funcionando aunque el juego este en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_progress(1.0)


func is_busy() -> bool:
	return _busy


## Cambio de color: la barra barre la pantalla y los tiles se actualizan a su paso.
func shift_color() -> void:
	if _busy:
		return
	_busy = true
	var keys := GameManager.Colors.keys()
	var old_name: String = GameManager.get_color_name()
	var new_name: String = keys[(GameManager.actual_color_index + 1) % keys.size()]
	_material.set_shader_parameter("tint", COLOR_TINTS.get(new_name, Color.WHITE))

	_set_progress(0.0)
	sweep_started.emit(old_name, new_name)
	# La colision cambia al empezar el barrido: el juego responde al instante.
	GameManager.change_color()
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_method(_set_progress, 0.0, 1.0, SWEEP_TIME)
	await _tween.finished
	_set_progress(1.0)

	sweep_finished.emit()
	_busy = false


func _set_progress(value: float) -> void:
	progress = value
	RenderingServer.global_shader_parameter_set("wiper_progress", value)
