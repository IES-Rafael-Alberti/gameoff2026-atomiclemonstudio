extends Node2D

var player: CharacterBody2D
var tile_map_layer: Array[Node]

var follow: bool = false

@onready var grey_skin: Sprite2D = $GreySkin
@onready var red_skin: Sprite2D = $RedSkin
@onready var blue_skin: Sprite2D = $BlueSkin
@onready var yellow_skin: Sprite2D = $YellowSkin

# Variables for make the key have more movement
var time_passed: float = 0.0
var facing_direction: int = 1 # 1 = right, -1 = left
@export var float_speed: float = 2.0      # Oscilation velocity
@export var float_amplitude: float = 4.0  # How much goes up or down (in px)
@export var follow_distance: float = 35.0 # Distance to the back of the player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Lets tile layers find the key regardless of the scene hierarchy.
	add_to_group("key")

	# Find the player if it was not assigned in the inspector.
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Error: Player not found in the 'player' group")

	tile_map_layer = get_tree().get_nodes_in_group("tile_layers")
	if tile_map_layer.is_empty():
		print("Error: TileMapLayer not found in the 'tile_layers' group")
	
	# Hide the key until is picked up
	visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not follow or not player:
		return
	
	if player.velocity.x != 0:
		facing_direction = -1 if player.velocity.x < 0 else 1

	# Calculate the floating oscillation using a sine function
	time_passed += delta * float_speed
	var hover_offset = sin(time_passed) * float_amplitude

	# Calculate the target position (behind the player)
	# If facing right (1), the back is to the left (-follow_distance)
	var target_x = player.global_position.x - (follow_distance * facing_direction)
	var target_y = player.global_position.y + 5 + hover_offset

	# Smoothly move the key towards the target (Lerp)
	# You can change '15.0' to a higher number if you want it to be stiffer, or lower for more floatiness
	global_position.x = lerp(global_position.x, target_x, delta * 15.0)
	global_position.y = lerp(global_position.y, target_y, delta * 15.0)


func follow_player() -> void:
	# Start from the player so the key doesn't fly in from its scene position.
	if player:
		global_position = player.global_position
	visible = true
	follow = true
	
	match GameManager.get_color_name():
		"GREY": grey_skin.visible = true
		"RED": red_skin.visible = true
		"BLUE": blue_skin.visible = true
		"YELLOW": yellow_skin.visible = true
	
