
extends CharacterBody2D

signal boss_defeated

const POOF_EFFECT_SCRIPT: Script = preload("res://scripts/poof_effect.gd")

# These sheets are drawn facing left and are mirrored to face the player.
# walk/jump have their own _left/_right sheets and are never mirrored.
const FACE_PLAYER_ANIMATIONS: Array[StringName] = [&"cast", &"idle", &"hit"]

enum BossState { ON_PLATFORM, JUMPING, FALLING, HIT, RECOVERING }

@export var projectile_scene: PackedScene
@export var heatseeker_scene: PackedScene
@export var platforms_spell_scene: PackedScene

@export var left_position: Marker2D
@export var right_position: Marker2D
# ChameleonMarkers: every Marker2D in it is a spot to jump or recover to.
@export var chameleon_markers: Node

@export var walk_speed: float = 100.0
@export var jump_duration: float = 0.8
@export var gravity: float = 980.0

@export var health: int = 100

# Life counter for spike/fall hits. Change this in the inspector to decide
# how many times the Chameleon can fall before it is defeated.
@export var max_hits: int = 3
# Shows the lives left (max_hits - hits_taken).
@export var health_bar: ProgressBar

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
# Level TileMapLayer (tile_map_manager.gd): it already knows where spikes are.
@export var tile_layer: TileMapLayer
@export var spike_check_offset_y: float = 20.0
@export var spike_check_offset_x: float = 10.0
@export var recovery_jump_height: float = 80.0
@export var recovery_jump_duration: float = 0.5
@export var fall_limit_y: float = 270.0

@onready var sprite: AnimatedSprite2D = $Chameleon
@onready var attack_point: Marker2D = $AttackPoint

var is_alive: bool = true
var is_running_sequence: bool = false

# Movement control.
var is_moving: bool = false
var movement_target_x: float = 0.0

var state: BossState = BossState.ON_PLATFORM
var hits_taken: int = 0

# Movelist step being run. It only advances when a step finishes, so a step
# cut short by a fall is retried once the boss is back on its platform.
var _step: int = 0
# Bumped to cancel the running step: every step checks it after each await.
var _action_id: int = 0
var _markers: Array[Marker2D] = []


var boss_sequence: Array[Dictionary] = [
	{"action": "cast", "spell": "projectile"},
	{"action": "wait", "duration": 1.0},

	# Jumps pick a random marker other than the current one.
	{"action": "jump"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "heatseeker"},
	{"action": "wait", "duration": 1.5},

	{"action": "walk", "target": "right"},
	{"action": "wait", "duration": 0.5},

	{"action": "cast", "spell": "platforms_spell"},
	{"action": "wait", "duration": 2.0},

	{"action": "jump"},
	{"action": "wait", "duration": 1.0}
]


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	_play(&"idle")
	_update_health_bar()

	if chameleon_markers == null:
		push_error("Chameleon: chameleon_markers is not assigned!")
		return

	for child in chameleon_markers.get_children():
		if child is Marker2D:
			_markers.append(child)


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D

	sprite.flip_h = (
		sprite.animation in FACE_PLAYER_ANIMATIONS
		and player != null
		and player.global_position.x > global_position.x
	)


# --------------------------------------------------
# ANIMATION CONTROL
# --------------------------------------------------

func _on_animation_finished() -> void:
	# cast and hit are one-shot. When their frames run out show idle, but
	# leave the state and the running step alone: a cast keeps casting.
	# The spike hit chains into cast itself.
	if state != BossState.HIT:
		sprite.play(&"idle")


# --------------------------------------------------
# HELPERS
# --------------------------------------------------

# Node-bound wait: it pauses with the game (a tree timer keeps running in the
# pause menu) and is dropped with the boss instead of resuming on a freed node.
func _wait(seconds: float) -> void:
	await create_tween().tween_interval(seconds).finished


func _play(animation: StringName) -> void:
	# play() alone keeps going if that animation is already on screen.
	sprite.stop()
	sprite.play(animation)


func _animation_length(animation: StringName) -> float:
	var frames: SpriteFrames = sprite.sprite_frames
	return frames.get_frame_count(animation) / maxf(frames.get_animation_speed(animation), 0.001)


func _spell_parent() -> Node:
	# current_scene is not set in every context (e.g. during scene changes).
	# Falling back to the tree root keeps the attack from silently failing.
	var current_scene: Node = get_tree().current_scene
	return current_scene if current_scene != null else get_tree().root


