
extends CharacterBody2D

signal boss_defeated

@export var projectile_scene: PackedScene
@export var heatseeker_scene: PackedScene

@export var left_position: Marker2D
@export var right_position: Marker2D

@export var walk_speed: float = 100.0
@export var jump_duration: float = 0.8
@export var gravity: float = 980.0

@export var health: int = 100

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

# Recovery settings.
@export var spike_check_offset_y: float = 20.0
@export var spike_check_offset_x: float = 10.0
@export var recovery_jump_height: float = 80.0
@export var recovery_jump_duration: float = 0.5
@export var fall_limit_y: float = 260.0

@onready var sprite: AnimatedSprite2D = $Chameleon
@onready var attack_point: Marker2D = $AttackPoint

var is_alive: bool = true
var is_running_sequence: bool = false

# Movement control.
var is_moving: bool = false
var movement_target_x: float = 0.0

# Recovery control.
var is_recovering: bool = false


var boss_sequence: Array[Dictionary] = [
	{"action": "cast", "spell": "projectile"},
	{"action": "wait", "duration": 1.0},

	{"action": "jump", "target": "left"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "heatseeker"},
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


# --------------------------------------------------
# PHYSICS
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# The recovery tween controls movement while recovering.
	if is_recovering:
		return

	# Apply gravity whenever the Chameleon is not standing
	# on a floor.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# Horizontal movement.
	if is_moving:
		var distance: float = movement_target_x - global_position.x

		if absf(distance) <= 4.0:
			is_moving = false
			velocity.x = 0.0
		else:
			velocity.x = signf(distance) * walk_speed
	else:
		velocity.x = 0.0

	move_and_slide()

	# Check for spikes or falling below the level.
	if global_position.y > fall_limit_y or _is_over_spike():
		_start_recovery()


# --------------------------------------------------
# SPIKE DETECTION
# --------------------------------------------------

func _is_over_spike() -> bool:
	var tile_layers := get_tree().get_nodes_in_group("tile_layers")

	# Check three positions around the Chameleon's feet.
	var check_positions: Array[Vector2] = [
		global_position + Vector2(0.0, spike_check_offset_y),
		global_position + Vector2(-spike_check_offset_x, spike_check_offset_y),
		global_position + Vector2(spike_check_offset_x, spike_check_offset_y)
	]

	for node in tile_layers:
		var layer := node as TileMapLayer

		if layer == null:
			continue

		# Only check the original TileMapLayer.
		# Generated color layers don't have interactive_tiles.
		if not layer.has_method("get_tile_properties"):
			continue

		var interactive_tiles: Variant = layer.get("interactive_tiles")

		if not interactive_tiles is Dictionary:
			continue

		for check_position in check_positions:
			var local_position: Vector2 = layer.to_local(check_position)
			var cell: Vector2i = layer.local_to_map(local_position)

			# Read the original cached properties directly.
			# This deliberately ignores the active color, so spikes
			# of every color can trigger the recovery.
			var props: Dictionary = interactive_tiles.get(cell, {})

			if props.get("SPIKE", false):
				return true

	return false


# --------------------------------------------------
# RECOVERY
# --------------------------------------------------

func _start_recovery() -> void:
	if is_recovering or not is_alive:
		return

	is_recovering = true
	is_moving = false

	velocity = Vector2.ZERO

	# Collect the available marker positions.
	var available_markers: Array[Marker2D] = []

	if left_position != null:
		available_markers.append(left_position)

	if right_position != null:
		available_markers.append(right_position)

	if available_markers.is_empty():
		push_error("Chameleon: No recovery markers assigned!")
		is_recovering = false
		return

	# Choose a random marker.
	var target_marker: Marker2D = available_markers.pick_random()
	var target_position: Vector2 = target_marker.global_position
	var starting_position: Vector2 = global_position

	# Play the appropriate jump animation.
	if target_position.x < global_position.x:
		sprite.play("jump_left")
	else:
		sprite.play("jump_right")

	# Create a jump arc.
	var apex_position: Vector2 = Vector2(
		(starting_position.x + target_position.x) * 0.5,
		minf(starting_position.y, target_position.y) - recovery_jump_height
	)

	var tween := create_tween()

	# First half: jump towards the middle of the marker.
	tween.tween_property(
		self,
		"global_position",
		apex_position,
		recovery_jump_duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Second half: land at the marker.
	tween.tween_property(
		self,
		"global_position",
		target_position,
		recovery_jump_duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished

	if not is_alive:
		return

	global_position = target_position
	velocity = Vector2.ZERO
	movement_target_x = target_position.x

	sprite.play("idle")

	is_recovering = false


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

			# Pause the attack pattern during recovery.
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

	if is_alive and not is_recovering:
		sprite.play("idle")


func spawn_spell(spell_name: String) -> void:
	match spell_name:
		"projectile":
			await spawn_projectile_attack()

		"heatseeker":
			spawn_heatseeker()

		"platforms_spell":
			GameManager.randomize_color()

		_:
			push_warning("Unknown Chameleon spell: " + spell_name)


# --------------------------------------------------
# HEATSEEKER
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

	heatseeker.call(
		"setup",
		selected_color,
		heatseeker_speed,
		heatseeker_damage
	)

	get_tree().current_scene.add_child(heatseeker)
	heatseeker.global_position = attack_point.global_position


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

	var screen_to_world: Transform2D = (
		get_viewport().get_canvas_transform().affine_inverse()
	)

	var top_world: Vector2 = screen_to_world * Vector2.ZERO

	var bottom_world: Vector2 = screen_to_world * Vector2(
		0.0,
		viewport_size.y
	)

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
			push_error("Chameleon: Projectile root must be Area2D!")
			return

		projectile.call("setup", color, projectile_speed)

		get_tree().current_scene.add_child(projectile)

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
# MOVEMENT
# --------------------------------------------------

func walk_to_target(target: String) -> void:
	if not is_alive:
		return

	var destination: Vector2 = _get_target_position(target)

	movement_target_x = destination.x
	is_moving = true

	if target == "left":
		sprite.play("walk_left")
	else:
		sprite.play("walk_right")

	while is_moving and is_alive:
		await get_tree().physics_frame

	velocity.x = 0.0

	if is_alive and not is_recovering:
		sprite.play("idle")


func jump_to_target(target: String) -> void:
	if not is_alive:
		return

	while not is_on_floor() and is_alive and not is_recovering:
		await get_tree().physics_frame

	if not is_alive or is_recovering:
		return

	var destination: Vector2 = _get_target_position(target)

	movement_target_x = destination.x
	is_moving = true

	velocity.y = -(gravity * jump_duration * 0.5)

	if target == "left":
		sprite.play("jump_left")
	else:
		sprite.play("jump_right")

	while (is_moving or not is_on_floor()) and is_alive and not is_recovering:
		await get_tree().physics_frame

	velocity.x = 0.0

	if is_alive and not is_recovering:
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
	is_moving = false
	is_recovering = false

	velocity = Vector2.ZERO

	boss_defeated.emit()

	queue_free()
