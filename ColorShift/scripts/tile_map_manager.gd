
extends TileMapLayer

## The level is painted once in this layer.
## Tiles tagged GREY (or untagged) are permanent and are drawn with the atlas
## quadrant of the active color. Colored tiles (RED, BLUE..., several tags =
## visible in each of those colors) are moved in _ready to one generated child
## layer per color, which is only visible and solid while its color is active.
## Colored tiles tagged HIDE work the other way round: they are there in every
## color except their own, drawn like the scenery (walls that open with a color).
## tile_wiper_reveal.gdshader recolors and reveals everything as the
## ScreenTransition bar passes; collision switches when the sweep starts.

const COLOR_PROPERTIES: Array[String] = [
	"RED",
	"BLUE",
	"YELLOW",
	"ORANGE",
	"PURPLE",
	"GREEN"
]

# Quadrant of the color atlas for each color (grey is (0, 0)).
# Both atlas families share the same quadrant layout:
#   Tileset - 4 colors / grass1  -> RED, BLUE, YELLOW
#   Tileset-2222 / grass2        -> PURPLE, GREEN, ORANGE
const COLOR_QUADRANTS: Dictionary = {
	"RED": Vector2(1, 0),
	"BLUE": Vector2(0, 1),
	"YELLOW": Vector2(1, 1),
	"PURPLE": Vector2(1, 0),
	"GREEN": Vector2(0, 1),
	"ORANGE": Vector2(1, 1)
}
const COMBO_COLORS: Array[String] = ["ORANGE", "PURPLE", "GREEN"]

const TILE_SHADER := preload("res://shader/transitions/tile_wiper_reveal.gdshader")
# Atlas families: [grey/red/blue/yellow atlas, atlas with the same layout for
# the mixes]. The first one goes to the shader's atlas_size/combo_atlas and the
# second one to atlas_size_alt/combo_atlas_alt.
const ATLAS_FAMILIES: Array = [
	[preload("res://assets/sprites/scenary/Tileset - 4 colors.png"), preload("res://assets/sprites/scenary/Tileset-2222.png")],
	[preload("res://assets/sprites/scenary/grass1.png"), preload("res://assets/sprites/scenary/grass2.png")],
]

var opened_doors: Dictionary = {}

var player: CharacterBody2D

# Layer key of HIDE tiles: "NOT_RED" is there in every color except RED.
const HIDE_PREFIX := "NOT_"

# Layer key -> generated TileMapLayer. The key is a color ("RED") or, for HIDE
# tiles, HIDE_PREFIX + their colors ("NOT_RED", "NOT_RED+BLUE").
var color_layers: Dictionary = {}
# Vector2i -> Array[String] with the layer keys of each colored cell.
var cell_keys: Dictionary = {}

var _sweeping: bool = false
# Sizes of every color atlas in the TileSet (the shader needs them to know
# which textures it is allowed to recolor by quadrant).
var _atlas_sizes: Array[Vector2] = []

# Stores interactive tile properties.
# Format: Vector2i -> Dictionary
var interactive_tiles: Dictionary = {}


func _ready() -> void:
	# Automatically register this layer.
	add_to_group("tile_layers")

	# Find player.
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if player == null:
		push_warning("Player not found in group 'player'")

	# Cache interactive tiles before colored cells leave this layer.
	_refresh_interactive_tiles()
	_collect_atlas_sizes()
	material = _make_material("GREY")
	_split_color_cells()

	# Connect to color manager.
	if not GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.connect(on_change_color)

	ScreenTransition.sweep_started.connect(_on_sweep_started)
	ScreenTransition.sweep_finished.connect(_on_sweep_finished)

	# Apply initial color.
	on_change_color(GameManager.get_color_name())

	# Connect to button signals
	if not GameManager.button_pressed_signal.is_connected(_on_button_pressed):
		GameManager.button_pressed_signal.connect(_on_button_pressed)


