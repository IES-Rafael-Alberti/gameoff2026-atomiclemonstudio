extends Control

@export var player: Node2D
@export var camera: Camera2D

@export var layer_speeds: Array[float] = [
	1.0,
	0.96,
	0.93,
	0.90,
	1.0,
	1.0,
	0.9,
	0.93
]

var parallax_layers: Array[Parallax2D] = []
var initial_positions: Array[Vector2] = []

var last_player_x: float
var player_offset_x: float = 0.0


func _ready() -> void:
	if player == null or camera == null:
		push_error("Assign Player and Camera in the Inspector!")
		return

	for child in get_children():
		if child is Parallax2D:
			parallax_layers.append(child)
			initial_positions.append(child.position)

			# Disable automatic camera parallax.
			child.follow_viewport = false

	last_player_x = player.global_position.x


func _process(_delta: float) -> void:
	if player == null or camera == null:
		return

	# Detect player horizontal movement.
	var player_delta_x: float = player.global_position.x - last_player_x

	# Accumulate the parallax effect caused by player movement.
	player_offset_x += player_delta_x

	# Get the actual camera center in world coordinates.
	var camera_center: Vector2 = camera.get_screen_center_position()

	for i in range(parallax_layers.size()):
		if i >= layer_speeds.size():
			continue

		var layer: Parallax2D = parallax_layers[i]
		var speed: float = layer_speeds[i]

		# Keep the parallax centered on the camera.
		var target_x: float = camera_center.x - player_offset_x * (1.0 - speed)

		layer.global_position.x = target_x
		layer.global_position.y = camera_center.y + initial_positions[i].y

	last_player_x = player.global_position.x
