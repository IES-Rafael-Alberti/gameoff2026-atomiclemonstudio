extends State

class_name JumpState


func enter():
	var character = state_machine.get_parent()
	character.velocity.y = -400

func physics_update(delta):
	var character = state_machine.get_parent()

	#Apply gravity
	character.velocity.y += 980 * delta
	if character.velocity.y > 0:
		state_machine.change_state("fallstate")
	
	#Handle horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * 200
	
	character.move_and_slide()
	
	#Return appropiate state when landing on the floor
	if character.is_on_floor():
		if direction != 0:
			state_machine.change_state("walkstate")
		else:
			state_machine.change_state("idlestate")
