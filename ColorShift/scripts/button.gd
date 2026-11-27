@tool
extends Node2D

## Mismo ID de barrera que usa el tileset para cada color.
const COLOR_TO_ID := {
	"GREY": 0,
	"RED": 1,
	"BLUE": 2,
	"YELLOW": 3,
	"PURPLE": 4,
	"GREEN": 5,
	"ORANGE": 6,
}
const ID_TO_COLOR := {
	0: "GREY",
	1: "RED",
	2: "BLUE",
	3: "YELLOW",
	4: "PURPLE",
	5: "GREEN",
	6: "ORANGE",
}

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

## Color del boton, elegible desde la lista del inspector.
@export_enum("GREY", "RED", "BLUE", "YELLOW", "PURPLE", "GREEN", "ORANGE")
var button_color: String = "GREY":
	set(value):
		if button_color == value:
			return
		button_color = value
		var new_id: int = COLOR_TO_ID.get(value, 0)
		if button_id != new_id:
			button_id = new_id
		notify_property_list_changed()

## ID de la barrera que abre este boton. Se mantiene igualado al color.
@export_range(0, 6, 1) var button_id: int = 0:
	set(value):
		if button_id == value:
			return
		button_id = value
		var new_color: String = ID_TO_COLOR.get(value, "GREY")
		if button_color != new_color:
			button_color = new_color
		notify_property_list_changed()

# BUTTON SETTINGS
@export var cooldown: float = 2.0
@export var visible_in_all_colors: bool = false

# TILE SETTINGS
@export var tile_layer: TileMapLayer
@export var tile_start: Vector2i = Vector2i(-14, -7)
@export var tile_end: Vector2i = Vector2i(13, -7)
@export var tile_respawn_time: float = 3.0

var tiles_hidden: bool = false


func _ready() -> void:
	# Con @tool el script tambien corre en el editor, donde no hay autoloads:
	# alli el boton se queda tal cual para poder editarlo.
	if Engine.is_editor_hint():
		return

	area_2d.monitoring = false

	if not GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.connect(_on_color_changed)
	if not ScreenTransition.sweep_finished.is_connected(_on_sweep_finished):
		ScreenTransition.sweep_finished.connect(_on_sweep_finished)

	_update_skin()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return

	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)
	if ScreenTransition.sweep_finished.is_connected(_on_sweep_finished):
		ScreenTransition.sweep_finished.disconnect(_on_sweep_finished)


func _on_color_changed(_color: String) -> void:
	# During a sweep the tileset reveals the new colour gradually. Switch the
	# button when that reveal is done so both finish changing together.
	if not ScreenTransition.is_busy():
		_update_skin()


func _on_sweep_finished() -> void:
	_update_skin()


func _update_skin() -> void:
	var current_color: String = GameManager.get_color_name()

	# Check if the button should be visible
	if not visible_in_all_colors and current_color != button_color:
		visible = false
		area_2d.monitoring = false
		return

	visible = true
	area_2d.monitoring = true

	# Update button skin according to current color
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

	_update_skin()
	remove_tiles()

	# Button cooldown
	await get_tree().create_timer(cooldown).timeout

	is_pressed = false
	can_press = true
	_update_skin()


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
