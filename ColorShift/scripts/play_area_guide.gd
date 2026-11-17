@tool
extends Node2D

## Draws the area covered by the fixed camera so the level can be designed
## inside a 1024x768 rectangle. It is hidden while playing unless
## show_in_game is enabled.

const VIEWPORT_SIZE := Vector2(1024.0, 768.0)
const TILE_SIZE := 32.0

@export var guide_size: Vector2 = VIEWPORT_SIZE:
	set(value):
		guide_size = value
		queue_redraw()

@export var show_grid: bool = true:
	set(value):
		show_grid = value
		queue_redraw()

@export var show_in_game: bool = false:
	set(value):
		show_in_game = value
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint() and not show_in_game:
		return

	var half := guide_size * 0.5
	var rect := Rect2(-half, guide_size)
	var guide_color := Color(1.0, 0.85, 0.2, 0.95)

	# Playable border.
	draw_rect(rect, guide_color, false, 2.0)

	# Tile grid (32 px cells) to make drawing easier.
	if show_grid:
		var grid_color := Color(1.0, 1.0, 1.0, 0.14)
		var x := -half.x + TILE_SIZE
		while x < half.x:
			draw_line(Vector2(x, -half.y), Vector2(x, half.y), grid_color, 1.0)
			x += TILE_SIZE
		var y := -half.y + TILE_SIZE
		while y < half.y:
			draw_line(Vector2(-half.x, y), Vector2(half.x, y), grid_color, 1.0)
			y += TILE_SIZE

	# Camera origin.
	draw_line(Vector2(-10.0, 0.0), Vector2(10.0, 0.0), guide_color, 1.0)
	draw_line(Vector2(0.0, -10.0), Vector2(0.0, 10.0), guide_color, 1.0)

	var font := ThemeDB.fallback_font
	if font:
		var tiles := Vector2i(
			int(round(guide_size.x / TILE_SIZE)),
			int(round(guide_size.y / TILE_SIZE))
		)
		var label := "%d x %d px  (%d x %d tiles)" % [
			int(guide_size.x), int(guide_size.y), tiles.x, tiles.y
		]
		draw_string(
			font,
			Vector2(-half.x + 8.0, -half.y + 20.0),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			guide_color
		)
