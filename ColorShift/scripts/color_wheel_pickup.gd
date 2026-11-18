extends Area2D
## Left color wheel collectible (level 4). Touching it gives the second wheel:
## it starts on the color opposite to the right wheel, turns with Left Shift
## and its color mixes with the right one (RED + BLUE = PURPLE...).

const SPIN_FPS := 6.0

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if GameManager.has_second_wheel:
		queue_free()
		return

	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	# Idle: turns through the frames of its sprite and floats a little.
	var time := Time.get_ticks_msec() / 1000.0
	_sprite.frame = int(time * SPIN_FPS) % _sprite.hframes
	_sprite.position.y = sin(time * 3.0) * 3.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	set_deferred("monitoring", false)
	hide()
	# Never lose the wheel because a Shift sweep was already running.
	while ScreenTransition.is_busy():
		await ScreenTransition.sweep_finished

	ScreenTransition.sweep(GameManager.obtain_second_wheel, 2)
	UIManager.show_message("New color wheel! Turn it with Left Shift", 2.5)
	queue_free()
