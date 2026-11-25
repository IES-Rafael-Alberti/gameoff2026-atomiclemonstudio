
extends CharacterBody2D

signal spell_requested(spell_name: String)
signal boss_defeated

# ==========================================
# REFERENCES
# ==========================================
@export var projectile_scene: PackedScene
@export var barrel_throw_scene: PackedScene
@export var platforms_scene: PackedScene
@export var left_position: Marker2D
@export var right_position: Marker2D

@onready var sprite: AnimatedSprite2D = $Chameleon

# ==========================================
# MOVEMENT SETTINGS
# ==========================================

@export var walk_speed: float = 100.0
@export var jump_duration: float = 0.8
@export var gravity: float = 980.0

# ==========================================
# BOSS SETTINGS
# ==========================================

@export var health: int = 100

var is_alive: bool = true
var is_running_sequence: bool = false

# ==========================================
# BOSS ATTACK SEQUENCE
# ==========================================

var boss_sequence: Array[Dictionary] = [
	{"action": "cast", "spell": "projectile"},
	{"action": "wait", "duration": 1.0},

	{"action": "jump", "target": "left"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "barrel_throw"},
	{"action": "wait", "duration": 1.5},

	{"action": "walk", "target": "right"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "platforms"},
	{"action": "wait", "duration": 2.0},

	{"action": "jump", "target": "right"},
	{"action": "wait", "duration": 1.0}
]

# ==========================================
# INITIALIZATION
# ==========================================

func _ready() -> void:
	sprite.play("idle")
	spell_requested.connect(_on_spell_requested)

func _on_spell_requested(spell_name: String) -> void:
	spawn_spell(spell_name)
	match spell_name:

		"projectile":
			print("Chameleon casts projectile!")

			# Instantiate projectile scene here.

		"barrel_throw":
			print("Chameleon casts barrel throw!")

			# Instantiate ground attack scene here.

		"platforms":
			print("Chameleon casts platforms!")

			# Instantiate special attack scene here.

func spawn_spell(spell_name: String) -> void:

	var spell_scene: PackedScene

	match spell_name:
		"projectile":
			spell_scene = projectile_scene

		"barrel_throw":
			spell_scene = barrel_throw_scene

		"platforms":
			spell_scene = platforms_scene

		_:
			push_warning("Unknown spell: " + spell_name)
			return

	if spell_scene == null:
		push_warning("Spell scene not assigned: " + spell_name)
		return

	var spell = spell_scene.instantiate()

	get_tree().current_scene.add_child(spell)

	spell.global_position = $AttackPoint.global_position
# ==========================================
# START BOSS FIGHT
# ==========================================

func start_boss_fight() -> void:

	if is_running_sequence or not is_alive:
		return

	is_running_sequence = true

	run_boss_sequence()


# ==========================================
# SEQUENCE CONTROLLER
# ==========================================

func run_boss_sequence() -> void:

	while is_alive:

		for instruction in boss_sequence:

			if not is_alive:
				break

			await execute_instruction(instruction)

	# Sequence automatically repeats when it reaches the end.


# ==========================================
# EXECUTE INSTRUCTIONS
# ==========================================

func execute_instruction(instruction: Dictionary) -> void:

	var action: String = instruction.get("action", "")

	match action:

		"cast":
			var spell: String = instruction.get("spell", "")
			await cast_spell(spell)

		"walk":
			var target: String = instruction.get("target", "")
			await walk_to_position(target)

		"jump":
			var target: String = instruction.get("target", "")
			await jump_to_position(target)

		"wait":
			var duration: float = instruction.get("duration", 1.0)
			await wait_action(duration)

		_:
			push_warning("Unknown boss action: " + action)


# ==========================================
# SPELL CASTING
# ==========================================

func cast_spell(spell_name: String) -> void:

	sprite.play("cast")

	# Wait until the casting animation finishes.
	await sprite.animation_finished

	if not is_alive:
		return

	# Tell the spell system which attack to perform.
	spell_requested.emit(spell_name)

	sprite.play("idle")


# ==========================================
# WALKING
# ==========================================

func walk_to_position(target_name: String) -> void:

	var target: Marker2D = get_target_position(target_name)

	if target == null:
		return

	var direction: float = sign(target.global_position.x - global_position.x)

	if direction == 0:
		sprite.play("idle")
		return

	if direction < 0:
		sprite.play("walk_left")
	else:
		sprite.play("walk_right")

	while absf(global_position.x - target.global_position.x) > 5.0:

		if not is_alive:
			return

		velocity.x = direction * walk_speed

		if not is_on_floor():
			velocity.y += gravity * get_physics_process_delta_time()

		move_and_slide()

		await get_tree().physics_frame

	velocity.x = 0.0
	sprite.play("idle")


# ==========================================
# JUMPING
# ==========================================

func jump_to_position(target_name: String) -> void:

	var target: Marker2D = get_target_position(target_name)

	if target == null:
		return

	var start_position: Vector2 = global_position
	var destination: Vector2 = target.global_position

	var direction: float = sign(destination.x - start_position.x)

	if direction < 0:
		sprite.play("jump_left")
	else:
		sprite.play("jump_right")

	var duration: float = maxf(jump_duration, 0.1)

	# Calculate the velocity needed to reach the destination.
	var horizontal_velocity: float = (
		destination.x - start_position.x
	) / duration

	var vertical_velocity: float = (
		destination.y - start_position.y
		- 0.5 * gravity * duration * duration
	) / duration

	var elapsed: float = 0.0

	while elapsed < duration:

		if not is_alive:
			return

		var delta: float = get_physics_process_delta_time()

		velocity.x = horizontal_velocity
		velocity.y = vertical_velocity + gravity * elapsed

		move_and_slide()

		elapsed += delta

		await get_tree().physics_frame

	velocity = Vector2.ZERO

	sprite.play("idle")


# ==========================================
# WAITING
# ==========================================

func wait_action(duration: float) -> void:

	sprite.play("idle")

	await get_tree().create_timer(duration).timeout


# ==========================================
# POSITION HELPERS
# ==========================================

func get_target_position(target_name: String) -> Marker2D:

	match target_name:

		"left":
			return left_position

		"right":
			return right_position

		_:
			push_warning("Unknown boss position: " + target_name)
			return null


# ==========================================
# DAMAGE AND DEATH
# ==========================================

func take_damage(amount: int) -> void:

	if not is_alive:
		return

	health -= amount

	if health <= 0:
		die()
		return

	sprite.play("hit")


func die() -> void:

	is_alive = false
	is_running_sequence = false

	velocity = Vector2.ZERO

	sprite.play("hit")

	boss_defeated.emit()
