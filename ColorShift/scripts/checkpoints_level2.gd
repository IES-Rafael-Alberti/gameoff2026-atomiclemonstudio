
extends Node

@export var player: CharacterBody2D

# Room definitions
# Each room has:
# - Minimum X and Y coordinates
# - Maximum X and Y coordinates
# - Respawn position

var rooms = [
	{
		"name": "Room 1",
		"min_x": -512.0,
		"max_x": 512.0,
		"min_y": -384.0,
		"max_y": 384.0,
		"spawn": Vector2(-439, 159)
	},
	{
		"name": "Room 2",
		"min_x": 513.0,
		"max_x": 1536.0,
		"min_y": -385.0,
		"max_y": 384.0,
		"spawn": Vector2(570, 20)
	}
]


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("teleport_checkpoint"):
		teleport_to_room_start()


func teleport_to_room_start() -> void:

	if player == null:
		print("ERROR: Player reference is missing!")
		return

	var player_position = player.global_position

	for room in rooms:

		if (
			player_position.x >= room["min_x"]
			and player_position.x < room["max_x"]
			and player_position.y >= room["min_y"]
			and player_position.y < room["max_y"]
		):

			player.global_position = room["spawn"]
			player.velocity = Vector2.ZERO

			print("Teleported to: ", room["name"])
			return

	print("Player is not inside any registered room!")
