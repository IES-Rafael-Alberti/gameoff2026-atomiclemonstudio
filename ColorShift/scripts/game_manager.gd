extends Node

enum Colors { GREY, RED, BLUE, YELLOW }

var actual_color_index: int = 0
var actual_color: Colors = Colors.GREY
signal color_changed(color: String)

var player_has_key: bool = false
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

var color_blind_mode: String = "Normal"

func _ready() -> void:
	update_color()

func change_color() -> void:
	# Advance to the next color
	actual_color_index = (actual_color_index + 1) % Colors.size()

	update_color()


func update_color() -> void:
	# Convertimos el entero (int) al tipo del enum (Colors)
	actual_color = actual_color_index as Colors

	var color_name = get_color_name()
	print("Color changed: ", color_name)
	# Notify every listener
	color_changed.emit(color_name)

func reset_color() -> void:
	actual_color_index = 0
	update_color()

func get_color_name() -> String:
	# Name of the active color. Listeners use it to apply the initial
	# state without waiting for the next color change.
	return Colors.keys()[actual_color_index]
