
extends Node2D

@export var effect_duration: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	# Randomly change the actual game color.
	GameManager.randomize_color()

	if sprite == null:
		await get_tree().create_timer(effect_duration).timeout
		queue_free()
		return

	# Pop in, hold for a moment, then fade out instead of leaving a stray
	# spell sprite on screen when the colour changes.
	sprite.scale = Vector2.ZERO
	sprite.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(
		sprite, "scale", Vector2.ONE, effect_duration * 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		sprite, "modulate:a", 1.0, effect_duration * 0.25
	)
	tween.tween_interval(effect_duration * 0.25)
	tween.tween_property(
		sprite, "modulate:a", 0.0, effect_duration * 0.25
	)

	await tween.finished

	queue_free()
