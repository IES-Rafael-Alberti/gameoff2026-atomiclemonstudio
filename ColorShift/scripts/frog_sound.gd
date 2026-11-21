
extends Node2D

# Tiempo entre reproducciones.
@export var intervalo: float = 5.0

# Distancia a la que el sonido deja de escucharse.
@export var distancia_maxima: float = 500.0

# Distancia a la que el sonido alcanza su volumen máximo.
@export var distancia_minima: float = 50.0

var temporizador: float = 0.0
var sonidos: Array[AudioStreamPlayer2D] = []


func _ready() -> void:
	for hijo in get_children():
		if hijo is AudioStreamPlayer2D:
			sonidos.append(hijo)

			# Configuración espacial.
			hijo.max_distance = distancia_maxima
			hijo.attenuation = 1.0


func _process(delta: float) -> void:
	if sonidos.is_empty():
		return

	temporizador += delta

	if temporizador >= intervalo:
		temporizador = 0.0
		reproducir_sonido_aleatorio()


func reproducir_sonido_aleatorio() -> void:
	var indice := randi_range(0, sonidos.size() - 1)
	var sonido = sonidos[indice]

	sonido.play()
