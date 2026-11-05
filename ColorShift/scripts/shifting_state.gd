extends State

class_name ShiftingState

# Player stands still while shift is held, so left/right can be used
# to rotate the color glasses instead of moving the character.

func enter():
	print("Entering shifting state")
	var character = state_machine.get_parent()
	character.velocity.x = 0

func physics_update(delta):
	var character = state_machine.get_parent()

	character.velocity.x = 0
	character.velocity.y += GRAVITY * delta
	character.move_and_slide()

	if not character.is_on_floor():
		state_machine.change_state("fallstate")
		return

	# Released shift -> back to idle (idle moves on to walk if a direction is held)
	if not Input.is_action_pressed("shift"):
		state_machine.change_state("idlestate")