# --------------------------------------------------
# PHYSICS
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	# Jumps, the hit stun and the recovery hop move the boss themselves.
	match state:
		BossState.ON_PLATFORM:
			velocity.y += gravity * delta

			# Horizontal movement.
			velocity.x = 0.0
			if is_moving:
				var distance: float = movement_target_x - global_position.x

				if absf(distance) <= 4.0:
					is_moving = false
				else:
					velocity.x = signf(distance) * walk_speed

			move_and_slide()

			if not is_on_floor():
				_start_fall()

		BossState.FALLING:
			# No collisions while falling, so no platform below can catch the
			# boss: every fall ends on spikes or past fall_limit_y (y grows
			# downwards).
			velocity.y += gravity * delta
			global_position += velocity * delta

			if _is_over_spike():
				_end_fall(true)
			elif global_position.y > fall_limit_y:
				_end_fall(false)


# --------------------------------------------------
# SPIKE DETECTION
# --------------------------------------------------

func _is_over_spike() -> bool:
	if tile_layer == null:
		return false

	# Check three positions around the Chameleon's feet. The tile manager
	# reads its SPIKE cache of every colour, so a spike counts even while
	# its colour is inactive (the boss is not a physics body for those tiles).
	var feet: Vector2 = global_position + Vector2(0.0, spike_check_offset_y)

	for offset_x in [-spike_check_offset_x, 0.0, spike_check_offset_x]:
		if tile_layer.is_spike_at_world_position(feet + Vector2(offset_x, 0.0)):
			return true

	return false


# --------------------------------------------------
# FALL / HIT HANDLING
# --------------------------------------------------

func get_lives_remaining() -> int:
	return maxi(max_hits - hits_taken, 0)


func _update_health_bar() -> void:
	if health_bar == null:
		return

	# ProgressBar clamps value to [0, max_value] by itself.
	health_bar.max_value = max_hits
	health_bar.value = get_lives_remaining() if is_alive else 0


func _start_fall() -> void:
	# Leaving ON_PLATFORM first means physics cannot start the same fall twice.
	state = BossState.FALLING
	# Cancel the running step. Spells already spawned stay in the scene.
	_action_id += 1
	is_moving = false
	velocity = Vector2.ZERO

	# The boss casts (facing the player) while it falls.
	_play(&"cast")


func _end_fall(on_spike: bool) -> void:
	state = BossState.HIT if on_spike else BossState.RECOVERING
	velocity = Vector2.ZERO

	# Every fall costs a life, spikes or not.
	hits_taken += 1
	_update_health_bar()

	if on_spike:
		_play(&"hit")
		await _wait(_animation_length(&"hit"))

	if get_lives_remaining() <= 0:
		_defeat_boss()
		return

	_start_recovery()


# --------------------------------------------------
# RECOVERY
# --------------------------------------------------

func _start_recovery() -> void:
	state = BossState.RECOVERING

	# Return to the marker closest to where the boss fell.
	var target_marker: Marker2D = _nearest_marker(global_position.x)

	if target_marker == null:
		push_error("Chameleon: No recovery markers assigned!")
		return

	# The recovery spell: cast again while hopping back up.
	_play(&"cast")

	await _arc_to(
		target_marker.global_position,
		recovery_jump_height,
		recovery_jump_duration
	)

	# The boss is back on its platform: show the poof now.
	_spawn_poof(global_position + Vector2(0.0, -8.0))

	# The platform may still be gone (the Button brings it back after a few
	# seconds): hover on the marker until it is solid again.
	while not test_move(global_transform, Vector2.DOWN):
		await _wait(0.1)

	state = BossState.ON_PLATFORM

	# Resume the movelist on the step the fall interrupted.
	if is_running_sequence:
		_run_boss_sequence()


func _spawn_poof(at_position: Vector2) -> void:
	var poof := Node2D.new()
	poof.set_script(POOF_EFFECT_SCRIPT)
	_spell_parent().add_child(poof)
	poof.global_position = at_position


# --------------------------------------------------
# BOSS FIGHT
# --------------------------------------------------

func start_boss_fight() -> void:
	if is_running_sequence or not is_alive:
		return

	is_running_sequence = true

	# Mid-fall, _start_recovery() starts the movelist once the boss is back.
	if state == BossState.ON_PLATFORM:
		_run_boss_sequence()


func _run_boss_sequence() -> void:
	# Runs the current step and then chains into the next one. A fall bumps
	# _action_id: this step stops at its next await, and _start_recovery()
	# calls this again to retry the same step.
	var action_id: int = _action_id
	var instruction: Dictionary = boss_sequence[_step]

	match instruction.get("action", ""):
		"wait":
			await _wait(instruction.get("duration", 1.0))

		"cast":
			await cast_spell(instruction.get("spell", ""))

		"walk":
			await walk_to_target(instruction.get("target", "right"))

		"jump":
			await jump_to_target()

	if action_id != _action_id or not is_alive:
		return

	_step = (_step + 1) % boss_sequence.size()
	_run_boss_sequence()


