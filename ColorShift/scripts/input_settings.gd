extends Node

const SAVE_PATH := "user://input_settings.cfg"

# Remappable actions (they must exist in the Input Map)
const REMAPPABLE_ACTIONS: Array[String] = [
	"move_left", "move_right", "move_down", "jump",
	"shift", "interact", "pause", "teleport_checkpoint",
]

func _ready() -> void:
	load_bindings()

func get_physical_keycode(action: String) -> int:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
	return KEY_NONE

func set_key(action: String, physical_keycode: int) -> void:
	var non_keyboard_events: Array[InputEvent] = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventKey:
			non_keyboard_events.append(event)

	InputMap.action_erase_events(action)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = physical_keycode as Key
	InputMap.action_add_event(action, key_event)
	for event in non_keyboard_events:
		InputMap.action_add_event(action, event)

func get_controller_event(action: String) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return event
	return null

func set_controller_event(action: String, controller_event: InputEvent) -> void:
	var keyboard_events: Array[InputEvent] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keyboard_events.append(event)

	InputMap.action_erase_events(action)
	for event in keyboard_events:
		InputMap.action_add_event(action, event)
	if controller_event is InputEventJoypadButton:
		controller_event.pressed = false
	InputMap.action_add_event(action, controller_event)

func save_bindings() -> void:
	var config := ConfigFile.new()
	for action in REMAPPABLE_ACTIONS:
		config.set_value("keys", action, get_physical_keycode(action))
		var controller_event := get_controller_event(action)
		if controller_event is InputEventJoypadButton:
			config.set_value("controllers", action, {
				"type": "button",
				"button_index": controller_event.button_index,
				"device": controller_event.device,
			})
		elif controller_event is InputEventJoypadMotion:
			config.set_value("controllers", action, {
				"type": "motion",
				"axis": controller_event.axis,
				"axis_value": controller_event.axis_value,
				"device": controller_event.device,
			})
	config.save(SAVE_PATH)

func load_bindings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return  # First run: keep the project's default bindings
	for action in REMAPPABLE_ACTIONS:
		if config.has_section_key("keys", action):
			var saved_keycode: int = config.get_value("keys", action)
			if not _project_keycodes(action).has(saved_keycode):
				set_key(action, saved_keycode)
		if config.has_section_key("controllers", action):
			var saved_controller = config.get_value("controllers", action)
			if saved_controller is Dictionary:
				var controller_event := _deserialize_controller_event(saved_controller)
				if controller_event != null:
					set_controller_event(action, controller_event)

func _project_keycodes(action: String) -> Array[int]:
	var keycodes: Array[int] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keycodes.append(event.physical_keycode)
	return keycodes

func _deserialize_controller_event(data: Dictionary) -> InputEvent:
	var event: InputEvent
	if data.get("type") == "button":
		var button_event := InputEventJoypadButton.new()
		button_event.button_index = data.get("button_index", 0)
		event = button_event
	elif data.get("type") == "motion":
		var motion_event := InputEventJoypadMotion.new()
		motion_event.axis = data.get("axis", 0)
		motion_event.axis_value = data.get("axis_value", 1.0)
		event = motion_event
	else:
		return null
	event.device = data.get("device", -1)
	return event

func reset_to_default() -> void:
	InputMap.load_from_project_settings()
	save_bindings()
