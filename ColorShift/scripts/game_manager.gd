extends Node

enum Colors { GREY, RED, BLUE, YELLOW }

var actual_color_index: int = 0
var actual_color: Colors = Colors.GREY

signal color_changed(color: String)

func _ready() -> void:
	update_color()

func change_color() -> void:
	# Advance to the next color
	actual_color_index = (actual_color_index + 1) % Colors.size()

	update_color()

func update_color() -> void:
	actual_color = actual_color_index
	var color_name = Colors.keys()[actual_color_index]

	print("Color changed: ", color_name)

	# Notify every listener
	color_changed.emit(color_name)
