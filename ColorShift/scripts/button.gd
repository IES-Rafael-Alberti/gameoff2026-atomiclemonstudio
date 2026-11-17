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
@export var button_color: String
@export var button_id: int

func _ready() -> void:
	# Disable monitoring by default on startup
	area_2d.monitoring = false
	
func _process(delta: float) -> void:
	var current_color = GameManager.get_color_name()
	
	# Check if the current game color matches this button's assigned color
	if current_color != button_color:
		visible = false
		area_2d.monitoring = false
		is_pressed = false
		return
	
	# If it DOES match, show the button and enable its area
	visible = true
	area_2d.monitoring = true
	
	# Manage the skins and their animations
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
	# Detect when the player enters the button area
	if body.is_in_group("player"):
		is_pressed = true
		GameManager.button_pressed(button_id)
