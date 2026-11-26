extends Node

const CONTENT_SIZE := Vector2i(1366, 768)
const TIMELINE := "timeline"

var _original_content_size := Vector2i.ZERO


func _ready() -> void:
	var window := get_window()
	_original_content_size = window.content_scale_size
	window.content_scale_size = CONTENT_SIZE

	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)
	Dialogic.start(TIMELINE)


func _exit_tree() -> void:
	if _original_content_size != Vector2i.ZERO:
		get_window().content_scale_size = _original_content_size


func _on_timeline_ended() -> void:
	SceneManager.change_scene("main_menu")
