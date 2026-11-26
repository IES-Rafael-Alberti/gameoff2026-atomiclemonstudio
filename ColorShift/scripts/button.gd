
extends Node2D

@onready var skins = {
	"GREY": $Grey_skin,
	"RED": $Red_skin,
	"BLUE": $Blue_skin,
	"YELLOW": $Yellow_skin,
	"ORANGE": $Orange_skin,
	"PURPLE": $Purple_skin,
	"GREEN": $Green_skin
}

@onready var area_2d: Area2D = $Area2D

var is_pressed: bool = false
var can_press: bool = true

@export var button_color: String
@export var button_id: int

# BUTTON SETTINGS
@export var cooldown: float = 2.0

# TILE SETTINGS
@export var tile_layer: TileMapLayer
@export var tile_start: Vector2i = Vector2i(-14, -7)
@export var tile_end: Vector2i = Vector2i(13, -7)
@export var tile_respawn_time: float = 3.0

var tiles_hidden: bool = false


func _ready() -> void:
	area_2d.monitoring = false


func _process(delta: float) -> void:
	var current_color = GameManager.get_color_name()

	if current_color != button_color:
		visible = false
		area_2d.monitoring = false
		return

	visible = true
	area_2d.monitoring = true

	for color_name in skins:
		var skin = skins[color_name]
		var is_active = (color_name == current_color)

		skin.visible = is_active

		if is_active:
			if is_pressed:
				skin.play("pressed")
			else:
				skin.play("default")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if not can_press:
		return

	activate_button()


func activate_button() -> void:
	can_press = false
	is_pressed = true

	GameManager.button_pressed(button_id)

	remove_tiles()

	# Button cooldown
	await get_tree().create_timer(cooldown).timeout

	is_pressed = false
	can_press = true


func remove_tiles() -> void:
	if tile_layer == null:
		return

	if tiles_hidden:
		return

	tiles_hidden = true

	# Store the original tile information
	var saved_tiles: Array = []

	var min_x = mini(tile_start.x, tile_end.x)
	var max_x = maxi(tile_start.x, tile_end.x)

	var min_y = mini(tile_start.y, tile_end.y)
	var max_y = maxi(tile_start.y, tile_end.y)

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var cell = Vector2i(x, y)

			var source_id = tile_layer.get_cell_source_id(cell)

			if source_id == -1:
				continue

			var atlas_coords = tile_layer.get_cell_atlas_coords(cell)
			var alternative_tile = tile_layer.get_cell_alternative_tile(cell)

			saved_tiles.append({
				"position": cell,
				"source_id": source_id,
				"atlas_coords": atlas_coords,
				"alternative_tile": alternative_tile
			})

			tile_layer.erase_cell(cell)

	# Wait before restoring tiles
	await get_tree().create_timer(tile_respawn_time).timeout

	# Restore original tiles
	for tile in saved_tiles:
		tile_layer.set_cell(
			tile["position"],
			tile["source_id"],
			tile["atlas_coords"],
			tile["alternative_tile"]
		)

	tiles_hidden = false
