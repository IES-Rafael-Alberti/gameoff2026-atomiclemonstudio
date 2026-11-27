
extends FrogState
class_name FrogChase

@export var chase_speed: float = 65.0
@export var turn_threshold: float = 12.0

var last_direction: float = 1.0
var player: Node2D
var walk_state: FrogWalk


func enter():
	# La rana es el padre de la máquina de estados.
	frog = get_parent().get_parent() as CharacterBody2D

	# Obtener el sprite de la rana.
	if frog:
		# Buscar automáticamente el AnimatedSprite2D.
		sprite = frog.find_child("Sprite2D", true, false) as AnimatedSprite2D

	# Buscar FrogWalk dentro de la máquina.
	walk_state = get_parent().get_node_or_null("FrogWalk") as FrogWalk

	# Buscar al jugador.
	find_player()

	play_animation("walk")
	setup_hop_animation()

	print("========== FROG CHASE ==========")
	print("Frog encontrada: ", frog != null)
	print("Walk encontrado: ", walk_state != null)
	print("Player encontrado: ", player != null)


func exit():
	pass


func update(_delta):
	pass


func physics_update(delta):
	if not frog:
		return

	if not is_instance_valid(player):
		find_player()

	if not is_instance_valid(player):
		Transitioned.emit(self, "FrogWalk")
		return

	if not walk_state:
		return

	# Calcular distancia horizontal y vertical.
	var distance_x: float = player.global_position.x - frog.global_position.x
	var distance_y: float = frog.global_position.y - player.global_position.y

	# Comprobar rango de persecución.
	if abs(distance_x) > walk_state.chase_range:
		Transitioned.emit(self, "FrogWalk")
		return

	# Comprobar altura máxima.
	if distance_y > walk_state.max_chase_height:
		Transitioned.emit(self, "FrogWalk")
		return

	# Calcular dirección hacia el jugador.
	var direction: float = sign(distance_x)

	# Moverse horizontalmente.
	frog.velocity.x = direction * chase_speed

	# Girar el sprite dependiendo de dónde esté el jugador.
	if direction != 0 and is_instance_valid(sprite):
		sprite.flip_h = direction < 0

	# Aplicar gravedad y movimiento.
	apply_gravity(delta)
	frog.move_and_slide()


func find_player():
	player = get_tree().get_first_node_in_group("player") as Node2D
