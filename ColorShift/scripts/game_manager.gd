extends Node

enum game_states {PLAYING, TIME_PAUSED, PAUSED, GAME_OVER, VICTORY}
var game_state = game_states.PLAYING

enum colors {GREY, RED, GREEN, BLUE}
var actual_color = colors.GREY

@export var player_node: Node2D

func _ready() -> void:
	if player_node:
		player_node.game_over.connect(_on_game_over)

func _on_game_over():
	SceneManager.change_scene("END")
	game_state = game_states.GAME_OVER
