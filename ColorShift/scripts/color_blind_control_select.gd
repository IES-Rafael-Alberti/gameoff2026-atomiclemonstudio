extends OptionButton

func _ready() -> void:
	var game_selected = GameManager.color_blind_mode
	
	match game_selected:
		"Normal": selected = 0
		"Protanopia": selected = 1
		"Deuteranopia": selected = 2
		"Tritanopia": selected = 3

func _on_item_selected(index: int) -> void:
	ColorBlindMode.set_mode(index)
