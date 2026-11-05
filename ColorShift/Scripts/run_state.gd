extends State

class_name WalkState

func physics_update(delta):
	var character = state_machine.get_parent()
	var direction = Input.get_axis("move_left", "move_right")

	if direction == 0:
		state_machine.change_state("idlestate")
		return

	character.velocity.x = direction * SPEED
	character.velocity.y += GRAVITY * delta
	character.move_and_slide()

	# Walked off a ledge
	if not character.is_on_floor():
		state_machine.change_state("fallstate")

func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumpstate")
	elif Input.is_action_just_pressed("shift"):
		state_machine.change_state("shiftingstate")
