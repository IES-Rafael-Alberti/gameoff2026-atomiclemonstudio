extends Area2D

signal collected

var _collectable_id: String


func _ready() -> void:
	_collectable_id = _make_collectable_id()
	if GameManager.is_collectable_collected(_collectable_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not GameManager.collect_carrot(_collectable_id):
		return

	MusicAndSounds.play_collectable()
	collected.emit()

	queue_free()


func _make_collectable_id() -> String:
	var scene := get_tree().current_scene
	var scene_path := scene.scene_file_path if scene != null else "unknown_scene"
	return "%s:%d:%d" % [
		scene_path,
		roundi(global_position.x),
		roundi(global_position.y),
	]
