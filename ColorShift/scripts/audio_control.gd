extends HSlider

const MenuStyle := preload("res://scripts/menu_style.gd")
const OUTLINE_WIDTH := 3.0

@export var audio_bus_name: String
var bus_index

func _ready() -> void:
	_add_outline()
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

# Black outline around the track, replaced by the focus ring when selected.
# It is drawn behind the slider, so it never covers the track or the grabber.
func _add_outline() -> void:
	var outline := Control.new()
	outline.show_behind_parent = true
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outline.draw.connect(_draw_outline.bind(outline))
	add_child(outline, false, Node.INTERNAL_MODE_FRONT)
	# The slider redraws when its focus changes: the outline has to follow.
	draw.connect(outline.queue_redraw)

func _draw_outline(outline: Control) -> void:
	var track_height := get_theme_stylebox("slider").get_minimum_size().y
	var track := Rect2(0.0, (size.y - track_height) / 2.0, size.x, track_height)
	if has_focus(true):
		outline.draw_style_box(MenuStyle.get_focus_box(), track)
	else:
		outline.draw_rect(track.grow(OUTLINE_WIDTH), Color.BLACK)

# The scene exports lowercase names ("master", "music", "sfx"), but the
# audio buses are capitalized ("Master", "Music", "SFX").
func _resolve_bus_name() -> String:
	match audio_bus_name.to_lower():
		"master": return "Master"
		"music": return "Music"
		"sfx": return "SFX"
	return audio_bus_name
