extends TileMapLayer

# Cache of every tile in the layer: coords -> original tile info.
# Needed because set_cell(-1) deletes a tile, so we must remember
# what to restore later.
var tiles: Dictionary = {}

func _ready() -> void:
	# Store the original data of every used cell before anything gets hidden
	for coords in get_used_cells():
		var data = get_cell_tile_data(coords)
		if data:
			tiles[coords] = {
				"id": get_cell_source_id(coords),
				"atlas": get_cell_atlas_coords(coords),
				# Custom data flags from the TileSet: true = hide on that color
				# The grey color for now doesnt need to disapear
				#"GREY": data.get_custom_data("GREY"),
				"RED": data.get_custom_data("RED"),
				"YELLOW": data.get_custom_data("YELLOW"),
				"BLUE": data.get_custom_data("BLUE")
			}
	
	# Listen for color changes from the GameManager autoload.
	# Connecting from the scene node guarantees we use THIS instance's
	# tiles dictionary (not an empty autoload instance).
	GameManager.color_changed.connect(on_change_color)

func on_change_color(actual_color: String) -> void:
	for coords in tiles:
		var tile = tiles[coords]
		
		# If the tile's flag for the current color is true, hide it
		if tile.get(actual_color, false):
			# source_id = -1 and atlas = (-1, -1) erases the cell
			set_cell(coords, -1, Vector2i(-1, -1))
		else:
			# Otherwise restore the original tile from the cache
			set_cell(coords, tile["id"], tile["atlas"])

func _exit_tree() -> void:
	# Disconnect when the node leaves the tree (e.g. on scene change)
	# to avoid calling a freed node from the GameManager signal
	if GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.disconnect(on_change_color)

# Removes a tile permanently (a picked-up key, an opened gate...) and forgets
# it, so a later color change cannot bring it back.
func remove_tile(coords: Vector2i) -> void:
	tiles.erase(coords)
	set_cell(coords, -1, Vector2i(-1, -1))
