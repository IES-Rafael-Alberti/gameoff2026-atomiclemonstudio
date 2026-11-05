extends Node

class_name State
var state_machine: StateMachine

# Shared values so every state uses the same numbers
const GRAVITY := 980.0
const SPEED := 200.0

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func handle_input(event: InputEvent):
	pass
