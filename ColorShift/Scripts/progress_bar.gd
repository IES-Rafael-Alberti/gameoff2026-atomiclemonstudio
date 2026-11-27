
extends TextureProgressBar

@export var chameleon: CharacterBody2D

var max_health: float = 100.0


func _ready() -> void:
	if chameleon == null:
		push_error("HealthBar: Chameleon reference is missing!")
		return

	max_health = float(chameleon.health)

	min_value = 0
	max_value = max_health
	step = 1.0
	value = max_health

	chameleon.health_changed.connect(_on_health_changed)

	print("Initial value: ", value)
	print("Maximum value: ", max_value)


func _on_health_changed(new_health: int) -> void:
	var tween := create_tween()
	tween.tween_property(
		self,
		"value",
		clampf(float(new_health), 0.0, max_health),
		0.2
	)
