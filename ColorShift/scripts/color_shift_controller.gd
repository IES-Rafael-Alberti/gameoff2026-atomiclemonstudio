extends Node

## Cycles the active color with Shift + Right, without any screen filter.

var _combo_active: bool = false


func _process(_delta: float) -> void:
	var combo := Input.is_action_pressed("shift") and Input.is_action_pressed("move_right")
	var triggered := combo and not _combo_active
	_combo_active = combo

	if not triggered:
		return
	if SceneManager.is_transitioning:
		return

	var state_machine := get_parent().get_node_or_null("StateMachine") as StateMachine
	if state_machine != null and state_machine.current_state != null:
		if state_machine.current_state.name.to_lower() == "deathstate":
			return

	GameManager.change_color()
