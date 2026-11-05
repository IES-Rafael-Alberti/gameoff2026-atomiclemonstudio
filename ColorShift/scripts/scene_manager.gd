extends Node

# Add here all the level paths
const menu_path: String = "res://scenes/menu.tscn"
const demo_level_path: String = "res://scenes/demo_level.tscn"
const level_1_path: String = "res://scenes/level_1.tscn"
const level_2_path: String = "res://scenes/level_2.tscn"

var paths = {
	"DEMO_LEVEL": demo_level_path, 
	"LEVEL_1": level_1_path, 
	"LEVEL_2": level_2_path
	}

var actual_scene: String = "No Scene"

func change_scene(scene_name: String):
	
	# Fade out to black when changes scenes
	var color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(color_rect)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# Change the scene
	var scene_path: String = paths.get(scene_name)
	
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("Error when changing to scene: ", scene_name)
	
	actual_scene = scene_name
	
	# Fade in when the scene already changed
	await get_tree().process_frame
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	await tween_in.finished
	
	color_rect.queue_free()

func reload_scene():
	get_tree().reload_current_scene()

func get_actual_scene() -> String:
	return actual_scene
