extends TileMapLayer
	
@export var tiles: Dictionary = {}

func _ready() -> void:
	print("tiles al empezar: ", tiles.size())
		
	for coords in get_used_cells():
		var data = get_cell_tile_data(coords)
		if data:
			# Guardamos directamente en la variable 'tiles' del script
			tiles[coords] = {
				"id": get_cell_source_id(coords),
				"atlas": get_cell_atlas_coords(coords),
				"GREY": data.get_custom_data("GREY"),
				"RED": data.get_custom_data("RED"),
				"YELLOW": data.get_custom_data("YELLOW"),
				"BLUE": data.get_custom_data("BLUE")
			}
	print("tiles al terminar: ", tiles.size())
	
func on_change_color(actual_color: String):
	print("tiles al seguir la funcion: ", tiles.size())
	
	for coords in tiles:
		var tile = tiles[coords]
		var debe_ocultarse = tile.get(actual_color, false)
		print(tile)
		print(debe_ocultarse)
		
		if debe_ocultarse:
			# Borramos la celda usando source_id = -1 y atlas Vector2i(-1, -1)
			set_cell(coords, -1, Vector2i(-1, -1))
			print("Tile ocultado en: ", coords)
		else:
			# Restauramos el tile original con su ID y coordenadas de atlas
			set_cell(coords, tile["id"], tile["atlas"])
