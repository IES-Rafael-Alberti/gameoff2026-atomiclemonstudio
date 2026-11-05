extends Node

enum colors {GREY, RED, BLUE, YELLOW}
var actual_color_index = 0
var actual_color = null

# Emitted whenever the active color changes.
signal color_changed(color: String)

func _ready() -> void:
	actual_color = colors.find_key(actual_color_index)

func _on_change_color():
	# Advance to the next color, wrapping around to the first one at the end
	actual_color_index = (actual_color_index + 1) % colors.size()
	actual_color = colors.keys()[actual_color_index]
	print("color cambiado: ", actual_color)
	
	# Notify every listener of the new color
	color_changed.emit(actual_color)
