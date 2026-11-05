extends State

class_name IdleState

@onready var animated_sprite = %PlayerSkin

func enter():
	print("Entering idle state")
	var character = state_machine.get_parent()
	character.velocity.x = 0
	animated_sprite.play("idle")
	
func physics_update(delta):
	var character = state_machine.get_parent()

	# Gravity, so walking off a ledge while idle still works
	character.velocity.y += GRAVITY * delta
	character.move_and_slide()

	if not character.is_on_floor():
		state_machine.change_state("fallstate")
		return

	if Input.get_axis("move_left", "move_right") != 0:
		state_machine.change_state("walkstate")

func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumpstate")
	elif Input.is_action_just_pressed("shift"):
		state_machine.change_state("shiftingstate")
