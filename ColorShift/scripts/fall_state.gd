extends State

class_name FallState

@onready var animated_sprite = %PlayerSkin

func enter():
	pass
	#print("Entering fall state")

func physics_update(delta):
	# Get the character here, not at class level: state_machine is still
	# null when the script's variables are initialised.
	var character = state_machine.get_parent()

	# Gravity
	character.velocity.y += GRAVITY * delta

	# Air control
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * SPEED
	character.move_and_slide()

	# Landing
	if character.is_on_floor():
		if direction != 0:
			state_machine.change_state("walkstate")
		else:
			state_machine.change_state("idlestate")
