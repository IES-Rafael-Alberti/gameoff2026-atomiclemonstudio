extends Node

enum Colors { GREY, RED, BLUE, YELLOW }
enum Colors2 { ORANGE, PURPLE, GREEN }

var wheel_1_color: Colors = Colors.GREY
var wheel_2_color: Colors = Colors.GREY
var actual_color: String = "GREY"
var actual_color_index: int = 0
signal color_changed(color: String)

var player_has_key: bool = false
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

var color_blind_mode: String = "Normal"

signal button_pressed_signal

func _ready() -> void:
	update_color()

func change_color(wheel: int) -> void:
	match wheel:
		1:
			wheel_1_color = ((wheel_1_color + 1) % Colors.size()) as Colors
		2:
			wheel_2_color = ((wheel_2_color + 1) % Colors.size()) as Colors
		_:
			return

	update_color()


func preview_color(wheel: int) -> String:
	var preview_wheel_1: Colors = wheel_1_color
	var preview_wheel_2: Colors = wheel_2_color

	match wheel:
		1:
			preview_wheel_1 = ((preview_wheel_1 + 1) % Colors.size()) as Colors
		2:
			preview_wheel_2 = ((preview_wheel_2 + 1) % Colors.size()) as Colors
		_:
			return get_color_name()

	if preview_wheel_1 == preview_wheel_2:
		return Colors.keys()[preview_wheel_1]
	if preview_wheel_1 == Colors.GREY:
		return Colors.keys()[preview_wheel_2]
	if preview_wheel_2 == Colors.GREY:
		return Colors.keys()[preview_wheel_1]

	if (preview_wheel_1 == Colors.RED and preview_wheel_2 == Colors.YELLOW) or \
			(preview_wheel_1 == Colors.YELLOW and preview_wheel_2 == Colors.RED):
		return "ORANGE"
	if (preview_wheel_1 == Colors.RED and preview_wheel_2 == Colors.BLUE) or \
			(preview_wheel_1 == Colors.BLUE and preview_wheel_2 == Colors.RED):
		return "PURPLE"
	if (preview_wheel_1 == Colors.YELLOW and preview_wheel_2 == Colors.BLUE) or \
			(preview_wheel_1 == Colors.BLUE and preview_wheel_2 == Colors.YELLOW):
		return "GREEN"

	return Colors.keys()[preview_wheel_1]


func update_color() -> void:
	actual_color = get_color_name()
	match actual_color:
		"GREY":
			actual_color_index = 0
		"RED", "ORANGE":
			actual_color_index = 1
		"BLUE", "PURPLE":
			actual_color_index = 2
		"YELLOW", "GREEN":
			actual_color_index = 3
	print("Color changed: ", actual_color)
	color_changed.emit(actual_color)

func reset_color() -> void:
	wheel_1_color = Colors.GREY
	wheel_2_color = Colors.GREY
	update_color()

func get_color_name() -> String:
	if wheel_1_color == wheel_2_color:
		return Colors.keys()[wheel_1_color]
	if wheel_1_color == Colors.GREY:
		return Colors.keys()[wheel_2_color]
	if wheel_2_color == Colors.GREY:
		return Colors.keys()[wheel_1_color]

	if (wheel_1_color == Colors.RED and wheel_2_color == Colors.YELLOW) or \
			(wheel_1_color == Colors.YELLOW and wheel_2_color == Colors.RED):
		return "ORANGE"
	if (wheel_1_color == Colors.RED and wheel_2_color == Colors.BLUE) or \
			(wheel_1_color == Colors.BLUE and wheel_2_color == Colors.RED):
		return "PURPLE"
	if (wheel_1_color == Colors.YELLOW and wheel_2_color == Colors.BLUE) or \
			(wheel_1_color == Colors.BLUE and wheel_2_color == Colors.YELLOW):
		return "GREEN"

	return Colors.keys()[wheel_1_color]

func button_pressed(button_id: int) -> void:
	button_pressed_signal.emit(button_id)
