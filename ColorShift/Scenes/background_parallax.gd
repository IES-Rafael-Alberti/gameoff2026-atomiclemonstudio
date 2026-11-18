
extends Node2D

@export var player: Node2D
@export var camera: Camera2D

@export var layer_speeds: Array[float] = [
	1.0,
	0.96,
	0.93,
	0.90,
	1.0,
	1.0,
	1.0,
	0.93
]

var parallax_layers: Array[Parallax2D] = []
var initial_positions: Array[Vector2] = []

var last_player_x: float
var camera_offset: Vector2


func _ready():
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
	camera_offset = camera.get_screen_center_position()


func _process(_delta):
	if player == null or camera == null:
		return

	# Detect player horizontal movement.
	var player_delta_x = player.global_position.x - last_player_x

	# Detect camera movement (including room transitions).
	var current_camera_position = camera.get_screen_center_position()
	var camera_delta = current_camera_position - camera_offset

	for i in range(parallax_layers.size()):
		if i >= layer_speeds.size():
			continue

		var layer = parallax_layers[i]
		var speed = layer_speeds[i]

		# Camera movement carries the whole parallax.
		layer.position.x += camera_delta.x

		# Player movement creates the depth effect.
		layer.position.x -= player_delta_x * (1.0 - speed)

		# Never move vertically.
		layer.position.y = initial_positions[i].y

	last_player_x = player.global_position.x
	camera_offset = current_camera_position
