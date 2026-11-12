extends Area2D

signal collected(id: String)

@export var collectable_id: String = "collectable_1"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	collected.emit(collectable_id)
	queue_free()
