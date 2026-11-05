extends Control

func _process(delta):
	if Input.is_action_pressed("shift"):
		if Input.is_action_just_pressed("move_left"):
			rotation_degrees += 90
		if Input.is_action_just_pressed("move_right"):
			rotation_degrees -= 90
