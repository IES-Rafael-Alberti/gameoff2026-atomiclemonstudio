extends Node

const SAVE_PATH := "user://input_settings.cfg"

# Remappable actions (they must exist in the Input Map)
const REMAPPABLE_ACTIONS: Array[String] = [
	"move_left", "move_right", "move_down", "jump",
	"shift", "shift_2", "interact", "pause", "teleport_checkpoint",
]

func _ready() -> void:
	load_bindings()

func get_physical_keycode(action: String) -> int:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
	return KEY_NONE

# Left/right side of the key (both shifts share the same keycode).
func get_key_location(action: String) -> int:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.location
	return KEY_LOCATION_UNSPECIFIED

func set_key(action: String, physical_keycode: int, location: int = KEY_LOCATION_UNSPECIFIED) -> void:
	var non_keyboard_events: Array[InputEvent] = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventKey:
			non_keyboard_events.append(event)

	InputMap.action_erase_events(action)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = physical_keycode as Key
	key_event.location = location as KeyLocation
	InputMap.action_add_event(action, key_event)
	for event in non_keyboard_events:
		InputMap.action_add_event(action, event)

func get_controller_event(action: String) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return event
	return null

func set_controller_event(action: String, controller_event: InputEvent) -> void:
	controller_event.device = -1
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
		config.set_value("key_locations", action, get_key_location(action))
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
			# -1: file saved before key sides existed, only the keycode matters.
			var saved_location: int = config.get_value("key_locations", action, -1)
			var is_default := _project_keys(action).any(func(key: Vector2i) -> bool:
				return key.x == saved_keycode and (saved_location == -1 or key.y == saved_location))
			if not is_default:
				set_key(action, saved_keycode, maxi(saved_location, KEY_LOCATION_UNSPECIFIED))
		if config.has_section_key("controllers", action):
			var saved_controller = config.get_value("controllers", action)
			if saved_controller is Dictionary:
				var controller_event := _deserialize_controller_event(saved_controller)
				if controller_event != null:
					set_controller_event(action, controller_event)

# Default keys of the action as (physical_keycode, location).
func _project_keys(action: String) -> Array[Vector2i]:
	var keys: Array[Vector2i] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keys.append(Vector2i(event.physical_keycode, event.location))
	return keys

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