# Move every colored cell to the child layer of each of its colors.
func _split_color_cells() -> void:
	for coords in get_used_cells():
		var data := get_cell_tile_data(coords)

		if data == null or data.get_custom_data("GREY"):
			continue

		var colors: Array[String] = []
		for color_name in COLOR_PROPERTIES:
			if data.get_custom_data(color_name):
				colors.append(color_name)

		# Tiles without a color property stay as permanent tiles.
		if colors.is_empty():
			continue

		var keys: Array[String] = colors
		if data.get_custom_data("HIDE"):
			keys = [HIDE_PREFIX + "+".join(PackedStringArray(colors))]

		cell_keys[coords] = keys
		for key in keys:
			_get_color_layer(key).set_cell(
				coords,
				get_cell_source_id(coords),
				get_cell_atlas_coords(coords),
				get_cell_alternative_tile(coords)
			)
		erase_cell(coords)


# Whether the layer with this key is there (visible and solid) in a color.
func _shows_in(key: String, color: String) -> bool:
	if key.begins_with(HIDE_PREFIX):
		return not color in key.trim_prefix(HIDE_PREFIX).split("+")

	return key == color


func _get_color_layer(key: String) -> TileMapLayer:
	if not color_layers.has(key):
		var layer := TileMapLayer.new()
		layer.name = "Color-" + key
		layer.tile_set = tile_set
		# Multi-color tiles are drawn in the color of the layer; HIDE tiles
		# like the scenery (on_change_color sets their color).
		layer.material = _make_material("GREY" if key.begins_with(HIDE_PREFIX) else key)
		# Other systems (player safety, camera, spikes) read every tile layer.
		layer.add_to_group("tile_layers")
		add_child(layer)
		color_layers[key] = layer

	return color_layers[key]


# Runtime size of each atlas family in this TileSet (Vector2.ZERO if unused).
# The shader only recolors textures of these sizes; door, collectables... are
# drawn as they are. With texture padding Godot adds 1 px around every tile.
func _collect_atlas_sizes() -> void:
	_atlas_sizes.clear()
	for family in ATLAS_FAMILIES:
		var size := Vector2.ZERO
		for i in tile_set.get_source_count():
			var source := tile_set.get_source(tile_set.get_source_id(i)) as TileSetAtlasSource
			if source == null or not source.texture in family:
				continue

			size = source.texture.get_size()
			if source.use_texture_padding:
				size = Vector2(source.get_atlas_grid_size() * (source.texture_region_size + Vector2i(2, 2)))
			break
		_atlas_sizes.append(size)


func _make_material(color_name: String) -> ShaderMaterial:
	var tile_material := ShaderMaterial.new()
	tile_material.shader = TILE_SHADER
	tile_material.set_shader_parameter("atlas_size", _atlas_sizes[0])
	tile_material.set_shader_parameter("base_atlas", ATLAS_FAMILIES[0][0])
	tile_material.set_shader_parameter("combo_atlas", ATLAS_FAMILIES[0][1])
	tile_material.set_shader_parameter("atlas_size_alt", _atlas_sizes[1])
	tile_material.set_shader_parameter("base_atlas_alt", ATLAS_FAMILIES[1][0])
	tile_material.set_shader_parameter("combo_atlas_alt", ATLAS_FAMILIES[1][1])
	_set_quadrants(tile_material, color_name, color_name)
	return tile_material


func _set_quadrants(tile_material: ShaderMaterial, old_color: String, new_color: String) -> void:
	tile_material.set_shader_parameter("old_quadrant", COLOR_QUADRANTS.get(old_color, Vector2.ZERO))
	tile_material.set_shader_parameter("new_quadrant", COLOR_QUADRANTS.get(new_color, Vector2.ZERO))
	tile_material.set_shader_parameter("old_combo", old_color in COMBO_COLORS)
	tile_material.set_shader_parameter("new_combo", new_color in COMBO_COLORS)


func _set_visible_sides(layer: TileMapLayer, show_old: bool, show_new: bool) -> void:
	var tile_material := layer.material as ShaderMaterial
	tile_material.set_shader_parameter("show_old", show_old)
	tile_material.set_shader_parameter("show_new", show_new)


