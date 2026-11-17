
extends TileMapLayer

const COLOR_PROPERTIES: Array[String] = [
	"GREY",
	"RED",
	"BLUE",
	"YELLOW",
	"ORANGE",
	"PURPLE",
	"GREEN"
]

var opened_doors: Dictionary = {}

# Stores the original cell data so cells can be hidden and restored.
var cell_data: Dictionary = {}
var cell_colors: Dictionary = {}
var visible_cells: Dictionary = {}

var player: CharacterBody2D

# Stores interactive tile properties.
# Format: Vector2i -> Dictionary
var interactive_tiles: Dictionary = {}


func _ready() -> void:
	# Automatically register this layer.
	add_to_group("tile_layers")

	# Find player.
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	print("\n===== TILEMAP INITIALIZATION =====")
	print("Layer: ", name)
	print("Registered in tile_layers: ", is_in_group("tile_layers"))
	print("Player found: ", player != null)
	print("Used cells: ", get_used_cells().size())

	if player == null:
		push_warning("Player not found in group 'player'")

	# Cache interactive tiles.
	_cache_cells()
	_refresh_interactive_tiles()

	# Connect to color manager.
	if not GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.connect(on_change_color)

	# Apply initial color.
	on_change_color(GameManager.get_color_name())

	# Connect to button signals
	if not GameManager.button_pressed_signal.is_connected(_on_button_pressed):
		GameManager.button_pressed_signal.connect(_on_button_pressed)


func _cache_cells() -> void:
	cell_data.clear()
	cell_colors.clear()

	for coords in get_used_cells():
		var data := get_cell_tile_data(coords)

		if data == null:
			continue

		cell_data[coords] = {
			"source_id": get_cell_source_id(coords),
			"atlas_coords": get_cell_atlas_coords(coords),
			"alternative_tile": get_cell_alternative_tile(coords)
		}
		cell_colors[coords] = _get_cell_color(data)


func _get_cell_color(data: TileData) -> Array[String]:
	var colors: Array[String] = []

	for color_name in COLOR_PROPERTIES:
		if bool(data.get_custom_data(color_name)):
			colors.append(color_name)

	# Tiles without a color property remain part of the permanent grey layer.
	if colors.is_empty():
		colors.append("GREY")

	return colors


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


# Show grey cells and cells matching the selected color.
func on_change_color(actual_color: String) -> void:
	visible = true
	collision_enabled = true

	var selected_color := actual_color.to_upper()
	for coords in cell_data:
		var colors: Array[String] = cell_colors.get(coords, ["GREY"])
		var should_be_visible: bool = "GREY" in colors or selected_color in colors

		if should_be_visible:
			_restore_cell(coords)
			visible_cells[coords] = true
		else:
			erase_cell(coords)
			visible_cells.erase(coords)


func _restore_cell(coords: Vector2i) -> void:
	if not cell_data.has(coords) or get_cell_source_id(coords) != -1:
		return

	var data: Dictionary = cell_data[coords]
	set_cell(
		coords,
		data["source_id"],
		data["atlas_coords"],
		data["alternative_tile"]
	)


# Disconnect signal when leaving the scene.
func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.disconnect(on_change_color)


# Return cached properties of a cell.
func get_tile_properties(coords: Vector2i) -> Dictionary:
	if visible_cells.has(coords) and interactive_tiles.has(coords):
		return interactive_tiles[coords]

	return {}


# Remove a tile permanently.
func remove_tile(coords: Vector2i) -> void:
	interactive_tiles.erase(coords)
	cell_data.erase(coords)
	cell_colors.erase(coords)
	visible_cells.erase(coords)
	erase_cell(coords)


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

		if not layer.has_method("get_tile_properties"):
			print("Layer missing interaction script: ", layer.name)
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


# Remove all connected barrier tiles.
func _remove_connected_barrier(start_cell: Vector2i) -> void:
	var to_check: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {}
	var connected_cells: Array[Vector2i] = []

	while to_check.size() > 0:
		var current: Vector2i = to_check.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		var props: Dictionary = get_tile_properties(current)

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
		var props: Dictionary = get_tile_properties(cell)
		
		# Check if the cell is a barrier
		if props.get("BARRIER", false):
			var barrier_id = props.get("BARRIER_ID")
			
			# Compare the barrier ID with the pressed button ID
			if barrier_id == button_id:
				_remove_connected_barrier(cell)
				UIManager.show_message("Barrier opened!", 1.8)
				print("Barrier opened with ID: ", button_id)
