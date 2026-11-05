extends Node

var dead: bool = false
signal game_over

func die() -> void:
	if dead: return
	dead = true
	
	game_over.emit()
	visual_die()

func visual_die():
	# Logic to change the shader to represent the character is hit and dead
	
	# TODO: we have to put has a variable the animated sprite of the character and link the shaderMaterial in it
	
	var material_shader = animated_sprite_2d.material
	if material_shader is ShaderMaterial:
		material_shader.set_shader_parameter("progress", 0.0)
		
		var tween = create_tween()
		tween.tween_property(material_shader, "shader_parameter/progress", 1.0, 1.0)
		
		# tween.tween_callback(queue_free) # Esto borraría al nodo del personaje al terminar
