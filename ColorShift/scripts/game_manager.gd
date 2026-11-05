extends Node

enum game_states {PLAYING, TIME_PAUSED, PAUSED, GAME_OVER, VICTORY}
var game_state = game_states.PLAYING

enum colors {GREY, RED, BLUE, YELLOW}
var actual_color_index = 0
var actual_color = null

var player_node: CharacterBody2D = null

func _ready() -> void:
	actual_color = colors.find_key(actual_color_index)

func _on_game_over():
	SceneManager.change_scene("END")
	game_state = game_states.GAME_OVER

func _on_change_color():
	print("Color anterior: ", actual_color)
	
	actual_color_index = (actual_color_index + 1) % colors.size()
	actual_color = colors.keys()[actual_color_index]
	
	print("Color despues: ", actual_color)
