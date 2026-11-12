extends Node

class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

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

	# Move the body just below the one-way band and start falling. This is
	# enough to clear the platform without disabling any collision layer.
	character.global_position.y += 7.0
	character.velocity.y = 60.0

func _is_on_one_way_platform(character: CharacterBody2D) -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false

	var bottom := _get_character_bottom()
	# Sample just below the feet: that is the tile the character is standing on.
	var feet := character.global_position + Vector2(0.0, bottom + 2.0)

	for node in scene.find_children("*", "TileMapLayer", true, false):
		var layer := node as TileMapLayer
		if layer == null:
			continue

		var cell := layer.local_to_map(layer.to_local(feet))
		var data := layer.get_cell_tile_data(cell)
		if data == null:
			continue

		for polygon in range(data.get_collision_polygons_count(0)):
			if data.is_collision_polygon_one_way(0, polygon):
				return true

	return false

func _get_character_bottom() -> float:
	var character = get_parent()
	var hitbox := character.get_node_or_null("PlayerHitbox") as CollisionShape2D
	if hitbox and hitbox.shape is RectangleShape2D:
		return hitbox.position.y + (hitbox.shape as RectangleShape2D).size.y * 0.5
	return 32.0

func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit()
		
	current_state = states.get(new_state_name.to_lower())
	
	if current_state:
		current_state.enter()
