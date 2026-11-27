extends Node

var message_label: Label
var hint_label: Label
var tutorial_label: Label
var message_tween: Tween

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100 # Ensures UI renders on top of everything
	add_child(canvas)

	# Levels are shown in 16:9 with side bars: keep the HUD inside the
	# centred 1024x768 game (in 4:3 it is the whole screen).
	var game_area := Control.new()
	game_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_area.set_anchors_preset(Control.PRESET_CENTER)
	game_area.offset_left = -512.0
	game_area.offset_top = -384.0
	game_area.offset_right = 512.0
	game_area.offset_bottom = 384.0
	canvas.add_child(game_area)

	var carrot_counter := preload("res://scenes/carrot_counter.tscn").instantiate()
	game_area.add_child(carrot_counter)

	# 1. Center message label (for notifications like "Got a key!")
	message_label = Label.new()
	message_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 40)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	message_label.add_theme_constant_override("outline_size", 10)
	message_label.modulate.a = 0.0
	game_area.add_child(message_label)

	# 2. Bottom hint label (for prompts like "Press E to open door")
	hint_label = _make_label(VERTICAL_ALIGNMENT_BOTTOM)
	hint_label.offset_bottom = -56.0
	game_area.add_child(hint_label)

	# 3. Top tutorial label (for how-to-play tips in the first level)
	tutorial_label = _make_label(VERTICAL_ALIGNMENT_TOP)
	tutorial_label.offset_top = 72.0
	game_area.add_child(tutorial_label)

func _make_label(vertical_alignment: VerticalAlignment) -> Label:
	var label := Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = vertical_alignment
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 7)
	label.modulate.a = 0.0
	return label

# Public method to show pop-up messages with a fade-out effect
func show_message(text: String, duration: float = 1.5) -> void:
	if not message_label:
		return
		
	message_label.text = text
	message_label.modulate.a = 1.0

	if message_tween and message_tween.is_valid():
		message_tween.kill()

	message_tween = create_tween()
	message_tween.tween_interval(duration)
	message_tween.tween_property(message_label, "modulate:a", 0.0, 0.45)

# Public method to update the contextual hint at the bottom of the screen
func show_hint(text: String) -> void:
	if not hint_label:
		return
		
	hint_label.text = text
	hint_label.modulate.a = 1.0 if text != "" else 0.0

# Public method to show a how-to-play tip at the top of the screen ("" hides it)
func show_tutorial(text: String) -> void:
	if not tutorial_label:
		return

	tutorial_label.text = text
	tutorial_label.modulate.a = 1.0 if text != "" else 0.0
