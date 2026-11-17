extends Node

## Keeps the player out of solid tiles that appear on top of it after a color
## change and restarts the level if the player ever leaves the fixed view.
##
## A block only pushes the player when it covers the center of the player's
## body. Standing on a floor, a wall or a platform never counts as being
## inside one. The destination is the nearest position where the whole body
## fits without overlapping a solid block.

const BODY_INSET := 1.5
const SEARCH_STEP_FINE := 2.0
const SEARCH_RADIUS_FINE := 96.0
const SEARCH_STEP_MEDIUM := 8.0
const SEARCH_RADIUS_MEDIUM := 384.0
const SEARCH_STEP_COARSE := 16.0
const SEARCH_RADIUS_COARSE := 1280.0

@export var resolve_on_color_change: bool = true
@export var restart_when_outside: bool = true
@export var outside_margin: float = 8.0

var _player: CharacterBody2D
var _hitbox: CollisionShape2D
var _state_machine: StateMachine

var _body_offset := Vector2.ZERO
var _body_size := Vector2(20.0, 47.0)
var _body_center_offset := Vector2.ZERO

# World-space collision polygons of the visible/solid layers. They are cached
# per layer and cell so both detection and the free-space search stay cheap.
var _solid_polygons: Array[PackedVector2Array] = []
var _polygons_by_layer: Dictionary = {}
var _cache_dirty := true

var _fine_offsets: Array[Vector2] = []
var _medium_offsets: Array[Vector2] = []
var _coarse_offsets: Array[Vector2] = []


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	if _player == null:
		push_error("PlayerSafety must be a child of a CharacterBody2D.")
		return

	_hitbox = _player.get_node_or_null("PlayerHitbox") as CollisionShape2D
	_state_machine = _player.get_node_or_null("StateMachine") as StateMachine
	_build_body_metrics()

	# The tile layers are later siblings than the player, so they connect to
	# the signal after this node. Deferring the reaction guarantees that their
	# visibility/collision state is already updated when we inspect it.
	GameManager.color_changed.connect(_on_color_changed, CONNECT_DEFERRED)


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)


func _physics_process(_delta: float) -> void:
	if _player == null or _is_dead():
		return

	if not restart_when_outside:
		return

	var play_rect := _get_play_rect()
	if not play_rect.grow(outside_margin).has_point(_player.global_position):
		_restart_level()


func _build_body_metrics() -> void:
	var local_rect := Rect2(-_body_size * 0.5, _body_size)
	if _hitbox != null and _hitbox.shape is RectangleShape2D:
		local_rect = (_hitbox.shape as RectangleShape2D).get_rect()

	_body_size = local_rect.size
	_body_offset = local_rect.position
	_body_center_offset = local_rect.position + local_rect.size * 0.5

	if _hitbox != null:
		_body_offset += _hitbox.position
		_body_center_offset += _hitbox.position


func _on_color_changed(_color_name: String) -> void:
	if not resolve_on_color_change or _is_dead():
		return

	resolve_overlap()


## Returns true when a solid block occupies the exact space of the player's
## body center. One-way platforms are ignored, so resting on them is safe.
func _is_body_center_inside_solid() -> bool:
	_ensure_polygon_cache()
	var center := _player.global_position + _body_center_offset

	for polygon in _solid_polygons:
		if Geometry2D.is_point_in_polygon(center, polygon):
			return true

	return false


## Moves the player to the nearest free position if a block appeared on top of
## it. Restarts the level when there is no free space at all.
func resolve_overlap() -> void:
	if _player == null or _hitbox == null:
		return

	# The active layer changed, so the cached collision geometry is stale.
	_cache_dirty = true
	_ensure_polygon_cache()

	if not _is_body_center_inside_solid():
		return

	var origin := _player.global_position
	var play_rect := _get_play_rect()
	var target = _find_nearest_free(origin, play_rect)

	if target == null:
		_restart_level()
		return

	_player.global_position = target
	_player.velocity = Vector2.ZERO


func _find_nearest_free(origin: Vector2, play_rect: Rect2):
	# Each phase is only built when the previous one found no free spot, so
	# the normal case (a block right next to the player) stays cheap.
	if _fine_offsets.is_empty():
		_fine_offsets = _make_search_offsets(SEARCH_STEP_FINE, SEARCH_RADIUS_FINE)
	var result = _search_offsets(_fine_offsets, origin, play_rect)
	if result != null:
		return result

	if _medium_offsets.is_empty():
		_medium_offsets = _make_search_offsets(SEARCH_STEP_MEDIUM, SEARCH_RADIUS_MEDIUM)
	result = _search_offsets(_medium_offsets, origin, play_rect)
	if result != null:
		return result

	if _coarse_offsets.is_empty():
		_coarse_offsets = _make_search_offsets(SEARCH_STEP_COARSE, SEARCH_RADIUS_COARSE)
	return _search_offsets(_coarse_offsets, origin, play_rect)


func _search_offsets(offsets: Array[Vector2], origin: Vector2, play_rect: Rect2):
	for offset in offsets:
		var candidate: Vector2 = origin + offset
		if not play_rect.encloses(_body_rect(candidate)):
			continue
		if _is_position_free(candidate):
			return candidate

	return null


