
extends Node
class_name FrogState

signal Transitioned(frogstate, new_frogstate_name)

@export var frog: CharacterBody2D
@export var sprite: AnimatedSprite2D

var sprite_ground_y: float

var hop_offsets: Array[float] = [
	0.0,
	-2.0,
	-4.0,
	-7.0,
	-10.0,
	-8.0,
	-4.0,
	0.0
]


func _ready():
	if sprite:
		sprite_ground_y = sprite.position.y


func enter():
	pass


func exit():
	pass


func update(_delta: float):
	pass


func physics_update(_delta: float):
	pass


func play_animation(animation_name: String):
	if sprite and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)


# Conectar el movimiento del sprite con los frames.
func setup_hop_animation():
	if not sprite:
		return

	if not sprite.frame_changed.is_connected(_update_hop_frame):
		sprite.frame_changed.connect(_update_hop_frame)

	_update_hop_frame()


func _update_hop_frame():
	if not sprite:
		return

	if sprite.animation != "walk":
		return

	var current_frame: int = sprite.frame

	if current_frame >= 0 and current_frame < hop_offsets.size():
		sprite.position.y = sprite_ground_y + hop_offsets[current_frame]


func apply_gravity(delta: float):
	if frog and not frog.is_on_floor():
		var gravity: float = ProjectSettings.get_setting(
			"physics/2d/default_gravity"
		)
		frog.velocity.y += gravity * delta
