
extends Area2D

@export var speed: float = 250.0
@export var damage: int = 1
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	get_tree().create_timer(lifetime).timeout.connect(
		queue_free
	)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
