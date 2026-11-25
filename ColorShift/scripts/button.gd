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


func _ready() -> void:
	# Disable monitoring by default on startup
	area_2d.monitoring = false


func _process(delta: float) -> void:
	# Con @tool el script tambien corre en el editor, donde no hay autoloads.
	if Engine.is_editor_hint():
		return

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
