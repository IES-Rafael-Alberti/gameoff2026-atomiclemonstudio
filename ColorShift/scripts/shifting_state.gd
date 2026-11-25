extends State

class_name ShiftingState

@onready var animated_sprite = %PlayerSkin

func enter():
	pass

# Saltar tiene prioridad sobre el barrido de color: si el jugador pulsa Shift
# y salta antes de soltarlo, debe poder saltar en vez de quedarse atrapado en
# este estado hasta que suelte la tecla.
func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and not event.is_echo():
		state_machine.change_state("jumpstate")

func physics_update(delta):
	var character = state_machine.get_parent()

	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * SPEED
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	character.velocity.y += GRAVITY * delta
	character.move_and_slide()

	if not character.is_on_floor():
		state_machine.change_state("fallstate")
		return

	if not Input.is_action_pressed("shift") and not Input.is_action_pressed("shift_2"):
		state_machine.change_state("idlestate")
