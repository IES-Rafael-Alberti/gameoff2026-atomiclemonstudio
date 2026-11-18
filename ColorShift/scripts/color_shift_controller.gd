extends Node

## Cycles the two color wheels with Shift and Control.

var _shift_active: bool = false
var _control_active: bool = false


func _ready() -> void:
	add_child(preload("res://scripts/color_disc.gd").new())


func _process(_delta: float) -> void:
	var shift_pressed := Input.is_action_pressed("shift")
	var control_pressed := Input.is_action_pressed("control")
	var shift_triggered := shift_pressed and not _shift_active
	var control_triggered := control_pressed and not _control_active
	_shift_active = shift_pressed
	_control_active = control_pressed

	if not shift_triggered and not control_triggered:
		return
	if SceneManager.is_transitioning:
		return

	var state_machine := get_parent().get_node_or_null("StateMachine") as StateMachine
	if state_machine != null and state_machine.current_state != null:
		if state_machine.current_state.name.to_lower() == "deathstate":
			return

	if shift_triggered:
		ScreenTransition.shift_color(1)
	elif control_triggered:
		ScreenTransition.shift_color(2)
