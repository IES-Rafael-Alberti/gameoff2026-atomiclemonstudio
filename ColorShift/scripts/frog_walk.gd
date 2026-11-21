
extends FrogState
class_name FrogWalk

@export_group("Movement")
@export var move_speed: float = 40.0
@export var jump_height: float = 300.0
@export var move_direction: Vector2 = Vector2.LEFT

@export_group("Patrol Limits")
@export var left_limit: Marker2D
@export var right_limit: Marker2D

@export_group("Detection")
@export var chase_range: float = 150.0
@export var max_chase_height: float = 100.0

var player: CharacterBody2D


func enter():
	
	sprite = frog.find_child("Sprite2D", true, false) as AnimatedSprite2D
	
	play_animation("walk")
	setup_hop_animation()

	player = get_tree().get_first_node_in_group("player")


func exit():
	pass


func update(_delta):
	pass


func physics_update(delta):
	if not frog:
		return

	# Buscar al jugador si todavía no lo tenemos.
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	# Comprobar si el jugador está cerca.
	if can_chase_player():
		print("WALK: Jugador detectado. Activando CHASE")
		Transitioned.emit(self, "FrogChase")
		return
	
	# Comprobar los límites de patrulla.
	check_patrol_limits()

	# Movimiento horizontal.
	frog.velocity.x = move_direction.x * move_speed

	# Actualizar orientación.
	update_sprite_direction()

	apply_gravity(delta)

	frog.move_and_slide()


func check_patrol_limits():
	if not left_limit or not right_limit:
		return

	if frog.global_position.x <= left_limit.global_position.x:
		move_direction = Vector2.RIGHT

	elif frog.global_position.x >= right_limit.global_position.x:
		move_direction = Vector2.LEFT


func can_chase_player() -> bool:
	if not is_instance_valid(player):
		return false

	# Distancia horizontal.
	var horizontal_distance = abs(
		player.global_position.x - frog.global_position.x
	)

	# Diferencia vertical: positiva si el jugador está encima.
	var vertical_distance = frog.global_position.y - player.global_position.y

	# Debe estar dentro del rango horizontal.
	if horizontal_distance > chase_range:
		return false

	# Si está demasiado alto, no lo persigue.
	if vertical_distance > max_chase_height:
		return false

	return true


func update_sprite_direction():
	if sprite:
		sprite.flip_h = move_direction.x < 0
