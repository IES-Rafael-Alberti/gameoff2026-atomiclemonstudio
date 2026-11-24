extends Node

enum Colors { GREY, RED, BLUE, YELLOW }

# Color order of each wheel, as drawn in its sprite: the active color is on
# top and every Shift turns the wheel to the next one.
const WHEEL_ORDER := {
	1: [Colors.GREY, Colors.YELLOW, Colors.BLUE, Colors.RED], # Wheel_Right_Turn.png
	2: [Colors.GREY, Colors.RED, Colors.BLUE, Colors.YELLOW], # Wheel_Left_Turn.png
}

var wheel_1_color: Colors = Colors.GREY
var wheel_2_color: Colors = Colors.GREY
var actual_color: String = "GREY"
# The left wheel (wheel 2) is collected in level_color_test. Both wheels start
# on GREY (the transparent slot), so every level begins with the neutral color.
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
	return WHEEL_ORDER[wheel].find(wheel_1_color if wheel == 1 else wheel_2_color)


func obtain_second_wheel() -> void:
	has_second_wheel = true
	wheel_2_color = Colors.GREY
	update_color()


func update_color() -> void:
	actual_color = get_color_name()
	print("Color changed: ", actual_color)
	color_changed.emit(actual_color)

func reset_color() -> void:
	# Keep the second wheel unlocked, but put both discs on GREY again.
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
