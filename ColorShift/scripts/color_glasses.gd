extends Control

@onready var game_manager = get_node("/root/GameManager")

func _process(delta: float) -> void:
	if Input.is_action_pressed("shift"):
		if Input.is_action_just_pressed("move_right"):
			# Rotate the color filter
			rotation_degrees -= 90
			# Change the active color
			game_manager.change_color()
