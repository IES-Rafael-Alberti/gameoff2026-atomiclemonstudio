extends HSlider

@export var audio_bus_name: String
var bus_index

func _ready() -> void:
	_configure_slider_textures()
	bus_index = AudioServer.get_bus_index(_resolve_bus_name())
	
	match audio_bus_name.to_lower():
		"master": value = GameManager.master_volume
		"music": value = GameManager.music_volume
		"sfx": value = GameManager.sfx_volume

	# Apply the stored volume, even when the slider value does not change.
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _configure_slider_textures() -> void:
	var grabber := load("res://shader/slider_grabber.tres")
	add_theme_icon_override("grabber", grabber)
	add_theme_icon_override("grabber_highlight", grabber)
	add_theme_icon_override("grabber_disabled", grabber)

	var transparent := StyleBoxEmpty.new()
	add_theme_stylebox_override("slider", transparent)
	add_theme_stylebox_override("grabber_area", transparent)
	add_theme_stylebox_override("grabber_area_highlight", transparent)

	var track_texture: TextureRect = get_node_or_null("TrackTexture")
	if track_texture == null:
		track_texture = TextureRect.new()
		track_texture.name = "TrackTexture"
		add_child(track_texture)

	track_texture.texture = _make_atlas("res://assets/ui/IMG_2350.PNG", Rect2(40, 96, 80, 16))
	track_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	track_texture.stretch_mode = TextureRect.STRETCH_SCALE
	track_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track_texture.z_index = -1

	var progress_texture: TextureRect = get_node_or_null("ProgressTexture")
	if progress_texture == null:
		progress_texture = TextureRect.new()
		progress_texture.name = "ProgressTexture"
		add_child(progress_texture)

	progress_texture.texture = _make_atlas("res://assets/ui/IMG_2348.PNG", Rect2(40, 68, 84, 16))
	progress_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	progress_texture.stretch_mode = TextureRect.STRETCH_SCALE
	progress_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_texture.z_index = -1

	if not value_changed.is_connected(_update_bar_textures):
		value_changed.connect(_update_bar_textures)
	if not resized.is_connected(_on_slider_resized):
		resized.connect(_on_slider_resized)

	call_deferred("_update_bar_textures", value)


func _make_atlas(path: String, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path)
	atlas.region = region
	return atlas


func _update_bar_textures(_value: float) -> void:
	var track := get_node_or_null("TrackTexture") as TextureRect
	var progress := get_node_or_null("ProgressTexture") as TextureRect
	if track == null or progress == null:
		return

	var bar_width := maxf(size.x - 9.0, 0.0)
	var bar_height := 16.0
	var bar_y := (size.y - bar_height) * 0.5

	track.position = Vector2(0.0, bar_y)
	track.size = Vector2(bar_width, bar_height)

	var span := maxf(max_value - min_value, 0.001)
	var ratio := clampf((value - min_value) / span, 0.0, 1.0)

	progress.position = Vector2(0.0, bar_y)
	progress.size = Vector2(maxf(bar_width * ratio, 0.0), bar_height)


func _on_slider_resized() -> void:
	_update_bar_textures(value)

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
