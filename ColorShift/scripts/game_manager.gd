
extends Node

enum Colors { GREY, RED, BLUE, YELLOW }

# Color order of each wheel, as drawn in its sprite: the active color is on
# top and every Shift turns the wheel to the next one.
const WHEEL_ORDER := {
	1: [Colors.GREY, Colors.YELLOW, Colors.BLUE, Colors.RED],
	2: [Colors.GREY, Colors.RED, Colors.BLUE, Colors.YELLOW],
}

var wheel_1_color: Colors = Colors.GREY
var wheel_2_color: Colors = Colors.GREY
var actual_color: String = "GREY"

# The left wheel (wheel 2) is collected in level_color_test.
var has_second_wheel: bool = false

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
			wheel_1_color = WHEEL_ORDER[1][(get_wheel_step(1) + 1) % 4]
		2:
			wheel_2_color = WHEEL_ORDER[2][(get_wheel_step(2) + 1) % 4]
		_:
			return

	update_color()


# Position (0-3) of the wheel in its color order.
func get_wheel_step(wheel: int) -> int:
	return WHEEL_ORDER[wheel].find(
		wheel_1_color if wheel == 1 else wheel_2_color
	)


# The left wheel is the right one turned upside down.
func _opposite_of_right_wheel() -> Colors:
	return WHEEL_ORDER[1][(get_wheel_step(1) + 2) % 4]


func obtain_second_wheel() -> void:
	has_second_wheel = true
	wheel_2_color = _opposite_of_right_wheel()
	update_color()


func update_color() -> void:
	actual_color = get_color_name()
	print("Color changed: ", actual_color)
	color_changed.emit(actual_color)


func reset_color() -> void:
	wheel_1_color = Colors.GREY
	wheel_2_color = _opposite_of_right_wheel() if has_second_wheel else Colors.GREY
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


# --------------------------------------------------
# RANDOM COLOR
# --------------------------------------------------

func randomize_color() -> void:
	var possible_colors: Array[String] = [
		"GREY",
		"RED",
		"BLUE",
		"YELLOW"
	]

	# Mixed colors are only available after obtaining the second wheel.
	if has_second_wheel:
		possible_colors.append_array([
			"ORANGE",
			"PURPLE",
			"GREEN"
		])

	# Avoid selecting the current color.
	possible_colors.erase(get_color_name())

	if possible_colors.is_empty():
		return

	var selected_color: String = possible_colors.pick_random()

	match selected_color:
		"GREY":
			wheel_1_color = Colors.GREY
			wheel_2_color = Colors.GREY

		"RED":
			wheel_1_color = Colors.RED
			wheel_2_color = Colors.GREY

		"BLUE":
			wheel_1_color = Colors.BLUE
			wheel_2_color = Colors.GREY

		"YELLOW":
			wheel_1_color = Colors.YELLOW
			wheel_2_color = Colors.GREY

		"ORANGE":
			wheel_1_color = Colors.RED
			wheel_2_color = Colors.YELLOW

		"PURPLE":
			wheel_1_color = Colors.RED
			wheel_2_color = Colors.BLUE

		"GREEN":
			wheel_1_color = Colors.YELLOW
			wheel_2_color = Colors.BLUE

	update_color()


func button_pressed(button_id: int) -> void:
	button_pressed_signal.emit(button_id)