# Read all special tiles from the TileSet.
func _refresh_interactive_tiles() -> void:
	interactive_tiles.clear()

	for coords in get_used_cells():
		var data := get_cell_tile_data(coords)

		if data == null:
			continue

		var need_to_hide: bool = data.get_custom_data("HIDE")
		var is_spike: bool = data.get_custom_data("SPIKE")
		var is_key: bool = data.get_custom_data("KEY")
		var is_barrier: bool = data.get_custom_data("BARRIER")
		var is_door: bool = data.get_custom_data("DOOR")
		var barrier_id: Variant = null
		if tile_set.has_custom_data_layer_by_name("BARRIER_ID"):
			barrier_id = data.get_custom_data("BARRIER_ID")

		if need_to_hide or is_spike or is_key or is_barrier or is_door:
			interactive_tiles[coords] = {
				"HIDE": need_to_hide,
				"SPIKE": is_spike,
				"KEY": is_key,
				"BARRIER": is_barrier,
				"DOOR": is_door,
				"BARRIER_ID": barrier_id
			}


# Check for nearby interactive objects.
func _process(_delta: float) -> void:
	if not visible or player == null:
		return

	var player_pos: Vector2 = player.global_position
	var local_pos: Vector2 = to_local(player_pos)
	var center_cell: Vector2i = local_to_map(local_pos)

	var cells_to_check: Array[Vector2i] = [
		center_cell,
		center_cell + Vector2i.UP,
		center_cell + Vector2i.DOWN,
		center_cell + Vector2i.LEFT,
		center_cell + Vector2i.RIGHT
	]

	for cell in cells_to_check:
		var props: Dictionary = get_tile_properties(cell)

		if props.is_empty():
			continue

		if props.get("KEY", false):
			UIManager.show_hint("Press E to pick up the key")
		elif props.get("DOOR", false):
			if opened_doors.has(cell):
				UIManager.show_hint("")
			else:
				UIManager.show_hint("Press E to open the door")
		else:
			UIManager.show_hint("")

		return

	UIManager.show_hint("")


# Only the layers that are there in the active color are solid. Outside a sweep
# they are also the only visible ones; during a sweep the shader decides.
func on_change_color(actual_color: String) -> void:
	for key in color_layers:
		var layer: TileMapLayer = color_layers[key]
		var shown := _shows_in(key, actual_color)
		layer.collision_enabled = shown
		if not _sweeping:
			layer.visible = shown
			if key.begins_with(HIDE_PREFIX):
				_set_quadrants(layer.material as ShaderMaterial, actual_color, actual_color)

	if not _sweeping:
		_set_quadrants(material as ShaderMaterial, actual_color, actual_color)


# In front of the bar everything keeps the old color; behind it, the new one.
func _on_sweep_started(old_color: String, new_color: String) -> void:
	if old_color == new_color:
		return

	_sweeping = true
	_set_quadrants(material as ShaderMaterial, old_color, new_color)
	for key in color_layers:
		var before := _shows_in(key, old_color)
		var after := _shows_in(key, new_color)
		if not before and not after:
			continue

		var layer: TileMapLayer = color_layers[key]
		_set_visible_sides(layer, before, after)
		layer.visible = true
		if key.begins_with(HIDE_PREFIX):
			_set_quadrants(layer.material as ShaderMaterial, old_color, new_color)


func _on_sweep_finished() -> void:
	if not _sweeping:
		return

	_sweeping = false
	for layer in color_layers.values():
		_set_visible_sides(layer, true, true)
	on_change_color(GameManager.get_color_name())


# Disconnect signal when leaving the scene.
func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.disconnect(on_change_color)
	if GameManager.button_pressed_signal.is_connected(_on_button_pressed):
		GameManager.button_pressed_signal.disconnect(_on_button_pressed)
	if ScreenTransition.sweep_started.is_connected(_on_sweep_started):
		ScreenTransition.sweep_started.disconnect(_on_sweep_started)
	if ScreenTransition.sweep_finished.is_connected(_on_sweep_finished):
		ScreenTransition.sweep_finished.disconnect(_on_sweep_finished)


