
extends Area2D

# Don't change this speed, change the one inside chameleon
@export var speed: float = 350.0
@export var damage: int = 1

var color_name: String = "RED"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func setup(new_color: String, new_speed: float) -> void:
	color_name = new_color.to_upper()
	speed = new_speed


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if not GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.connect(_on_color_changed)

	_update_color()


func _physics_process(delta: float) -> void:
	# Projectiles travel downwards.
	global_position.y += speed * delta

	# Remove projectiles once they leave the visible screen.
	var screen_position: Vector2 = (
		get_viewport().get_canvas_transform() * global_position
	)

	var screen_height: float = get_viewport().get_visible_rect().size.y

	if screen_position.y > screen_height + 100.0:
		queue_free()


func _on_color_changed(_new_color: String) -> void:
	_update_color()


func _update_color() -> void:
	var active_color: String = GameManager.get_color_name().to_upper()

	# A projectile disappears when its colour is the active colour.
	var should_hide: bool = active_color == color_name

	visible = not should_hide

	set_deferred("monitoring", not should_hide)
	collision.set_deferred("disabled", should_hide)

	match color_name:
		"RED":
			sprite.modulate = Color.RED
		"BLUE":
			sprite.modulate = Color.BLUE
		"YELLOW":
			sprite.modulate = Color.YELLOW
		"ORANGE":
			sprite.modulate = Color.ORANGE
		"PURPLE":
			sprite.modulate = Color.PURPLE
		"GREEN":
			sprite.modulate = Color.GREEN
		_:
			sprite.modulate = Color.GRAY


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)
