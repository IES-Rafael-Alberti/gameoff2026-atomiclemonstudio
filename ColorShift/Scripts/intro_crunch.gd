extends Node2D
## Suena un crunch en cada mordisco del limón del logo (frames 1 y 2).
## Cicla los sonidos entre arranques: cada intro usa los dos siguientes
## (1-2, 3-4, 5-6, 1-2...), guardando el índice en user://.

const CRUNCHES: Array[AudioStream] = [
	preload("res://assets/sounds/crunch.1.ogg"),
	preload("res://assets/sounds/crunch.2.ogg"),
	preload("res://assets/sounds/crunch.3.ogg"),
	preload("res://assets/sounds/crunch.5.ogg"),
	preload("res://assets/sounds/crunch.6.ogg"),
]
const BITES_PER_INTRO := 2
const SAVE_PATH := "user://intro_crunch.cfg"
const VOLUME_DB := 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _player := AudioStreamPlayer.new()
var _next := 0


func _ready() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH) # Si no existe aún, se empieza por el primero
	_next = int(config.get_value("intro", "next_crunch", 0)) % CRUNCHES.size()
	# Se avanza ya, así el ciclo sigue aunque se salte la intro
	config.set_value("intro", "next_crunch", (_next + BITES_PER_INTRO) % CRUNCHES.size())
	config.save(SAVE_PATH)

	_player.bus = &"SFX"
	_player.volume_db = VOLUME_DB
	_player.max_polyphony = BITES_PER_INTRO # El primer crunch no se corta si dura más de 1 s
	add_child(_player)

	# El frame lo cambia la pista del AnimationPlayer, así el sonido va clavado a la animación
	_sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if _sprite.frame == 0: # Limón entero: aún no hay mordisco
		return
	_player.stream = CRUNCHES[_next]
	_player.play()
	_next = (_next + 1) % CRUNCHES.size()
