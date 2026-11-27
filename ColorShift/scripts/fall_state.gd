extends State

class_name FallState

@onready var animated_sprite = %PlayerSkin

const COYOTE_TIME := 0.12
var coyote_timer := 0.0

func enter():
	var character = state_machine.get_parent()
	# Si venimos de suelo, nos llevamos la inercia de la plataforma una sola vez
	# y tenemos coyote time. Si venimos del salto, ya la llevamos aplicada.
	if state_machine.previous_state_name in ["idlestate", "walkstate", "shiftingstate"]:
		character.velocity.y += state_machine.inherited_velocity.y
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = 0.0
	#print("Entering fall state")
	
func handle_input(event):
	if event.is_action_pressed("jump") and coyote_timer > 0.0:
		coyote_timer = 0.0
		state_machine.change_state("jumpstate")

func physics_update(delta):
	# Get the character here, not at class level: state_machine is still
	# null when the script's variables are initialised.
	var character = state_machine.get_parent()

	# Gravity
	character.velocity.y += GRAVITY * delta

	# Air control
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * SPEED + state_machine.inherited_velocity.x
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	character.move_and_slide()

	# Landing
	if character.is_on_floor():
		if direction != 0:
			state_machine.change_state("walkstate")
		else:
			state_machine.change_state("idlestate")
