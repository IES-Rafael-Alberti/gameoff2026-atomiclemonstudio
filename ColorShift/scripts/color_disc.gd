extends CanvasLayer
## Ruedas de color del HUD, como ayuda para daltonicos ademas de los filtros.
## Derecha: rueda 1 (Right Shift). Izquierda: rueda 2 (Left Shift), visible al
## conseguirla en el nivel 4. El color activo es el de arriba. Cada sprite tiene
## 8 fotogramas de 32 px: los pares son los 4 colores y los impares el giro.
## Se crea desde color_shift_controller.gd, asi solo existe dentro de los niveles.

const SPRITES := {
	1: preload("res://assets/ui/Wheel_Right_Turn.png"),
	2: preload("res://assets/ui/Wheel_Left_Turn.png"),
}
const FRAME_PX := 32
const SIZE := 64.0
const MARGIN := 16.0

# Wheel -> TextureRect and wheel -> step currently drawn.
var _discs: Dictionary = {}
var _steps: Dictionary = {}


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS

	for wheel in SPRITES:
		var atlas := AtlasTexture.new()
		atlas.atlas = SPRITES[wheel]

		var disc := TextureRect.new()
		disc.texture = atlas
		disc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if wheel == 1:
			disc.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			disc.offset_left = -SIZE - MARGIN
			disc.offset_right = -MARGIN
		else:
			disc.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
			disc.offset_left = MARGIN
			disc.offset_right = MARGIN + SIZE
		disc.offset_top = MARGIN
		disc.offset_bottom = MARGIN + SIZE
		add_child(disc)

		_discs[wheel] = disc
		_steps[wheel] = GameManager.get_wheel_step(wheel)
		_show_frame(wheel, _steps[wheel] * 2)

	_discs[2].visible = GameManager.has_second_wheel
	GameManager.color_changed.connect(_on_color_changed)


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)


func _on_color_changed(_color: String) -> void:
	if GameManager.has_second_wheel and not _discs[2].visible:
		# Just collected: it appears already on its start color.
		_discs[2].visible = true
		_steps[2] = GameManager.get_wheel_step(2)
		_show_frame(2, _steps[2] * 2)

	for wheel in _discs:
		var step := GameManager.get_wheel_step(wheel)
		var from: int = _steps[wheel]
		if step == from:
			continue

		_steps[wheel] = step
		if step != (from + 1) % 4:
			_show_frame(wheel, step * 2)
			continue

		# One turn: in-between frame during the first half of the sweep.
		_show_frame(wheel, from * 2 + 1)
		get_tree().create_timer(ScreenTransition.SWEEP_TIME * 0.5).timeout.connect(
			_show_frame.bind(wheel, step * 2)
		)


func _show_frame(wheel: int, frame: int) -> void:
	var atlas := _discs[wheel].texture as AtlasTexture
	atlas.region = Rect2(frame * FRAME_PX, 0, FRAME_PX, FRAME_PX)
