extends Node2D
## Level 5 starts with the second color wheel already unlocked.
##
## _enter_tree() is called on the parent before the children enter the tree,
## so the second wheel is active before tile_map_manager.gd reads the initial
## color in its _ready(). If the wheel was already collected in a previous
## level, its current color is kept.

func _enter_tree() -> void:
	if not GameManager.has_second_wheel:
		GameManager.obtain_second_wheel()
