extends Node2D

@onready var state_machine: StateMachine = get_node("../../Player/StateMachine")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	state_machine.change_state("deathstate")
