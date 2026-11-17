
extends AnimatableBody2D

@export_group("Movement")
@export var speed: float = 80.0
@export var upper_limit: float = -300
@export var lower_limit: float = 300

@export_enum("Up:-1", "Down:1")
var starting_direction: int = 1

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var direction: float = 1.0
var moving: bool = true


func _ready() -> void:

	direction = float(starting_direction)

	if upper_limit >= lower_limit:
		push_error("Snake: upper_limit must be smaller than lower_limit.")
		moving = false

	if sprite == null:
		push_error("Snake: No AnimatedSprite2D found. Check its node name.")


func _physics_process(delta: float) -> void:

	if not moving:
		return

	var next_y: float = global_position.y + direction * speed * delta

	if next_y <= upper_limit:
		next_y = upper_limit
		direction = 1.0

	elif next_y >= lower_limit:
		next_y = lower_limit
		direction = -1.0

	global_position.y = next_y

	update_sprite_direction()


func update_sprite_direction() -> void:

	if sprite == null:
		return

	sprite.flip_v = direction < 0.0


func reverse_direction() -> void:
	direction *= -1.0


func stop() -> void:
	moving = false


func resume() -> void:
	moving = true
