extends State

class_name JumpState

@onready var animated_sprite = %PlayerSkin

const HOLD_TIME := 0.12
const SHORT_JUMP_VELOCITY := -200.0

var hold_time_elapsed := 0.0

func enter():
	var character = state_machine.get_parent()
	character.velocity.y = -450
	hold_time_elapsed = 0.0
	animated_sprite.play("jump")

func handle_input(event):
	if event.is_action_released("jump"):
		var character = state_machine.get_parent()
		if hold_time_elapsed < HOLD_TIME:
			character.velocity.y = SHORT_JUMP_VELOCITY

func physics_update(delta):
	var character = state_machine.get_parent()

	# Gravity
	character.velocity.y += GRAVITY * delta

	if Input.is_action_pressed("jump"):
		hold_time_elapsed += delta

	# Horizontal movement (air control)
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * SPEED
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	character.move_and_slide()

	# Once we stop going up (or bonk a ceiling), hand over to fall.
	# Landing is handled by FallState.
	if character.velocity.y >= 0:
		state_machine.change_state("fallstate")
