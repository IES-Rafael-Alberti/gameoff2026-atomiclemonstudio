
extends CharacterBody2D

signal boss_defeated

@export var projectile_scene: PackedScene
@export var heatseeker_scene: PackedScene
@export var platforms_spell_scene: PackedScene

@export var health: int = 100

# Physics and recovery settings.
@export var gravity: float = 980.0
@export var fall_delay: float = 0.15
@export var jump_recovery_duration: float = 0.6

# Projectile attack settings.
@export var projectile_count: int = 16
@export var projectile_speed: float = 350.0
@export var projectile_line_interval: float = 0.7

@export var projectile_colors: Array[String] = [
	"RED",
	"BLUE",
	"YELLOW"
]

# Heatseeker settings.
@export var heatseeker_speed: float = 180.0
@export var heatseeker_damage: int = 1

@export var heatseeker_colors: Array[String] = [
	"GREY",
	"RED",
	"BLUE",
	"YELLOW",
	"ORANGE",
	"PURPLE",
	"GREEN"
]

@onready var sprite: AnimatedSprite2D = $Chameleon
@onready var attack_point: Marker2D = $AttackPoint

var is_alive: bool = true
var is_running_sequence: bool = false

# Recovery control.
var starting_position: Vector2
var is_recovering: bool = false
var is_falling: bool = false
var is_returning: bool = false

# Every interruption changes this token.
var action_token: int = 0


# --------------------------------------------------
# BOSS ATTACK SEQUENCE
# --------------------------------------------------

var boss_sequence: Array[Dictionary] = [
	{"action": "cast", "spell": "projectile"},
	{"action": "wait", "duration": 1.0},

	{"action": "cast", "spell": "heatseeker"},
	{"action": "wait", "duration": 1.5},

	{"action": "cast", "spell": "platforms_spell"},
	{"action": "wait", "duration": 2.0}
]


func _ready() -> void:
	starting_position = global_position
	sprite.play("idle")


# --------------------------------------------------
# PHYSICS AND FALL DETECTION
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	if not is_alive or is_returning:
		return

	velocity.x = 0.0

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	# Detect when the chameleon loses the floor.
	if not is_on_floor() and velocity.y > 0.0:
		if not is_recovering:
			_start_fall()


# --------------------------------------------------
# FALL AND RECOVERY
# --------------------------------------------------

func _start_fall() -> void:
	if is_recovering or not is_alive:
		return

	is_recovering = true
	is_falling = true

	# Cancel the current attack or animation wait.
	action_token += 1

	# The fall interrupts any pending cast.
	velocity.x = 0.0

	_recover_from_fall()


func _recover_from_fall() -> void:
	# Allow a short delay before showing the hit animation.
	await get_tree().create_timer(fall_delay).timeout

	if not is_alive:
		return

	# Play hit animation.
	sprite.play("hit")

	await _wait_for_animation("hit")

	if not is_alive:
		return

	# Stop physics while the recovery jump is controlling position.
	is_returning = true
	is_falling = false
	velocity = Vector2.ZERO

	# Play jump animation while returning to the starting position.
	sprite.play("jump")

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		starting_position,
		jump_recovery_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	if not is_alive:
		return

	global_position = starting_position

	# Recovery finished.
	is_returning = false
	is_recovering = false
	is_falling = false

	velocity = Vector2.ZERO

	# Return to idle until the next attack.
	sprite.play("idle")


# --------------------------------------------------
# ANIMATION CONTROL
# --------------------------------------------------

func _wait_for_animation(animation: StringName) -> void:
	var current_token: int = action_token

	while is_alive and current_token == action_token:
		if sprite.animation != animation:
			return

		if not sprite.is_playing():
			return

		await get_tree().process_frame


# --------------------------------------------------
# SPELL PARENT
# --------------------------------------------------

func _spell_parent() -> Node:
	var current_scene: Node = get_tree().current_scene
	return current_scene if current_scene != null else get_tree().root


# --------------------------------------------------
# BOSS FIGHT
# --------------------------------------------------

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

			# Wait until recovery is completely finished.
			while is_recovering and is_alive:
				await get_tree().process_frame

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

			# If an attack was interrupted, wait for recovery.
			while is_recovering and is_alive:
				await get_tree().process_frame

			if not is_alive:
				return


# --------------------------------------------------
# SPELLS
# --------------------------------------------------


