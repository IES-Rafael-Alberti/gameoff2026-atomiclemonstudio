
extends FrogState
class_name FrogDeath


func enter():
	if not frog:
		return

	# Detener completamente el movimiento.
	frog.velocity = Vector2.ZERO

	# Evitar que la rana siga interactuando.
	frog.set_physics_process(false)

	if sprite:
		sprite.position.y = sprite_ground_y
		sprite.play("death")

		# Esperar a que termine la animación.
		await sprite.animation_finished

	# Eliminar la rana.
	if is_instance_valid(frog):
		frog.queue_free()


func exit():
	pass


func update(_delta):
	pass


func physics_update(_delta):
	pass
