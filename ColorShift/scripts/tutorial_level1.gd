extends Node
## How-to-play tips of the first level, one per room, naming the keys or
## buttons of the device the player is using.

@export var camera: Camera2D


func _ready() -> void:
	# Keeps running while paused, only to hide the tip behind the pause menu.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	var text := ""
	if get_tree().paused:
		pass
	elif camera.current_room == Vector2i(0, 0):
		text = "Use %s / %s to move\nUse %s to change the color" % [
			InputSettings.get_action_text("move_left"),
			InputSettings.get_action_text("move_right"),
			InputSettings.get_action_text("shift"),
		]
	elif camera.current_room == Vector2i(1, 0):
		text = "Use %s to jump" % InputSettings.get_action_text("jump")
	UIManager.show_tutorial(text)


func _exit_tree() -> void:
	UIManager.show_tutorial("")
