extends Node

class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}
var drop_through_timer := 0.0
var drop_through_collision_mask := 1

# Velocidad de la plataforma mientras estamos en suelo. Se congela al saltar
# para que el jugador conserve esa inercia durante todo el vuelo.
var inherited_velocity := Vector2.ZERO
var previous_state_name := ""

func _ready() -> void:
	#Registers child states based on the child nodes
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self

	#Start with initial state
	if initial_state:
		change_state(initial_state.name.to_lower())
		
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	var character = get_parent() as CharacterBody2D
	# is_on_floor() todavia refleja el frame anterior, asi que aqui la velocidad
	# de la plataforma sigue siendo valida. En el aire no se actualiza: es la
	# inercia que el jugador conserva hasta aterrizar.
	if character != null and character.is_on_floor():
		inherited_velocity = character.get_platform_velocity()

	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0 and character != null:
			character.collision_mask = drop_through_collision_mask

	if current_state:
		current_state.physics_update(delta)
		_check_spike_collisions()
		_check_drop_through()

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _check_spike_collisions() -> void:
	if current_state and current_state.name.to_lower() == "deathstate":
		return

	var character = get_parent() as CharacterBody2D
	if character == null:
		return

	# Spikes are solid tiles, so a touching spike shows up as a slide
	# collision. Check the tile under the contact point for the SPIKE flag.
	for i in range(character.get_slide_collision_count()):
		var collision := character.get_slide_collision(i)
		if _is_spike_at(collision.get_position()):
			change_state("deathstate")
			return

func _is_spike_at(world_position: Vector2) -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false

	for node in scene.find_children("*", "TileMapLayer", true, false):
		var layer := node as TileMapLayer
		if layer == null:
			continue

		# If the layer is hidden or disabled, ignore its spikes completely
		if not layer.visible or not layer.enabled:
			continue

		var cell := layer.local_to_map(layer.to_local(world_position))
		var data := layer.get_cell_tile_data(cell)
		if data and data.get_custom_data("SPIKE"):
			return true

	return false

func _check_drop_through() -> void:
	if current_state and current_state.name.to_lower() == "deathstate":
		return

	var character = get_parent() as CharacterBody2D
	if character == null:
		return

	# Only while standing still on the ground and pressing Down.
	if not Input.is_action_just_pressed("move_down"):
		return
	if not character.is_on_floor():
		return
	if not _is_on_one_way_platform(character):
		return

	drop_through_collision_mask = character.collision_mask
	character.collision_mask = 0
	character.velocity.y = 180.0
	drop_through_timer = 0.18

func _is_on_one_way_platform(character: CharacterBody2D) -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false

	var bottom := _get_character_bottom()
	var feet := character.global_position + Vector2(0.0, bottom + 2.0)

	for node in scene.find_children("*", "TileMapLayer", true, false):
		var layer := node as TileMapLayer
		if layer == null or layer.tile_set == null:
			continue

		var cell := layer.local_to_map(layer.to_local(feet))
		var data := layer.get_cell_tile_data(cell)
		if data == null:
			continue

		for polygon in range(data.get_collision_polygons_count(0)):
			if data.is_collision_polygon_one_way(0, polygon):
				return true

	# Moving one-way platforms (AnimatableBody2D inside moving_platform.tscn).
	for node in scene.find_children("*", "CollisionShape2D", true, false):
		var shape := node as CollisionShape2D
		if shape == null or not shape.one_way_collision:
			continue

		var body := shape.get_parent() as CollisionObject2D
		if body == null or not body.is_in_group("one_way_platforms"):
			continue

		var local_feet := shape.to_local(feet)
		if shape.shape is RectangleShape2D:
			var rect := (shape.shape as RectangleShape2D).get_rect()
			if rect.has_point(local_feet):
				return true
		elif shape.shape is ConvexPolygonShape2D:
			# Same trapezoid as the one-way tiles, scaled to the platform width.
			if _point_in_convex(local_feet, (shape.shape as ConvexPolygonShape2D).points):
				return true

	return false


func _point_in_convex(point: Vector2, points: PackedVector2Array) -> bool:
	# Convex polygon: the point is inside if it stays on the same side of
	# every edge. Returns true on the boundary too.
	if points.size() < 3:
		return false

	var sign := 0.0
	for i in points.size():
		var edge := points[(i + 1) % points.size()] - points[i]
		var side := edge.cross(point - points[i])
		if absf(side) < 0.0001:
			continue
		var s := 1.0 if side > 0.0 else -1.0
		if sign == 0.0:
			sign = s
		elif s != sign:
			return false

	return true

func _get_character_bottom() -> float:
	var character = get_parent()
	var hitbox := character.get_node_or_null("PlayerHitbox") as CollisionShape2D
	if hitbox and hitbox.shape is RectangleShape2D:
		return hitbox.position.y + (hitbox.shape as RectangleShape2D).size.y * 0.5
	return 32.0

func change_state(new_state_name: String) -> void:
	previous_state_name = current_state.name.to_lower() if current_state else ""
	if current_state:
		current_state.exit()
		
	current_state = states.get(new_state_name.to_lower())
	
	if current_state:
		current_state.enter()
