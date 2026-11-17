extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func set_mode(index: int) -> void:
	# index 0: Normal, 1: Protanopia, 2: Deuteranopia, 3: Tritanopia
	var material = color_rect.material as ShaderMaterial
	if material:
		material.set_shader_parameter("mode", index)
		match index:
			0: GameManager.color_blind_mode = "Normal"
			1: GameManager.color_blind_mode = "Protanopia"
			2: GameManager.color_blind_mode = "Deuteranopia"
			3: GameManager.color_blind_mode = "Tritanopia"
