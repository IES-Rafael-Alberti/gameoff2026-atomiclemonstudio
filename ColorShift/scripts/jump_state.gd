extends State

class_name JumpState

@onready var animated_sprite = %PlayerSkin

func enter():
	print("Entering jump state")
	var character = state_machine.get_parent()
	character.velocity.y = -450
	animated_sprite.play("jump")

func physics_update(delta):
	var character = state_machine.get_parent()

	# Gravity
	character.velocity.y += GRAVITY * delta

	# Horizontal movement (air control)
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * SPEED
	character.move_and_slide()

	# Once we stop going up (or bonk a ceiling), hand over to fall.
	# Landing is handled by FallState.
	if character.velocity.y >= 0:
		state_machine.change_state("fallstate")
