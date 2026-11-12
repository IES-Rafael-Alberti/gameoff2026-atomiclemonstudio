extends TileMapLayer

enum LayerType {
	GREY,
	RED,
	BLUE,
	YELLOW
}

@export var layer_type: LayerType
var player: CharacterBody2D

# Dictionary to cache gameplay properties of special cells (spikes, keys, doors, etc.)
# Structure: Vector2i (cell coordinates) -> Dictionary (custom data flags)
var interactive_tiles: Dictionary = {}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("Error: Player not found in the 'player' group")
	
	# Connect to GameManager to handle layer visibility when color changes
	GameManager.color_changed.connect(on_change_color)
	
	# Sync initial visibility state
	if "current_color" in GameManager:
		on_change_color(GameManager.current_color)
	else:
		visible = (layer_type == LayerType.GREY)
		collision_enabled = (layer_type == LayerType.GREY)

	# Scan and cache special gameplay properties from the TileSet
	for coords in get_used_cells():
		var data = get_cell_tile_data(coords)
		if data:
			var need_to_hide = data.get_custom_data("HIDE")
			var is_spike = data.get_custom_data("SPIKE")
			var is_key = data.get_custom_data("KEY")
			var is_barrier = data.get_custom_data("BARRIER")
			var is_door = data.get_custom_data("DOOR")
			
			# Only cache tiles that actually have an interactive gameplay property
			if need_to_hide or is_spike or is_key or is_barrier or is_door:
				interactive_tiles[coords] = {
					"HIDE": need_to_hide,
					"SPIKE": is_spike,
					"KEY": is_key,
					"BARRIER": is_barrier,
					"DOOR": is_door
				}

# Check every frame if the player is next to an interactive object
func _process(_delta: float) -> void:
	# If this layer is not visible/active, do nothing
	if not visible:
		return
		
	if not player:
		return
	
	var player_pos = player.global_position
	var local_pos = to_local(player_pos)
	var center_cell = local_to_map(local_pos)
	
	# Cells to check (player cell and adjacent ones)
	var cells_to_check = [
		center_cell,
		center_cell + Vector2i.UP,
		center_cell + Vector2i.DOWN,
		center_cell + Vector2i.LEFT,
		center_cell + Vector2i.RIGHT
	]
	
	var near_interactive_object = false
	
	for cell in cells_to_check:
		var props = get_tile_properties(cell)
		if not props.is_empty():
			near_interactive_object = true
			
			# Show hint text depending on the object type
			if props.get("KEY", false):
				UIManager.show_hint("Press E to pick up the key")
			elif props.get("BARRIER", false):
				UIManager.show_hint("Press E to open the barrier")
			elif props.get("DOOR", false):
				UIManager.show_hint("Press E to open the door")
			break # Found a nearby object, break inner loop
			
	# If the player moves away from all interactive objects on this layer, clear the hint
	if not near_interactive_object:
		UIManager.show_hint("")

func on_change_color(actual_color: String) -> void:
	# Convert current enum value (e.g., LayerType.RED) to String ("RED")
	var my_color_name: String = LayerType.keys()[layer_type]
	# Show or hide the entire layer based on the selected color
	var is_active: bool = (my_color_name == actual_color)
	visible = is_active	
	collision_enabled = is_active
		
	print("Layer: ", my_color_name, " | Active?: ", is_active, " | Collision enabled: ", collision_enabled)

func _exit_tree() -> void:
	# Disconnect signal upon exiting the scene tree to prevent memory leaks/errors
	if GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.disconnect(on_change_color)


# --- INTERACTION METHODS FOR THE PLAYER ---

# Returns the interactive properties of a specific cell coordinate in this layer
func get_tile_properties(coords: Vector2i) -> Dictionary:
	if interactive_tiles.has(coords):
		return interactive_tiles[coords]
	return {}

# Permanently removes a tile (e.g., a collected key or an opened door)
func remove_tile(coords: Vector2i) -> void:
	interactive_tiles.erase(coords)
	erase_cell(coords)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact_nearest()
		
func _try_interact_nearest() -> void:
	var current_player = get_tree().get_first_node_in_group("player")
	if not current_player:
		return
	
	var player_pos = current_player.global_position
	
	for layer in get_tree().get_nodes_in_group("tile_layers"):
		if not layer.visible:
			continue
			
		var local_pos = layer.to_local(player_pos)
		var center_cell = layer.local_to_map(local_pos)
		
		var cells_to_check = [
			center_cell,
			center_cell + Vector2i.UP,
			center_cell + Vector2i.DOWN,
			center_cell + Vector2i.LEFT,
			center_cell + Vector2i.RIGHT
		]
		
		for cell in cells_to_check:
			var props = layer.get_tile_properties(cell)
			
			if not props.is_empty():
				_handle_interaction(layer, cell, props)
				return


# Recursively removes all connected barrier cells starting from an initial cell
func _remove_connected_barrier(start_cell: Vector2i) -> void:
	var to_check: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {}
	var connected_cells: Array[Vector2i] = []
	
	# Search loop (Flood Fill)
	while to_check.size() > 0:
		var current = to_check.pop_back()
		
		if visited.has(current):
			continue
		visited[current] = true
		
		# Check if this neighboring cell is a barrier
		var props = get_tile_properties(current)
		if props.get("BARRIER", false):
			connected_cells.append(current)
			
			# Add the 4 orthogonal neighbors (up, down, left, right) to the review list
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var neighbor = current + dir
				if not visited.has(neighbor):
					to_check.append(neighbor)
					
	# Once all connected cells are found, remove them all at once
	for cell in connected_cells:
		remove_tile(cell)

func _handle_interaction(layer: TileMapLayer, cell: Vector2i, props: Dictionary) -> void:
	if props.get("KEY", false):
		GameManager.player_has_key = true
		layer.remove_tile(cell)
		UIManager.show_message("You got the key!", 1.6)
		
	elif props.get("BARRIER", false):
		if GameManager.player_has_key:
			layer._remove_connected_barrier(cell)
			UIManager.show_message("Barrier opened!", 1.8)
		else:
			UIManager.show_message("You need a key", 1.4)
			
	elif props.get("DOOR", false):
		if GameManager.player_has_key:
			UIManager.show_message("Tutorial completed successfully!", 4.0)
			SceneManager.change_scene("level_1")
		else:
			UIManager.show_message("You need a key", 1.4)
