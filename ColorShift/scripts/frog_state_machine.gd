extends Node

var frogstates : Dictionary = {}

func _ready():
	for child in get_children():
		if child is FrogState:
			frogstates[child.name] = child

func _process(delta):
	if current_frogstate:
		current_frogstate.Update(delta)

func _physics_process(delta):
	if current_frogstate:
		current_frogstate.Physics_Update(delta)
