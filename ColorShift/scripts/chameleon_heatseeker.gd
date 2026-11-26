
extends Area2D

@export var speed: float = 180.0

var color_name: String = "RED"
var damage: int = 1
var player: Node2D = null

# The boss can configure the spell before it enters the tree. In that case
# _ready() must not roll a second, conflicting colour.
var _is_configured: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func setup(new_color: String, new_speed: float, new_damage: int) -> void:
	color_name = new_color.to_upper()
	speed = new_speed
	damage = maxi(new_damage, 1)
	_is_configured = true

	# setup() is normally called before add_child(); if the node is already
	# in the tree, apply the colour straight away as well.
	if is_node_ready():
		_update_color()


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	player = get_tree().get_first_node_in_group("player") as Node2D

	if not GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.connect(_on_color_changed)

	if not _is_configured:
		# Choose a random color different from the active color.
		var possible_colors: Array[String] = [
			"GREY",
			"RED",
			"BLUE",
			"YELLOW"
		]

		if GameManager.has_second_wheel:
			possible_colors.append_array([
				"ORANGE",
				"PURPLE",
				"GREEN"
			])

		possible_colors.erase(GameManager.get_color_name().to_upper())

		if possible_colors.is_empty():
			possible_colors = ["RED", "BLUE", "YELLOW"]

		color_name = possible_colors.pick_random()

	_update_color()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		return

	var direction: Vector2 = (
		player.global_position - global_position
	).normalized()

	global_position += direction * speed * delta

	rotation = direction.angle()


func _on_color_changed(_new_color: String) -> void:
	_update_color()


func _update_color() -> void:
	var active_color: String = GameManager.get_color_name().to_upper()

	var should_disappear: bool = active_color == color_name

	if should_disappear:
		queue_free()
		return

	match color_name:
		"GREY":
			sprite.modulate = Color.GRAY
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
			sprite.modulate = Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)
