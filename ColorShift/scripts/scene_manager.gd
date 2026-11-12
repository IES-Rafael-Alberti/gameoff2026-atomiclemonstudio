extends Node

signal scene_change_started(scene_name: String)
signal scene_changed(scene_name: String)

const FADE_TIME := 0.5

# A single place to register scenes: name -> path
const SCENES := {
	"main_menu": "res://scenes/main_menu.tscn",
	"pause_menu": "res://scenes/pause_menu.tscn",
	"options_menu": "res://scenes/options_menu.tscn",
	"demo_level": "res://scenes/demo_level.tscn",
	"level_1": "res://scenes/level_1.tscn",
	"level_2": "res://scenes/level_2.tscn",
	"credits": "res://scenes/credits.tscn",
}

var current_scene_name: String = ""
var is_transitioning: bool = false

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect


func _ready() -> void:
	# Ensure the fade effect works even while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100 # above any HUD
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	_fade_layer.add_child(_fade_rect)


func change_scene(scene_name: String) -> void:
	var key := scene_name.to_lower()

	if not SCENES.has(key):
		push_error("SceneManager: la escena '%s' no está registrada." % scene_name)
		return
	if is_transitioning:
		return

	is_transitioning = true
	scene_change_started.emit(key)

	await _fade_to(1.0)

	var error := get_tree().change_scene_to_file(SCENES[key])
	if error != OK:
		push_error("SceneManager: error al cargar '%s' (código %d)." % [key, error])
	else:
		current_scene_name = key

	# change_scene_to_file is deferred: we wait for the new scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	await _fade_to(0.0)

	is_transitioning = false
	if error == OK:
		scene_changed.emit(key)


func reload_scene() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	# Reset level also reset the color filter
	GameManager.reset_color()

	await _fade_to(1.0)
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade_to(0.0)

	is_transitioning = false


func get_current_scene() -> String:
	return current_scene_name


func _fade_to(target_alpha: float) -> void:
	# While a fade is in progress, mouse input is blocked
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", target_alpha, FADE_TIME)
	await tween.finished
	if target_alpha == 0.0:
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
