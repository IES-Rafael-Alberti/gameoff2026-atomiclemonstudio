extends CanvasLayer
## Ruedas de color del HUD, como ayuda para daltonicos ademas de los filtros.
## Derecha: rueda 1 (Right Shift). Izquierda: rueda 2 (Left Shift), visible desde
## el nivel 4. El color activo es el de arriba. Cada sprite tiene
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
var _cooldown_labels: Dictionary = {}


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

		var cooldown_label := Label.new()
		cooldown_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		cooldown_label.offset_left = -24
		cooldown_label.offset_right = 24
		cooldown_label.offset_top = -12
		cooldown_label.offset_bottom = 12
		cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cooldown_label.add_theme_font_size_override("font_size", 16)
		cooldown_label.add_theme_color_override("font_color", Color.WHITE)
		cooldown_label.add_theme_color_override("font_outline_color", Color.BLACK)
		cooldown_label.add_theme_constant_override("outline_size", 4)
		cooldown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		disc.add_child(cooldown_label)

		_discs[wheel] = disc
		_steps[wheel] = GameManager.get_wheel_step(wheel)
		_cooldown_labels[wheel] = cooldown_label
		_show_frame(wheel, _steps[wheel] * 2)

	_discs[2].visible = GameManager.can_use_second_wheel()
	GameManager.color_changed.connect(_on_color_changed)
	GameManager.shift_cooldown_changed.connect(_on_shift_cooldown_changed)
	_on_shift_cooldown_changed(GameManager.shift_cooldown_remaining)


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)
	if GameManager.shift_cooldown_changed.is_connected(_on_shift_cooldown_changed):
		GameManager.shift_cooldown_changed.disconnect(_on_shift_cooldown_changed)


func _on_shift_cooldown_changed(remaining: float) -> void:
	var show_timer := GameManager.current_level_number == 8 and remaining > 0.0
	for wheel in _cooldown_labels:
		var label := _cooldown_labels[wheel] as Label
		label.visible = show_timer
		if show_timer:
			label.text = "%.1f" % remaining


func _on_color_changed(_color: String) -> void:
	if GameManager.can_use_second_wheel() and not _discs[2].visible:
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
