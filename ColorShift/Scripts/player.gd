extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -350.0
const JUMP_DELAY = 0.10

var jump_timer = 0.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dead: bool = false
signal game_over

@onready var animated_sprite = $PlayerSkin

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_timer > 0.0:
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if is_on_floor():
		jump_timer = JUMP_DELAY
	else:
		jump_timer -= delta
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	
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