## Checks the full body (slightly shrunk so resting against a surface is not
## considered an overlap) against every solid polygon of the active layers.
func _is_position_free(world_position: Vector2) -> bool:
	_ensure_polygon_cache()

	var body := _body_rect(world_position)
	var probe := Rect2(
		body.position + Vector2(BODY_INSET, BODY_INSET),
		body.size - Vector2(BODY_INSET * 2.0, BODY_INSET * 2.0)
	)

	for layer in _polygons_by_layer:
		var polygons_by_cell: Dictionary = _polygons_by_layer[layer]
		var cells := _cells_for_rect(layer, probe)
		for x in range(cells.position.x, cells.end.x):
			for y in range(cells.position.y, cells.end.y):
				var cell := Vector2i(x, y)
				if not polygons_by_cell.has(cell):
					continue
				for polygon in polygons_by_cell[cell]:
					if _rect_intersects_polygon(probe, polygon):
						return false

	return true


func _ensure_polygon_cache() -> void:
	if not _cache_dirty:
		return

	_cache_dirty = false
	_solid_polygons.clear()
	_polygons_by_layer.clear()

	for node in get_tree().get_nodes_in_group("tile_layers"):
		var layer := node as TileMapLayer
		if layer == null or not layer.visible or not layer.collision_enabled:
			continue
		if layer.tile_set == null:
			continue

		var polygons_by_cell: Dictionary = {}
		var physics_layers := layer.tile_set.get_physics_layers_count()

		for cell in layer.get_used_cells():
			var data := layer.get_cell_tile_data(cell)
			if data == null:
				continue

			var cell_polygons: Array[PackedVector2Array] = []
			for physics_layer in range(physics_layers):
				for polygon_index in range(data.get_collision_polygons_count(physics_layer)):
					if data.is_collision_polygon_one_way(physics_layer, polygon_index):
						continue

					var points := data.get_collision_polygon_points(physics_layer, polygon_index)
					if points.size() < 3:
						continue

					var world_polygon := PackedVector2Array()
					for point in points:
						world_polygon.append(layer.to_global(layer.map_to_local(cell) + point))

					cell_polygons.append(world_polygon)
					_solid_polygons.append(world_polygon)

			if not cell_polygons.is_empty():
				polygons_by_cell[cell] = cell_polygons

		if not polygons_by_cell.is_empty():
			_polygons_by_layer[layer] = polygons_by_cell


func _cells_for_rect(layer: TileMapLayer, rect: Rect2) -> Rect2i:
	var corners := [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y)
	]

	var min_cell := Vector2i.ZERO
	var max_cell := Vector2i.ZERO
	var first := true

	for corner in corners:
		var cell := layer.local_to_map(layer.to_local(corner))
		if first:
			min_cell = cell
			max_cell = cell
			first = false
		else:
			min_cell.x = mini(min_cell.x, cell.x)
			min_cell.y = mini(min_cell.y, cell.y)
			max_cell.x = maxi(max_cell.x, cell.x)
			max_cell.y = maxi(max_cell.y, cell.y)

	# A margin of one cell covers polygons that overflow their own cell.
	min_cell -= Vector2i.ONE
	max_cell += Vector2i.ONE

	return Rect2i(min_cell, max_cell - min_cell + Vector2i.ONE)


func _rect_intersects_polygon(rect: Rect2, polygon: PackedVector2Array) -> bool:
	var bounds := Rect2(polygon[0], Vector2.ZERO)
	for point in polygon:
		bounds = bounds.expand(point)

	if not bounds.intersects(rect):
		return false

	for point in polygon:
		if rect.has_point(point):
			return true

	var corners := [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y)
	]

	for corner in corners:
		if Geometry2D.is_point_in_polygon(corner, polygon):
			return true

	for i in range(4):
		var from_a: Vector2 = corners[i]
		var to_a: Vector2 = corners[(i + 1) % 4]
		for j in range(polygon.size()):
			var from_b: Vector2 = polygon[j]
			var to_b: Vector2 = polygon[(j + 1) % polygon.size()]
			if Geometry2D.segment_intersects_segment(from_a, to_a, from_b, to_b) != null:
				return true

	return false


## Builds a list of offsets sorted from shortest to longest. Ties prefer the
## most horizontal movement, so lateral pushes win over vertical ones.
func _make_search_offsets(step: float, radius: float) -> Array[Vector2]:
	var max_ring := int(ceil(radius / step))
	var radius_squared := radius * radius
	var offsets: Array[Vector2] = []

	for x in range(-max_ring, max_ring + 1):
		for y in range(-max_ring, max_ring + 1):
			if x == 0 and y == 0:
				continue
			var offset := Vector2(x, y) * step
			if offset.length_squared() > radius_squared:
				continue
			offsets.append(offset)

	offsets.sort_custom(_offset_is_closer)
	return offsets


func _offset_is_closer(a: Vector2, b: Vector2) -> bool:
	var distance_a := a.length_squared()
	var distance_b := b.length_squared()
	if not is_equal_approx(distance_a, distance_b):
		return distance_a < distance_b

	var vertical_a := absf(a.y)
	var vertical_b := absf(b.y)
	if not is_equal_approx(vertical_a, vertical_b):
		return vertical_a < vertical_b

	return absf(a.x) < absf(b.x)


func _body_rect(world_position: Vector2) -> Rect2:
	return Rect2(world_position + _body_offset, _body_size)


func _get_play_rect() -> Rect2:
	var viewport := get_viewport()
	var size := viewport.get_visible_rect().size
	var camera := viewport.get_camera_2d()
	if camera != null:
		size /= camera.zoom
		var center := camera.get_screen_center_position()
		return Rect2(center - size * 0.5, size)

	# The fixed camera is always at the world origin.
	return Rect2(-size * 0.5, size)


func _is_dead() -> bool:
	if _state_machine == null or _state_machine.current_state == null:
		return false
	return _state_machine.current_state.name.to_lower() == "deathstate"


func _restart_level() -> void:
	if _is_dead():
		return

	if _state_machine != null:
		_state_machine.change_state("deathstate")
	else:
		SceneManager.reload_scene()
