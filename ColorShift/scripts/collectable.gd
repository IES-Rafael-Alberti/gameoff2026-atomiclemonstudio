extends Area2D

signal collected


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	MusicAndSounds.play_collectable()
	collected.emit()

	GameManager.collect_carrot()

	queue_free()
