
extends Camera2D

@export_category("Room Dimensions")
@export var room_offset: Vector2 = Vector2.ZERO
@export var room_width: float = 1024.0
@export var room_height: float = 768.0

@export_category("Camera Settings")
@export_range(0.1, 3.0, 0.05) var camera_zoom: float = 1.0

@export_category("References")
@export var player_path: NodePath = ^"../Player"

var player: CharacterBody2D
var current_room := Vector2i.ZERO

# Rooms holding at least one tile of any color layer. The camera never moves
# into any other room and PlayerSafety restarts the level there.
var _rooms: Dictionary = {}


func _ready() -> void:
	player = get_node(player_path) as CharacterBody2D

	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false

	zoom = Vector2(camera_zoom, camera_zoom)

	for node in get_tree().get_nodes_in_group("tile_layers"):
		var layer := node as TileMapLayer
		for cell in layer.get_used_cells():
			_rooms[room_at(layer.to_global(layer.map_to_local(cell)))] = true

	current_room = room_at(player.global_position)
	_move_to_room()


func _physics_process(_delta: float) -> void:
	if player == null:
		return

	var new_room := room_at(player.global_position)

	if new_room != current_room and has_room(new_room):
		current_room = new_room
		_move_to_room()


func room_at(point: Vector2) -> Vector2i:
	var relative := point - room_offset
	return Vector2i(floori(relative.x / room_width), floori(relative.y / room_height))


func has_room(room: Vector2i) -> bool:
	return _rooms.is_empty() or _rooms.has(room)


## Used by PlayerSafety: rooms tile the world with no gaps, so moving between
## two rooms that hold tiles never counts as leaving the level.
func is_inside_level(point: Vector2) -> bool:
	return has_room(room_at(point))


func _move_to_room() -> void:
	global_position = room_offset + Vector2(
		(current_room.x + 0.5) * room_width,
		(current_room.y + 0.5) * room_height
	)

	print("Current room: ", current_room)
