extends CanvasLayer
## Ruedas de color del HUD, como ayuda para daltonicos ademas de los filtros.
## Derecha: rueda 1 (Right Shift). Izquierda: rueda 2 (Left Shift), visible al
## conseguirla en level_color_test. El color activo es el de arriba. Cada sprite tiene
## 8 fotogramas de 32 px: los pares son los 4 colores y los impares el giro.
## Se crea desde color_shift_controller.gd, asi solo existe dentro de los niveles.
##
## Los niveles se ven en 16:9: el juego 4:3 centrado y las barras laterales a los
## lados. Cada disco se centra en el borde del juego y solo se ve su mitad exterior,
## como si pasara por debajo del juego (barras < discos < juego). Van girados 90
## grados hacia fuera para que el color activo (el de arriba) se vea entero.

const SPRITES := {
	1: preload("res://assets/ui/Wheel_Right_Turn.png"),
	2: preload("res://assets/ui/Wheel_Left_Turn.png"),
}
const BARS := preload("res://assets/ui/ui-lateral-bars.png")
const FRAME_PX := 32
# On-screen disc size: a whole multiple of FRAME_PX (8x).
const SIZE := 256.0
const MARGIN := 16.0
# 16:9 screen of the levels; the 1024 px wide game sits in the middle (x 171-1195).
const LEVEL_CONTENT_SIZE := Vector2i(1366, 768)
const GAME_WIDTH := 1024.0

# Wheel -> TextureRect and wheel -> step currently drawn.
var _discs: Dictionary = {}
var _steps: Dictionary = {}
var _original_content_size := Vector2i.ZERO


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	var window := get_window()
	_original_content_size = window.content_scale_size
	window.content_scale_size = LEVEL_CONTENT_SIZE

	# Opaque bars with a transparent 1024 px centre: they also hide the
	# neighbouring rooms that the wider view would show.
	var bars := TextureRect.new()
	bars.texture = BARS
	bars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bars)

	var bar_width := (LEVEL_CONTENT_SIZE.x - GAME_WIDTH) * 0.5
	for wheel in SPRITES:
		var atlas := AtlasTexture.new()
		atlas.atlas = SPRITES[wheel]

		var disc := TextureRect.new()
		disc.texture = atlas
		disc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		disc.size = Vector2(SIZE, SIZE)
		disc.pivot_offset = disc.size * 0.5
		# Turned outwards: the active (top) slot ends on the outer side.
		disc.rotation_degrees = 90.0 if wheel == 1 else -90.0

		# Clipped to its bar, so the half over the game is cut at the seam.
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.position.x = bar_width + GAME_WIDTH if wheel == 1 else 0.0
		clip.size = Vector2(bar_width, LEVEL_CONTENT_SIZE.y)
		var seam := bar_width + GAME_WIDTH if wheel == 1 else bar_width
		disc.position = Vector2(seam - clip.position.x - SIZE * 0.5, MARGIN)
		clip.add_child(disc)
		add_child(clip)

		_discs[wheel] = disc
		_steps[wheel] = GameManager.get_wheel_step(wheel)
		_show_frame(wheel, _steps[wheel] * 2)

	_discs[2].visible = GameManager.has_second_wheel
	GameManager.color_changed.connect(_on_color_changed)


func _exit_tree() -> void:
	if _original_content_size != Vector2i.ZERO:
		get_window().content_scale_size = _original_content_size
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