# --------------------------------------------------
# SPELLS
# --------------------------------------------------

func cast_spell(spell_name: String) -> void:
	var action_id: int = _action_id

	_play(&"cast")

	# The spell appears once the cast animation has played through. By then
	# the sprite shows idle, but the step lasts until the spell is done.
	await _wait(_animation_length(&"cast"))

	if action_id != _action_id:
		return

	await spawn_spell(spell_name)


func spawn_spell(spell_name: String) -> void:
	match spell_name:
		"projectile":
			await spawn_projectile_attack()

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
		# The spell scene also performs the colour change; keep the effect
		# working when no visual effect scene has been assigned.
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

func spawn_projectile_attack() -> void:
	if projectile_scene == null:
		push_error("Chameleon: projectile_scene is not assigned!")
		return

	if projectile_colors.is_empty():
		push_warning("Chameleon: No projectile colours configured!")
		return

	var action_id: int = _action_id

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
		spawn_projectile_line(
			color,
			viewport_size,
			screen_to_world
		)

		await _wait(projectile_line_interval)

		# Interrupted: the lines already on screen keep falling.
		if action_id != _action_id:
			return

	var vertical_distance: float = absf(
		bottom_world.y - top_world.y
	)

	var travel_time: float = vertical_distance / maxf(
		projectile_speed,
		1.0
	)

	await _wait(travel_time + 0.2)


func spawn_projectile_line(
	color: String,
	viewport_size: Vector2,
	screen_to_world: Transform2D
) -> void:

	for i in range(projectile_count):
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
# MOVEMENT
# --------------------------------------------------

func walk_to_target(target: String) -> void:
	var action_id: int = _action_id
	var destination: Vector2 = _get_target_position(target)
	var distance: float = destination.x - global_position.x

	if absf(distance) <= 4.0:
		return

	movement_target_x = destination.x
	is_moving = true

	_play(&"walk_right" if distance > 0.0 else &"walk_left")

	# Physics stops the walk at the marker. Waiting the travel time (instead
	# of for the arrival) means a wall in the way cannot hang the step.
	await _wait(absf(distance) / maxf(walk_speed, 1.0))

	if action_id != _action_id:
		return

	is_moving = false
	_play(&"idle")


func jump_to_target() -> void:
	# Jump to one of the markers the boss is not standing on.
	var current_marker: Marker2D = _nearest_marker(global_position.x)
	var free_markers: Array[Marker2D] = _markers.filter(
		func(marker: Marker2D) -> bool: return marker != current_marker
	)

	if free_markers.is_empty():
		push_warning("Chameleon: No free marker to jump to!")
		return

	var destination: Vector2 = free_markers.pick_random().global_position

	state = BossState.JUMPING
	is_moving = false
	velocity = Vector2.ZERO

	_play(&"jump_right" if destination.x > global_position.x else &"jump_left")

	# Same apex the old velocity jump reached with this gravity and air time.
	await _arc_to(
		destination,
		gravity * jump_duration * jump_duration / 8.0,
		jump_duration
	)

	state = BossState.ON_PLATFORM
	_play(&"idle")


func _arc_to(target: Vector2, height: float, duration: float) -> void:
	# Quadratic Bezier with its control point halfway in x: x moves at a
	# constant speed while y follows a parabola, like a real jump, and it
	# lands exactly on the target. With level ends the apex is `height` up.
	var start: Vector2 = global_position
	var control := Vector2(
		(start.x + target.x) * 0.5,
		minf(start.y, target.y) - height * 2.0
	)

	var tween := create_tween()
	tween.tween_method(
		func(t: float) -> void:
			global_position = start.lerp(control, t).lerp(control.lerp(target, t), t),
		0.0,
		1.0,
		duration
	)
	await tween.finished


func _nearest_marker(x: float) -> Marker2D:
	var nearest: Marker2D = null

	for marker in _markers:
		if nearest == null or absf(marker.global_position.x - x) < absf(nearest.global_position.x - x):
			nearest = marker

	return nearest


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

	# Only a visual flinch: the running step and the fall logic carry on.
	if state == BossState.ON_PLATFORM:
		_play(&"hit")


func _defeat_boss() -> void:
	if not is_alive:
		return

	is_alive = false
	is_running_sequence = false
	is_moving = false
	_action_id += 1

	velocity = Vector2.ZERO
	_update_health_bar()

	boss_defeated.emit()

	queue_free()
