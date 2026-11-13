
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


func _ready() -> void:
	player = get_node(player_path) as CharacterBody2D

	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false

	zoom = Vector2(camera_zoom, camera_zoom)

	# Determine the starting room only once.
	var relative_position: Vector2 = player.global_position - room_offset

	current_room = Vector2i(
		floori(relative_position.x / room_width),
		floori(relative_position.y / room_height)
	)

	_move_to_room()


func _physics_process(_delta: float) -> void:
	_check_room_transition()


func _check_room_transition() -> void:
	if player == null:
		return

	# Calculate the boundaries of the current room.
	var room_left: float = room_offset.x + current_room.x * room_width
	var room_right: float = room_left + room_width

	var room_top: float = room_offset.y + current_room.y * room_height
	var room_bottom: float = room_top + room_height

	var new_room: Vector2i = current_room

	# Only change rooms when the player crosses an actual boundary.
	if player.global_position.x >= room_right:
		new_room.x += 1
	elif player.global_position.x < room_left:
		new_room.x -= 1

	if player.global_position.y >= room_bottom:
		new_room.y += 1
	elif player.global_position.y < room_top:
		new_room.y -= 1

	if new_room != current_room:
		current_room = new_room
		_move_to_room()


func _move_to_room() -> void:
	global_position = room_offset + Vector2(
		(current_room.x + 0.5) * room_width,
		(current_room.y + 0.5) * room_height
	)

	print("Current room: ", current_room)
