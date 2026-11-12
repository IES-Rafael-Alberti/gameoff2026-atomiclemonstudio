extends Node2D

## Replaces collectable tiles placed in any TileMapLayer with real Area2D
## pickups. This makes them independent from the active color and lets map
## authors place them using the tileset.

const COLLECTABLE_SCENE := preload("res://scenes/collectable_1.tscn")


func _ready() -> void:
	# Wait until every TileMapLayer is ready and has its cells loaded.
	call_deferred("_spawn_collectables")


func _spawn_collectables() -> void:
	var spawned_positions: Dictionary = {}

	for node in get_tree().get_nodes_in_group("tile_layers"):
		var layer := node as TileMapLayer
		if layer == null:
			continue

		for cell in layer.get_used_cells():
			var data := layer.get_cell_tile_data(cell)
			if data == null or not data.get_custom_data("COLLECTABLE"):
				continue

			var world_position := layer.to_global(layer.map_to_local(cell))

			# A tile duplicated in several color layers must create one pickup.
			if spawned_positions.has(world_position):
				_erase_tile(layer, cell)
				continue

			spawned_positions[world_position] = true
			_erase_tile(layer, cell)

			var collectable := COLLECTABLE_SCENE.instantiate()
			collectable.global_position = world_position
			add_child(collectable)


func _erase_tile(layer: TileMapLayer, cell: Vector2i) -> void:
	if layer.has_method("remove_tile"):
		layer.remove_tile(cell)
	else:
		layer.erase_cell(cell)
