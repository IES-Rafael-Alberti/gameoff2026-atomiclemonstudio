extends CanvasLayer
## Disco indicador del color actual en la esquina superior derecha, como ayuda
## para daltonicos ademas de los filtros. El color activo queda siempre en el
## cuadrante de arriba a la derecha; con cada Shift el disco gira un cuadrante.
## Se crea desde color_shift_controller.gd, asi solo existe dentro de los niveles.

const TEXTURE := preload("res://assets/ui/color_disc.svg")
const SIZE := 48.0

var _disc: TextureRect


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS

	_disc = TextureRect.new()
	_disc.texture = TEXTURE
	_disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_disc.size = Vector2(SIZE, SIZE)
	_disc.pivot_offset = _disc.size * 0.5
	_disc.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_disc.offset_left = -SIZE - 16.0
	_disc.offset_right = -16.0
	_disc.offset_top = 16.0
	_disc.offset_bottom = 16.0 + SIZE
	_disc.rotation = -PI * 0.5 * GameManager.actual_color_index
	add_child(_disc)

	ScreenTransition.sweep_started.connect(_on_sweep_started)


func _on_sweep_started(_old_color: String, _new_color: String) -> void:
	# Relativo, para no girar hacia atras al volver de YELLOW a GREY.
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT) \
		.tween_property(_disc, "rotation", _disc.rotation - PI * 0.5, ScreenTransition.SWEEP_TIME)
