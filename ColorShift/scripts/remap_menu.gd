extends Control

signal back_pressed

# Names shown to the player
const ACTION_DISPLAY_NAMES := {
	"jump": "Jump",
	"move_right": "Move right",
	"move_left": "Move left",
	"move_down": "Move down",
	"shift": "Shift",
	"interact": "Interact",
	"pause": "Pause",
	"teleport_checkpoint": "Teleport to checkpoint",
}

@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var reset_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ResetButton
@onready var back_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BackButton

var _action_buttons := {}          # action -> device -> Button
var _listening_action := ""
var _listening_device := ""

func _ready() -> void:
	# Keep working while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_populate_action_list")

	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _populate_action_list() -> void:
	_create_column_header()
	for action in InputSettings.REMAPPABLE_ACTIONS:
		_create_row(action)

func _create_column_header() -> void:
	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var action_label := Label.new()
	action_label.text = "Action"
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(action_label)

	for title in ["Keyboard", "Controller"]:
		var column_label := Label.new()
		column_label.text = title
		column_label.custom_minimum_size = Vector2(180, 0)
		column_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.add_child(column_label)

	action_list.add_child(header)

func _create_row(action: String) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = ACTION_DISPLAY_NAMES.get(action, action)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var keyboard_button := Button.new()
	keyboard_button.custom_minimum_size = Vector2(180, 0)
	keyboard_button.text = _get_keyboard_text(action)
	keyboard_button.tooltip_text = "Change keyboard binding"
	keyboard_button.pressed.connect(_on_remap_button_pressed.bind(action, "keyboard"))
	row.add_child(keyboard_button)

	var controller_button := Button.new()
	controller_button.custom_minimum_size = Vector2(180, 0)
	controller_button.text = _get_controller_text(action)
	controller_button.tooltip_text = "Change controller binding"
	controller_button.pressed.connect(_on_remap_button_pressed.bind(action, "controller"))
	row.add_child(controller_button)

	action_list.add_child(row)
	_action_buttons[action] = {
		"keyboard": keyboard_button,
		"controller": controller_button,
	}

func _get_keyboard_text(action: String) -> String:
	var physical_keycode := InputSettings.get_physical_keycode(action)
	if physical_keycode == KEY_NONE:
		return "—"
	var keycode := DisplayServer.keyboard_get_keycode_from_physical(physical_keycode as Key)
	return OS.get_keycode_string(keycode)

func _get_controller_text(action: String) -> String:
	var controller_event := InputSettings.get_controller_event(action)
	if controller_event == null:
		return "—"
	if controller_event is InputEventJoypadButton:
		return _get_joypad_button_name(controller_event.button_index)
	var direction := "+" if controller_event.axis_value > 0.0 else "-"
	return "Axis %d %s" % [controller_event.axis, direction]

func _get_joypad_button_name(button_index: int) -> String:
	var names := {
		JOY_BUTTON_A: "A",
		JOY_BUTTON_B: "B",
		JOY_BUTTON_X: "X",
		JOY_BUTTON_Y: "Y",
		JOY_BUTTON_BACK: "Back",
		JOY_BUTTON_GUIDE: "Guide",
		JOY_BUTTON_START: "Start",
		JOY_BUTTON_LEFT_STICK: "L3",
		JOY_BUTTON_RIGHT_STICK: "R3",
		JOY_BUTTON_LEFT_SHOULDER: "LB",
		JOY_BUTTON_RIGHT_SHOULDER: "RB",
		JOY_BUTTON_DPAD_UP: "D-pad Up",
		JOY_BUTTON_DPAD_DOWN: "D-pad Down",
		JOY_BUTTON_DPAD_LEFT: "D-pad Left",
		JOY_BUTTON_DPAD_RIGHT: "D-pad Right",
	}
	return names.get(button_index, "Button %d" % button_index)

func _on_remap_button_pressed(action: String, device: String) -> void:
	_cancel_listening()
	_listening_action = action
	_listening_device = device
	_action_buttons[action][device].text = "Press..."

func _cancel_listening() -> void:
	if _listening_action != "":
		_update_action_buttons(_listening_action)
		_listening_action = ""
		_listening_device = ""

func _input(event: InputEvent) -> void:
	if _listening_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_cancel_listening()
		return
	if not _is_valid_binding_event(event):
		return

	get_viewport().set_input_as_handled()

	if _listening_device == "keyboard":
		_assign_keyboard(_listening_action, event.physical_keycode)
	else:
		_assign_controller(_listening_action, event)
	_listening_action = ""
	_listening_device = ""

func _is_valid_binding_event(event: InputEvent) -> bool:
	if _listening_device == "keyboard":
		return event is InputEventKey and event.pressed and not event.echo
	if event is InputEventJoypadButton:
		return event.pressed
	return event is InputEventJoypadMotion and abs(event.axis_value) > 0.5

func _assign_keyboard(action: String, new_keycode: int) -> void:
	var old_keycode := InputSettings.get_physical_keycode(action)

	for other_action in InputSettings.REMAPPABLE_ACTIONS:
		if other_action != action and InputSettings.get_physical_keycode(other_action) == new_keycode:
			InputSettings.set_key(other_action, old_keycode)
			_update_action_buttons(other_action)

	InputSettings.set_key(action, new_keycode)
	_update_action_buttons(action)
	InputSettings.save_bindings()

func _assign_controller(action: String, new_event: InputEvent) -> void:
	InputSettings.set_controller_event(action, new_event)
	_update_action_buttons(action)
	InputSettings.save_bindings()

func _update_action_buttons(action: String) -> void:
	_action_buttons[action]["keyboard"].text = _get_keyboard_text(action)
	_action_buttons[action]["controller"].text = _get_controller_text(action)

func _on_reset_pressed() -> void:
	_cancel_listening()
	InputSettings.reset_to_default()
	for action in _action_buttons:
		_update_action_buttons(action)

func _on_back_pressed() -> void:
	_cancel_listening()
	back_pressed.emit()
