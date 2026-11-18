
extends FrogState

@export var initial_frogstate: FrogState

var current_frogstate: FrogState
var frogstates: Dictionary = {}


func _ready():
	print("===== FROG FSM INITIALIZING =====")

	for child in get_children():
		if child is FrogState:
			var state_name = child.name.to_lower()

			frogstates[state_name] = child
			child.Transitioned.connect(on_child_transition)

			print("Estado registrado: ", state_name)

	if initial_frogstate:
		current_frogstate = initial_frogstate
		print("Estado inicial: ", current_frogstate.name)
		current_frogstate.enter()
	else:
		push_error("No has asignado Initial Frogstate")


func _process(delta):
	if current_frogstate:
		current_frogstate.update(delta)


func _physics_process(delta):
	if current_frogstate:
		current_frogstate.physics_update(delta)


func on_child_transition(frogstate, new_frogstate_name):
	print("FSM: Señal recibida desde ", frogstate.name)
	print("FSM: Estado solicitado: ", new_frogstate_name)

	if frogstate != current_frogstate:
		print("FSM: RECHAZADO. El estado emisor no es el actual.")
		return

	transition_to(new_frogstate_name)


func transition_to(new_frogstate_name: String):
	if not current_frogstate:
		return

	if current_frogstate.name == "FrogDeath":
		return

	var target_name = new_frogstate_name.to_lower()

	print("FSM: Buscando estado ", target_name)

	var new_frogstate = frogstates.get(target_name)

	if not new_frogstate:
		push_error("FSM: No existe el estado " + target_name)
		return

	if new_frogstate == current_frogstate:
		return

	print("FSM: CAMBIANDO ", current_frogstate.name, " -> ", new_frogstate.name)

	current_frogstate.exit()
	current_frogstate = new_frogstate
	current_frogstate.enter()
