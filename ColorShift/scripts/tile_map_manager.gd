
extends TileMapLayer

## The level is painted once in this layer.
## Tiles tagged GREY (or untagged) are permanent. Colored tiles (RED, BLUE...,
## several tags = visible in each of those colors) are moved in _ready to one
## generated child layer per color, which is only visible and solid while its
## color is active. The ScreenTransition sweep reveals them with
## tile_wiper_reveal.gdshader; collision switches when the sweep starts.

const COLOR_PROPERTIES: Array[String] = [
	"RED",
	"BLUE",
	"YELLOW",
	"ORANGE",
	"PURPLE",
	"GREEN"
]

const WIPER_SHADER := preload("res://shader/transitions/tile_wiper_reveal.gdshader")

var opened_doors: Dictionary = {}

var player: CharacterBody2D

# Color name -> generated TileMapLayer holding the cells of that color.
var color_layers: Dictionary = {}
# Vector2i -> Array[String] with the colors of each colored cell.
var cell_colors: Dictionary = {}

var _sweeping: bool = false

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

		cell_colors[coords] = colors
		for color_name in colors:
			_get_color_layer(color_name).set_cell(
				coords,
				get_cell_source_id(coords),
				get_cell_atlas_coords(coords),
				get_cell_alternative_tile(coords)
			)
		erase_cell(coords)


func _get_color_layer(color_name: String) -> TileMapLayer:
	if not color_layers.has(color_name):
		var layer := TileMapLayer.new()
		layer.name = "Color-" + color_name
		layer.tile_set = tile_set
		# Other systems (player safety, camera, spikes) read every tile layer.
		layer.add_to_group("tile_layers")
		add_child(layer)
		color_layers[color_name] = layer

	return color_layers[color_name]


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
		var barrier_id: Variant = data.get_custom_data("BARRIER_ID")

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


# Only the layer of the active color is solid. Outside a sweep it is also the
# only visible one; during a sweep the wiper shader decides what is drawn.
func on_change_color(actual_color: String) -> void:
	for color_name in color_layers:
		var layer: TileMapLayer = color_layers[color_name]
		var is_active: bool = color_name == actual_color
		layer.collision_enabled = is_active
		if not _sweeping:
			layer.visible = is_active


# The old color stays in front of the bar and the new one appears behind it.
func _on_sweep_started(old_color: String, new_color: String) -> void:
	if old_color == new_color:
		return

	_sweeping = true
	for color_name in color_layers:
		if color_name != old_color and color_name != new_color:
			continue

		var wiper := ShaderMaterial.new()
		wiper.shader = WIPER_SHADER
		wiper.set_shader_parameter("keep_before", color_name == old_color)

		var layer: TileMapLayer = color_layers[color_name]
		layer.material = wiper
		layer.visible = true


func _on_sweep_finished() -> void:
	if not _sweeping:
		return

	_sweeping = false
	for layer in color_layers.values():
		layer.material = null
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
	if cell_colors.has(coords) and not GameManager.get_color_name() in cell_colors[coords]:
		return {}

	return interactive_tiles[coords]


# Remove a tile permanently.
func remove_tile(coords: Vector2i) -> void:
	interactive_tiles.erase(coords)
	cell_colors.erase(coords)
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


# Remove all connected barrier tiles, whatever color is active.
func _remove_connected_barrier(start_cell: Vector2i) -> void:
	var to_check: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {}
	var connected_cells: Array[Vector2i] = []

	while to_check.size() > 0:
		var current: Vector2i = to_check.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		var props: Dictionary = interactive_tiles.get(current, {})

		if props.get("BARRIER", false):
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

		UIManager.show_message("You got the key!", 1.6)

		var key := get_tree().get_first_node_in_group("key")
		if key and key.has_method("follow_player"):
			key.follow_player()

	elif props.get("DOOR", false):
		if GameManager.player_has_key:
			opened_doors[cell] = true
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
				_remove_connected_barrier(cell)
				UIManager.show_message("Barrier opened!", 1.8)
				print("Barrier opened with ID: ", button_id)
