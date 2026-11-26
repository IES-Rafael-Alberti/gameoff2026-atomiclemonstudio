
extends Node2D

@export var effect_duration: float = 1.0


func _ready() -> void:
	# Randomly change the actual game color.
	GameManager.randomize_color()

	# Keep the spell scene alive for its visual effect.
	await get_tree().create_timer(effect_duration).timeout

	queue_free()
