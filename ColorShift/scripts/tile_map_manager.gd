extends TileMapLayer

enum LayerType {
	GREY,
	RED,
	BLUE,
	YELLOW
}

@export var layer_type: LayerType
@export var player: CharacterBody2D
var has_key: bool = false

# Dictionary to cache gameplay properties of special cells (spikes, keys, doors, etc.)
# Structure: Vector2i (cell coordinates) -> Dictionary (custom data flags)
var interactive_tiles: Dictionary = {}

func _ready() -> void:
	# Find the player if it was not assigned in the inspector.
	if not player:
		var level := get_parent()
		if level:
			player = level.get_node_or_null("Player") as CharacterBody2D

	# Connect to GameManager to handle layer visibility when color changes
	GameManager.color_changed.connect(on_change_color)

	# Sync the initial visibility and collision state with the active color.
	on_change_color(GameManager.get_color_name())

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

func on_change_color(actual_color: String) -> void:
	# Convert current enum value (e.g., LayerType.RED) to String ("RED").
	var my_color_name: String = LayerType.keys()[layer_type]
	# Each layer only exists while its color is active.
	visible = (my_color_name == actual_color)
	collision_enabled = visible

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
	# Si la variable player está vacía, intentamos encontrarla automáticamente
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			print("¡Error: No se encuentra al jugador en la escena!")
			return # Salimos para que no crashee

	var player_pos = player.global_position
	
	# El resto de tu código de búsqueda...
	for layer in get_tree().get_nodes_in_group("tile_layers"):
		if not layer.visible:
			continue
			
		var local_pos = layer.to_local(player_pos)
		var cell = layer.local_to_map(local_pos)
		var props = layer.get_tile_properties(cell)
		
		if not props.is_empty():
			_handle_interaction(layer, cell, props)
			break
		
func _handle_interaction(layer: TileMapLayer, cell: Vector2i, props: Dictionary) -> void:
	if props.get("KEY", false):
		has_key = true
		layer.remove_tile(cell)
		UIManager.show_message("¡Has cogido la llave!", 1.6)
		# Spawn follower logic can be triggered here or on the player directly
		
	elif props.get("BARRIER", false):
		if has_key:
			layer.remove_tile(cell)
			UIManager.show_message("¡Barrera abierta!", 1.8)
		else:
			UIManager.show_message("Necesitas la llave", 1.4)
			
	elif props.get("DOOR", false):
		if has_key:
			UIManager.show_message("¡Has superado el tutorial con éxito!", 4.0)
			SceneManager.change_scene("level_1")
		else:
			UIManager.show_message("Necesitas la llave", 1.4)
