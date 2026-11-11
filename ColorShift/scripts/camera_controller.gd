
extends Camera2D

@export_category("Room Dimensions")

@export var room_width: float = 640.0
@export var room_height: float = 360.0

@export_category("Camera Settings")

# 1.0 = normal zoom.
# 0.5 = see twice as much world.
# 2.0 = see half as much world.
@export_range(0.1, 3.0, 0.05) var camera_zoom: float = 1.0

@export_category("References")

@export var player_path: NodePath = ^"../Player"

var player: CharacterBody2D
var current_room := Vector2i(999999, 999999)


func _ready() -> void:
	player = get_node(player_path) as CharacterBody2D

	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false

	zoom = Vector2(camera_zoom, camera_zoom)

	update_room(true)


func _physics_process(_delta: float) -> void:
	update_room()


func update_room(force: bool = false) -> void:
	if player == null:
		return

	var room_index := Vector2i(
		floori(player.global_position.x / room_width),
		floori(player.global_position.y / room_height)
	)

	if room_index == current_room and not force:
		return

	current_room = room_index

	global_position = Vector2(
		(room_index.x + 0.5) * room_width,
		(room_index.y + 0.5) * room_height
	)

	print("Current room: ", current_room)