# Return cached properties of a cell, only if the cell is present right now.
func get_tile_properties(coords: Vector2i) -> Dictionary:
	if not interactive_tiles.has(coords):
		return {}
	var color := GameManager.get_color_name()
	if cell_keys.has(coords) and not cell_keys[coords].any(func(key: String) -> bool: return _shows_in(key, color)):
		return {}

	return interactive_tiles[coords]


# Remove a tile permanently.
func remove_tile(coords: Vector2i) -> void:
	interactive_tiles.erase(coords)
	cell_keys.erase(coords)
	erase_cell(coords)
	for layer in color_layers.values():
		layer.erase_cell(coords)


# Receive interaction input.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if event.is_echo():
		return

	if not visible:
		return

	_try_interact_nearest()

	get_viewport().set_input_as_handled()


# Search for the nearest interactive tile.
func _try_interact_nearest() -> void:
	var current_player := get_tree().get_first_node_in_group("player") as CharacterBody2D

	if current_player == null:
		print("ERROR: No player found!")
		return

	var player_pos: Vector2 = current_player.global_position

	for node in get_tree().get_nodes_in_group("tile_layers"):
		var layer := node as TileMapLayer

		if layer == null or not layer.visible:
			continue

		# Generated color layers are managed by their parent layer.
		if not layer.has_method("get_tile_properties"):
			continue

		var local_pos: Vector2 = layer.to_local(player_pos)
		var center_cell: Vector2i = layer.local_to_map(local_pos)

		var cells_to_check: Array[Vector2i] = [
			center_cell,
			center_cell + Vector2i.UP,
			center_cell + Vector2i.DOWN,
			center_cell + Vector2i.LEFT,
			center_cell + Vector2i.RIGHT
		]

		for cell in cells_to_check:
			var props: Dictionary = layer.get_tile_properties(cell)

			if props.is_empty():
				continue

			_handle_interaction(layer, cell, props)
			return


# Remove the connected barrier tiles that share the same ID. Barriers of other
# IDs can touch each other (e.g. three colored doors side by side), so the flood
# fill must not cross into them.
func _remove_connected_barrier(start_cell: Vector2i, barrier_id: Variant) -> void:
	var to_check: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {}
	var connected_cells: Array[Vector2i] = []

	while to_check.size() > 0:
		var current: Vector2i = to_check.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		var props: Dictionary = interactive_tiles.get(current, {})

		if props.get("BARRIER", false) and props.get("BARRIER_ID") == barrier_id:
			connected_cells.append(current)

			for dir in [
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i.LEFT,
				Vector2i.RIGHT
			]:
				var neighbor: Vector2i = current + dir

				if not visited.has(neighbor):
					to_check.append(neighbor)

	for cell in connected_cells:
		remove_tile(cell)


# Handle key, barrier and door interactions.
func _handle_interaction(
	layer: TileMapLayer,
	cell: Vector2i,
	props: Dictionary
) -> void:

	if props.get("KEY", false):
		GameManager.player_has_key = true
		layer.remove_tile(cell)

		MusicAndSounds.play_key_collect()
		UIManager.show_message("You got the key!", 1.6)

		var key := get_tree().get_first_node_in_group("key")
		if key and key.has_method("follow_player"):
			key.follow_player()

	elif props.get("DOOR", false):
		if GameManager.player_has_key:
			opened_doors[cell] = true
			MusicAndSounds.play_door_open()
			UIManager.show_hint("")
			print("DOOR ENTERED!")
			SceneManager.change_scene("level_select")
		else:
			UIManager.show_message("You need a key", 1.4)


func _on_button_pressed(button_id: int) -> void:
	# Loop through all interactive cells registered in this layer
	for cell in interactive_tiles.keys():
		var props: Dictionary = interactive_tiles.get(cell, {})

		# Check if the cell is a barrier
		if props.get("BARRIER", false):
			var barrier_id = props.get("BARRIER_ID")

			# Compare the barrier ID with the pressed button ID
			if barrier_id == button_id:
				_remove_connected_barrier(cell, barrier_id)
				UIManager.show_message("Barrier opened!", 1.8)
				print("Barrier opened with ID: ", button_id)
