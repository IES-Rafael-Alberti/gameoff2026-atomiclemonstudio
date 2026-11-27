extends Node2D
## Level 6 starts with the second color wheel already unlocked. It was
## obtained in level 4 and stays available for the rest of the game.
##
## _enter_tree() runs on the parent before the children enter the tree, so the
## wheel is active before tile_map_manager.gd reads the initial color.

func _enter_tree() -> void:
	if not GameManager.has_second_wheel:
		GameManager.obtain_second_wheel()
