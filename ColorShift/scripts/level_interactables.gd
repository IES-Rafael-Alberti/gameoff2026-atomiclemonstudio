extends Node2D

# Key / barrier / door interactions for the tutorial level.

const KEY_FLAG := "KEY"
const BARRIER_FLAG := "BARRIER"
const DOOR_FLAG := "DOOR"
const KEY_TEXTURE: Texture2D = preload("res://assets/sprites/scenary/key.png")

@export var pickup_radius: float = 34.0
@export var interact_radius: float = 64.0
@export var follower_lerp: float = 9.0
@export var follower_offset: Vector2 = Vector2(-22.0, -28.0)

var has_key: bool = false

var _layer
var _player: CharacterBody2D
var _key_cells: Array[Vector2i] = []
var _barrier_cells: Array[Vector2i] = []
var _door_cells: Array[Vector2i] = []
var _barrier_open: bool = false
var _door_used: bool = false

var _follower: Sprite2D
var _hint: Label
var _message: Label
var _message_tween: Tween
var _time: float = 0.0

func _ready() -> void:
	_layer = get_parent().get_node("TileMapLayer")
	_player = get_parent().get_node("Player")
	_build_ui()
	_collect_cells()

func _collect_cells() -> void:
	for cell in _layer.get_used_cells():
		var data: TileData = _layer.get_cell_tile_data(cell)
		if data == null:
			continue
		if data.get_custom_data(KEY_FLAG):
			_key_cells.append(cell)
		if data.get_custom_data(BARRIER_FLAG):
			_barrier_cells.append(cell)
		if data.get_custom_data(DOOR_FLAG):
			_door_cells.append(cell)

func _process(delta: float) -> void:
	_time += delta
	_update_follower(delta)
	_try_pickup_key()
	_update_hint(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not _barrier_open and _near_any(_barrier_cells):
		if has_key:
			_open_barrier()
		else:
			_show_message("Necesitas la llave", 1.4)
		get_viewport().set_input_as_handled()
		return

	if not _door_used and _near_any(_door_cells):
		if has_key:
			_finish_tutorial()
		else:
			_show_message("Necesitas la llave", 1.4)
		get_viewport().set_input_as_handled()

func _try_pickup_key() -> void:
	if has_key or _key_cells.is_empty():
		return

	var key_position := _cell_center(_key_cells[0])
	if _player.global_position.distance_to(key_position) <= pickup_radius:
		_collect_key()

func _collect_key() -> void:
	has_key = true
	for cell in _key_cells:
		_layer.remove_tile(cell)
	_key_cells.clear()
	_spawn_follower()
	_show_message("¡Has cogido la llave!", 1.6)

func _spawn_follower() -> void:
	_follower = Sprite2D.new()
	_follower.texture = KEY_TEXTURE
	_follower.scale = Vector2(0.7, 0.7)
	_follower.modulate = Color(1.0, 0.92, 0.55)
	_follower.z_index = 5
	_follower.global_position = _player.global_position + follower_offset
	add_child(_follower)

func _update_follower(delta: float) -> void:
	if _follower == null or not is_instance_valid(_player):
		return

	var facing := 1.0
	var skin := _player.get_node_or_null("%PlayerSkin") as AnimatedSprite2D
	if skin and skin.flip_h:
		facing = -1.0

	var target := _player.global_position + Vector2(follower_offset.x * facing, follower_offset.y)
	target.y += sin(_time * 6.0) * 3.0
	_follower.global_position = _follower.global_position.lerp(target, clampf(follower_lerp * delta, 0.0, 1.0))

func _near_any(cells: Array[Vector2i]) -> bool:
	if cells.is_empty():
		return false
	for cell in cells:
		if _player.global_position.distance_to(_cell_center(cell)) <= interact_radius:
			return true
	return false

func _cell_center(cell: Vector2i) -> Vector2:
	return _layer.to_global(_layer.map_to_local(cell))

func _open_barrier() -> void:
	_barrier_open = true
	for cell in _barrier_cells:
		_layer.remove_tile(cell)
	_barrier_cells.clear()
	_show_message("¡Barrera abierta!", 1.8)

func _finish_tutorial() -> void:
	_door_used = true
	_show_message("¡Has superado el tutorial con éxito!", 4.0)
	SceneManager.change_scene("level_1")

func _update_hint(delta: float) -> void:
	var text := ""
	if not _barrier_open and _near_any(_barrier_cells):
		text = "E  Abrir barrera" if has_key else "Necesitas la llave"
	elif not _door_used and _near_any(_door_cells):
		text = "E  Abrir puerta" if has_key else "Necesitas la llave"

	_hint.text = text
	var target_alpha := 1.0 if text != "" else 0.0
	_hint.modulate.a = move_toward(_hint.modulate.a, target_alpha, delta * 6.0)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	_message = Label.new()
	_message.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 40)
	_message.add_theme_color_override("font_color", Color.WHITE)
	_message.add_theme_color_override("font_outline_color", Color.BLACK)
	_message.add_theme_constant_override("outline_size", 10)
	_message.modulate.a = 0.0
	canvas.add_child(_message)

	_hint = Label.new()
	_hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_hint.offset_bottom = -56.0
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.add_theme_color_override("font_color", Color.WHITE)
	_hint.add_theme_color_override("font_outline_color", Color.BLACK)
	_hint.add_theme_constant_override("outline_size", 7)
	_hint.modulate.a = 0.0
	canvas.add_child(_hint)

func _show_message(text: String, duration: float) -> void:
	_message.text = text
	_message.modulate.a = 1.0

	if _message_tween and _message_tween.is_valid():
		_message_tween.kill()

	_message_tween = create_tween()
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(_message, "modulate:a", 0.0, 0.45)
