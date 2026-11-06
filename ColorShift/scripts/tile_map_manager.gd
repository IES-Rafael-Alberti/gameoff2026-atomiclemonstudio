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
				# Custom data flags from the TileSet
				"GREY": data.get_custom_data("GREY"),
				"RED": data.get_custom_data("RED"),
				"YELLOW": data.get_custom_data("YELLOW"),
				"BLUE": data.get_custom_data("BLUE"),
				# Reveal tiles (platforms and spikes) work the other way
				# around: they only exist while their color is active.
				"REVEAL": data.get_custom_data("REVEAL")
			}

	# Listen for color changes from the GameManager autoload.
	# Connecting from the scene node guarantees we use THIS instance's
	# tiles dictionary (not an empty autoload instance).
	GameManager.color_changed.connect(on_change_color)

	# Apply the current color immediately. Otherwise the level would start
	# with every tile visible until the player changes color for the first time.
	on_change_color(GameManager.get_color_name())

func on_change_color(actual_color: String) -> void:
	for coords in tiles:
		var tile = tiles[coords]
		var belongs_to_color = tile.get(actual_color, false)
		var should_hide := false

		if tile.get("REVEAL", false):
			# Hidden objects (platforms, spikes) appear only with their color.
			should_hide = not belongs_to_color
		elif tile.get("GREY", false):
			# Grey scenery is neutral: it stays visible with every filter.
			should_hide = false
		else:
			# Normal colored blocks disappear when their color is active.
			should_hide = belongs_to_color

		if should_hide:
			# source_id = -1 and atlas = (-1, -1) erases the cell
			set_cell(coords, -1, Vector2i(-1, -1))
		else:
			# Otherwise restore the original tile from the cache
			set_cell(coords, tile["id"], tile["atlas"])

# Removes a tile permanently (a picked-up key, an opened gate...) and forgets
# it, so a later color change cannot bring it back.
func remove_tile(coords: Vector2i) -> void:
	tiles.erase(coords)
	set_cell(coords, -1, Vector2i(-1, -1))

func _exit_tree() -> void:
	# Disconnect when the node leaves the tree (e.g. on scene change)
	# to avoid calling a freed node from the GameManager signal
	if GameManager.color_changed.is_connected(on_change_color):
		GameManager.color_changed.disconnect(on_change_color)
