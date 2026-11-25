extends Area2D

@export var boss: CharacterBody2D

func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		boss.start_boss_fight()
