
extends Area2D

@export var boss: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:

	if not body.is_in_group("player"):
		return

	if boss == null:
		push_error("Battle trigger: No boss assigned in Inspector!")
		return

	if boss.has_method("start_boss_fight"):
		boss.start_boss_fight()
		set_deferred("monitoring", false)
	else:
		push_error("Assigned boss does not have start_boss_fight()!")
