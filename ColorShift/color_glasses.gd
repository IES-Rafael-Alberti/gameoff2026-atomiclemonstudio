extends Control

func _process(delta):
		if Input.is_action_just_pressed("shift"):
			rotation_degrees += 90
