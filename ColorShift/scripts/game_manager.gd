
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
# The left wheel (wheel 2) is unlocked by its level 4 pickup. Both wheels start
# on GREY (the transparent slot), so every level begins with the neutral color.
var has_second_wheel: bool = false
var current_level_number: int = 0
var shift_cooldown_remaining: float = 0.0
const BOSS_SHIFT_COOLDOWN := 1.0
signal color_changed(color: String)
signal shift_cooldown_changed(remaining: float)

var player_has_key: bool = false
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

var color_blind_mode: String = "Normal"

const number_of_carrots: int = 10
var carrots_picked: int = 0
signal carrot_collected
const PROGRESS_SAVE_PATH := "user://collectables.cfg"
var _collected_collectables: Dictionary = {}

signal button_pressed_signal


func _ready() -> void:
	_load_progress()
	update_color()

func _process(delta: float) -> void:
	if shift_cooldown_remaining <= 0.0:
		return

	shift_cooldown_remaining = maxf(shift_cooldown_remaining - delta, 0.0)
	shift_cooldown_changed.emit(shift_cooldown_remaining)

func configure_for_scene(scene_name: String) -> void:
	current_level_number = 0
	shift_cooldown_remaining = 0.0
	shift_cooldown_changed.emit(shift_cooldown_remaining)
	if not scene_name.begins_with("level_"):
		return

	var level_number_text := scene_name.trim_prefix("level_")
	if not level_number_text.is_valid_int():
		return

	current_level_number = int(level_number_text)

func can_use_second_wheel() -> bool:
	return has_second_wheel and (current_level_number == 0 or current_level_number >= 4)

func try_begin_shift() -> bool:
	if current_level_number == 8:
		if shift_cooldown_remaining > 0.0:
			return false
		shift_cooldown_remaining = BOSS_SHIFT_COOLDOWN
		shift_cooldown_changed.emit(shift_cooldown_remaining)
	return true

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
	wheel_2_color = Colors.GREY
	_save_progress()
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

func is_collectable_collected(collectable_id: String) -> bool:
	return _collected_collectables.has(collectable_id)

func collect_carrot(collectable_id: String) -> bool:
	if is_collectable_collected(collectable_id):
		return false

	_collected_collectables[collectable_id] = true
	carrots_picked = mini(_collected_collectables.size(), number_of_carrots)
	_save_progress()
	carrot_collected.emit()
	return true

func _load_progress() -> void:
	var config := ConfigFile.new()
	var error := config.load(PROGRESS_SAVE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return
	if error != OK:
		push_error("GameManager: no se pudo cargar el progreso (código %d)." % error)
		return

	var saved_ids: PackedStringArray = config.get_value("collectables", "collected", PackedStringArray())
	for collectable_id in saved_ids:
		_collected_collectables[collectable_id] = true
	carrots_picked = mini(_collected_collectables.size(), number_of_carrots)
	has_second_wheel = config.get_value("progress", "second_wheel_unlocked", false)

func _save_progress() -> void:
	var config := ConfigFile.new()
	var error := config.load(PROGRESS_SAVE_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_error("GameManager: no se pudo leer el progreso (código %d)." % error)
		return

	var saved_ids := PackedStringArray()
	for collectable_id in _collected_collectables:
		saved_ids.append(collectable_id)
	config.set_value("collectables", "collected", saved_ids)
	config.set_value("progress", "second_wheel_unlocked", has_second_wheel)

	error = config.save(PROGRESS_SAVE_PATH)
	if error != OK:
		push_error("GameManager: no se pudo guardar el progreso (código %d)." % error)
