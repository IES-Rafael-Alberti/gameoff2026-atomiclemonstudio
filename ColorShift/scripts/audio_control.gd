extends HSlider

@export var audio_bus_name: String
var bus_index

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(audio_bus_name)
	
	match audio_bus_name:
		"master": value = GameManager.master_volume
		"music": value = GameManager.music_volume
		"sfx": value = GameManager.sfx_volume

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	match  audio_bus_name:
		"master": GameManager.master_volume = value
		"music": GameManager.music_volume = value
		"sfx": GameManager.sfx_volume = value
