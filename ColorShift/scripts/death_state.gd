extends State

## Plays the death animation and restarts the level when it finishes.
## The old character fade-out was removed: the animation is the death feedback.

const DEATH_ANIMATION := "death"

var _restarting: bool = false


func enter() -> void:
	if _restarting:
		return
	_restarting = true

	var character = state_machine.get_parent() as CharacterBody2D
	if character == null:
		SceneManager.reload_scene()
		return

	character.velocity = Vector2.ZERO

	var sprite := character.get_node_or_null("%PlayerSkin") as AnimatedSprite2D
	var animation := _find_death_animation(sprite)

	if animation == &"":
		# If the animation is missing, keep a short pause before restarting.
		await get_tree().create_timer(0.5).timeout
		SceneManager.reload_scene()
		return

	# Stop on the last frame so animation_finished can be awaited.
	sprite.sprite_frames.set_animation_loop(animation, false)
	sprite.play(animation)
	await sprite.animation_finished
	SceneManager.reload_scene()


func _find_death_animation(sprite: AnimatedSprite2D) -> StringName:
	if sprite == null or sprite.sprite_frames == null:
		return &""

	for animation_name in sprite.sprite_frames.get_animation_names():
		if String(animation_name).to_lower() == DEATH_ANIMATION:
			return StringName(animation_name)

	return &""
