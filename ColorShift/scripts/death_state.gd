extends State

# Seconds the character takes to fade out before the level restarts.
@export var fade_duration: float = 0.5

var _restarting: bool = false

func enter() -> void:
	if _restarting:
		return

	_restarting = true
	print("Entering death state")

	var character = state_machine.get_parent() as CharacterBody2D
	if character == null:
		SceneManager.reload_scene()
		return

	character.velocity = Vector2.ZERO

	# Death feedback: the whole character fades out, then the level restarts.
	var tween := create_tween()
	tween.tween_property(character, "modulate:a", 0.0, fade_duration)
	await tween.finished

	SceneManager.reload_scene()
