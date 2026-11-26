
extends CharacterBody2D

signal boss_defeated

@export var projectile_scene: PackedScene
@export var barrel_throw_scene: PackedScene
@export var platforms_spell_scene: PackedScene

@export var left_position: Marker2D
@export var right_position: Marker2D

@export var walk_speed: float = 100.0
@export var jump_duration: float = 0.8
@export var gravity: float = 980.0

@export var health: int = 100

# Projectile attack settings.
@export var projectile_count: int = 16
@export var projectile_speed: float = 170.0
@export var projectile_line_interval: float = 1.8

# You can change these colours in the Inspector.
@export var projectile_colors: Array[String] = [
	"RED",
	"BLUE",
	"YELLOW"
]

@onready var sprite: AnimatedSprite2D = $Chameleon
@onready var attack_point: Marker2D = $AttackPoint

var is_alive: bool = true
var is_running_sequence: bool = false

var boss_sequence: Array[Dictionary] = [
	{"action": "cast", "spell": "projectile"},
	{"action": "wait", "duration": 1.0},

	{"action": "jump", "target": "left"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "barrel_throw"},
	{"action": "wait", "duration": 1.5},

	{"action": "walk", "target": "right"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "platforms_spell"},
	{"action": "wait", "duration": 2.0},

	{"action": "jump", "target": "right"},
	{"action": "wait", "duration": 1.0}
]


func _ready() -> void:
	sprite.play("idle")


# Called by your BattleStartTrigger.
func start_boss_fight() -> void:
	if is_running_sequence or not is_alive:
		return

	is_running_sequence = true
	_run_boss_sequence()


func _run_boss_sequence() -> void:
	while is_alive:
		for instruction in boss_sequence:
			if not is_alive:
				return

			var action: String = instruction.get("action", "")

			match action:
				"wait":
					var duration: float = instruction.get("duration", 1.0)
					await get_tree().create_timer(duration).timeout

				"cast":
					var spell_name: String = instruction.get("spell", "")
					await cast_spell(spell_name)

				"walk":
					var target: String = instruction.get("target", "right")
					await walk_to_target(target)

				"jump":
					var target: String = instruction.get("target", "right")
					await jump_to_target(target)

			if not is_alive:
				return


# --------------------------------------------------
# SPELLS
# --------------------------------------------------

func cast_spell(spell_name: String) -> void:
	if not is_alive:
		return

	sprite.play("cast")
	await sprite.animation_finished

	if not is_alive:
		return

	await spawn_spell(spell_name)

	if is_alive:
		sprite.play("idle")


func spawn_spell(spell_name: String) -> void:
	match spell_name:
		"projectile":
			await spawn_projectile_attack()

		"barrel_throw":
			spawn_single_spell(barrel_throw_scene)

		"platforms_spell":
			spawn_single_spell(platforms_spell_scene)

		_:
			push_warning("Unknown Chameleon spell: " + spell_name)


func spawn_single_spell(spell_scene: PackedScene) -> void:
	if spell_scene == null:
		push_error("Chameleon: Spell scene is not assigned in the Inspector!")
		return

	var spell := spell_scene.instantiate() as Node2D

	if spell == null:
		push_error("Chameleon: Spell scene must have a Node2D root!")
		return

	get_tree().current_scene.add_child(spell)
	spell.global_position = attack_point.global_position


# --------------------------------------------------
# PROJECTILE ATTACK
# --------------------------------------------------

func spawn_projectile_attack() -> void:
	if projectile_scene == null:
		push_error("Chameleon: projectile_scene is not assigned!")
		return

	if projectile_colors.is_empty():
		push_warning("Chameleon: No projectile colours configured!")
		return

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	# Convert viewport coordinates into world coordinates.
	# This makes the attack cover the camera's visible screen.
	var screen_to_world: Transform2D = (
		get_viewport().get_canvas_transform().affine_inverse()
	)

	var top_world: Vector2 = screen_to_world * Vector2.ZERO

	var bottom_world: Vector2 = screen_to_world * Vector2(
		0.0,
		viewport_size.y
	)

	# Fire one horizontal row for each configured colour.
	for color in projectile_colors:
		if not is_alive:
			return

		spawn_projectile_line(
			color,
			viewport_size,
			screen_to_world
		)

		await get_tree().create_timer(
			projectile_line_interval
		).timeout

	# Wait until the final row has travelled off-screen.
	if not is_alive:
		return

	var vertical_distance: float = absf(
		bottom_world.y - top_world.y
	)

	var travel_time: float = vertical_distance / maxf(
		projectile_speed,
		1.0
	)

	await get_tree().create_timer(travel_time + 0.2).timeout


func spawn_projectile_line(
	color: String,
	viewport_size: Vector2,
	screen_to_world: Transform2D
) -> void:

	for i in range(projectile_count):
		if not is_alive:
			return

		var projectile := projectile_scene.instantiate() as Area2D

		if projectile == null:
			push_error(
				"Chameleon: Projectile scene root must be an Area2D!"
			)
			return

		# Configure the projectile before adding it to the scene tree.
		projectile.call(
			"setup",
			color,
			projectile_speed
		)

		get_tree().current_scene.add_child(projectile)

		# Distribute projectiles evenly across the screen width.
		var screen_x: float = (
			(float(i) + 0.5) / float(projectile_count)
		) * viewport_size.x

		# Spawn just above the visible screen.
		var spawn_screen_position: Vector2 = Vector2(
			screen_x,
			-30.0
		)

		projectile.global_position = (
			screen_to_world * spawn_screen_position
		)


# --------------------------------------------------
# MOVEMENT
# --------------------------------------------------

func walk_to_target(target: String) -> void:
	if not is_alive:
		return

	var destination: Vector2 = _get_target_position(target)

	if target == "left":
		sprite.play("walk_left")
	else:
		sprite.play("walk_right")

	var distance: float = global_position.distance_to(destination)
	var duration: float = distance / maxf(walk_speed, 1.0)

	var tween := create_tween()
	tween.tween_property(
		self,
		"global_position",
		destination,
		duration
	)

	await tween.finished

	if is_alive:
		sprite.play("idle")


func jump_to_target(target: String) -> void:
	if not is_alive:
		return

	var destination: Vector2 = _get_target_position(target)

	if target == "left":
		sprite.play("jump_left")
	else:
		sprite.play("jump_right")

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		Vector2(
			destination.x,
			global_position.y - 100.0
		),
		jump_duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"global_position",
		destination,
		jump_duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished

	if is_alive:
		sprite.play("idle")


func _get_target_position(target: String) -> Vector2:
	match target:
		"left":
			if left_position != null:
				return left_position.global_position

		"right":
			if right_position != null:
				return right_position.global_position

	push_warning("Chameleon: Invalid or unassigned movement target: " + target)
	return global_position


# --------------------------------------------------
# DAMAGE AND DEATH
# --------------------------------------------------

func take_damage(amount: int) -> void:
	if not is_alive:
		return

	health -= amount

	if health <= 0:
		_defeat_boss()
		return

	sprite.play("hit")


func _defeat_boss() -> void:
	if not is_alive:
		return

	is_alive = false
	is_running_sequence = false

	sprite.play("idle")
	velocity = Vector2.ZERO

	boss_defeated.emit()

	queue_free()