func cast_spell(spell_name: String) -> void:
	if not is_alive or is_recovering:
		return

	var current_token: int = action_token

	# Play cast animation.
	sprite.play("cast")

	# Wait for cast animation to finish or be interrupted.
	while is_alive and current_token == action_token:
		if sprite.animation != &"cast":
			return

		if not sprite.is_playing():
			break

		await get_tree().process_frame

	# Cancel the spell if a fall interrupted the cast.
	if not is_alive or current_token != action_token:
		return

	if is_recovering:
		return

	# Immediately return to idle after cast finishes.
	sprite.play("idle")

	# Execute the spell while idle animation is playing.
	await spawn_spell(spell_name, current_token)



func spawn_spell(spell_name: String, token: int) -> void:
	if not is_alive or token != action_token:
		return

	match spell_name:
		"projectile":
			await spawn_projectile_attack(token)

		"heatseeker":
			spawn_heatseeker()

		"platforms_spell":
			spawn_platforms_spell()

		_:
			push_warning("Unknown Chameleon spell: " + spell_name)


# --------------------------------------------------
# PLATFORMS SPELL
# --------------------------------------------------

func spawn_platforms_spell() -> void:
	if platforms_spell_scene == null:
		GameManager.randomize_color()
		return

	var spell := platforms_spell_scene.instantiate() as Node2D

	if spell == null:
		push_error("Chameleon: Platforms spell root must be Node2D!")
		GameManager.randomize_color()
		return

	_spell_parent().add_child(spell)
	spell.global_position = attack_point.global_position


# --------------------------------------------------
# HEATSEEKER ATTACK
# --------------------------------------------------

func spawn_heatseeker() -> void:
	if heatseeker_scene == null:
		push_error("Chameleon: heatseeker_scene is not assigned!")
		return

	if heatseeker_colors.is_empty():
		push_warning("Chameleon: No Heatseeker colors configured!")
		return

	var available_colors: Array[String] = []

	var current_color: String = GameManager.get_color_name().to_upper()

	for color in heatseeker_colors:
		if color.to_upper() != current_color:
			available_colors.append(color.to_upper())

	if available_colors.is_empty():
		available_colors = heatseeker_colors.duplicate()

	var selected_color: String = available_colors[
		randi_range(0, available_colors.size() - 1)
	].to_upper()

	var heatseeker := heatseeker_scene.instantiate() as Area2D

	if heatseeker == null:
		push_error("Chameleon: Heatseeker scene root must be Area2D!")
		return

	if not heatseeker.has_method("setup"):
		push_error("Chameleon: Heatseeker scene is missing setup()!")
		heatseeker.free()
		return

	heatseeker.call(
		"setup",
		selected_color,
		heatseeker_speed,
		heatseeker_damage
	)

	_spell_parent().add_child(heatseeker)
	heatseeker.global_position = attack_point.global_position


# --------------------------------------------------
# PROJECTILE ATTACK
# --------------------------------------------------

func spawn_projectile_attack(token: int) -> void:
	if projectile_scene == null:
		push_error("Chameleon: projectile_scene is not assigned!")
		return

	if projectile_colors.is_empty():
		push_warning("Chameleon: No projectile colours configured!")
		return

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	var screen_to_world: Transform2D = (
		get_viewport().get_canvas_transform().affine_inverse()
	)

	var top_world: Vector2 = screen_to_world * Vector2.ZERO

	var bottom_world: Vector2 = screen_to_world * Vector2(
		0.0,
		viewport_size.y
	)

	for color in projectile_colors:
		if not is_alive or token != action_token:
			return

		spawn_projectile_line(
			color,
			viewport_size,
			screen_to_world,
			token
		)

		await get_tree().create_timer(
			projectile_line_interval
		).timeout

		if not is_alive or token != action_token:
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
	screen_to_world: Transform2D,
	token: int
) -> void:

	for i in range(projectile_count):
		if not is_alive or token != action_token:
			return

		var projectile := projectile_scene.instantiate() as Area2D

		if projectile == null:
			push_error("Chameleon: Projectile root must be Area2D!")
			return

		projectile.call("setup", color, projectile_speed)

		_spell_parent().add_child(projectile)

		var screen_x: float = (
			(float(i) + 0.5) / float(projectile_count)
		) * viewport_size.x

		var spawn_screen_position: Vector2 = Vector2(
			screen_x,
			-30.0
		)

		projectile.global_position = (
			screen_to_world * spawn_screen_position
		)


# --------------------------------------------------
# DAMAGE AND DEATH
# --------------------------------------------------

func take_damage(amount: int) -> void:
	if not is_alive:
		return

	health -= amount

	if health <= 0:
		_defeat_boss()


func _defeat_boss() -> void:
	if not is_alive:
		return

	is_alive = false
	is_running_sequence = false

	# Cancel pending animation and attack operations.
	action_token += 1

	boss_defeated.emit()

	queue_free()
