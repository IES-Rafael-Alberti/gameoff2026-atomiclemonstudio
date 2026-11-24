extends HSlider

@export var audio_bus_name: String
var bus_index

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(_resolve_bus_name())
	
	match audio_bus_name.to_lower():
		"master": value = GameManager.master_volume
		"music": value = GameManager.music_volume
		"sfx": value = GameManager.sfx_volume

	# Apply the stored volume, even when the slider value does not change.
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	match audio_bus_name.to_lower():
		"master": GameManager.master_volume = value
		"music": GameManager.music_volume = value
		"sfx": GameManager.sfx_volume = value

# The scene exports lowercase names ("master", "music", "sfx"), but the
# audio buses are capitalized ("Master", "Music", "SFX").
func _resolve_bus_name() -> String:
	match audio_bus_name.to_lower():
		"master": return "Master"
		"music": return "Music"
		"sfx": return "SFX"
	return audio_bus_name
