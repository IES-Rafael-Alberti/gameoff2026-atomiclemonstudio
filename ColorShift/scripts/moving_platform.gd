extends Node2D

## Plataforma móvil con trayectoria editable y color opcional.
##
## La ruta se dibuja en el nodo hijo Path2D: selecciónalo y mueve/añade puntos
## de su Curve2D en el viewport. Los puntos son relativos a este nodo, que es
## donde se coloca la plataforma en la escena.
##
## - ping_pong: va al final y vuelve al principio.
## - pause_at_ends: segundos quieto al llegar a cada extremo.
## - platform_distance: distancia del recorrido en px. Siempre se trata como
##   un valor positivo y se aplica hacia `direction`, asi que 600 recorre 600
##   px hacia la izquierda, arriba o abajo igual que hacia la derecha.
##   0 = respetar la curva dibujada a mano.
## - direction: "right" (por defecto), "left", "up" o "down". La plataforma
##   siempre sale del punto donde la colocaste y avanza en esa direccion.
##
## Igual que los tiles de color del tilemap (tile_map_manager.gd):
## - platform_color: la plataforma solo existe en ese color (visible y sólida).
##   GREY es permanente, como los tiles grises del tilemap.
## El sprite se recorta del mismo atlas que usa level_4, así que se ve igual
## que las plataformas pintadas en el TileMapLayerDefinitive.

signal reached_end
signal reached_start

const ATLAS_BASE := preload("res://assets/sprites/scenary/Tileset - 4 colors.png")
const ATLAS_COMBO := preload("res://assets/sprites/scenary/Tileset-2222.png")

# [índice de atlas (0=base, 1=mezclas), tile_x, tile_y] de la plataforma de 96x32.
const PLATFORM_REGIONS := {
	"GREY": [0, 3, 4],
	"RED": [0, 9, 4],
	"BLUE": [0, 3, 11],
	"YELLOW": [0, 9, 11],
	"PURPLE": [1, 9, 4],
	"GREEN": [1, 3, 11],
	"ORANGE": [1, 9, 11],
}

@export var speed: float = 60.0
## Distancia del recorrido en px (siempre positiva). 0 = curva dibujada a mano.
@export_range(0.0, 10000.0, 1.0) var platform_distance: float = 0.0
## Direccion en la que avanza la plataforma desde su punto de origen.
@export_enum("right", "left", "up", "down") var direction: String = "right"
@export var ping_pong: bool = true
@export var pause_at_ends: float = 0.0
@export_range(0.0, 1.0, 0.01) var start_progress: float = 0.0
@export var auto_start: bool = true
@export_enum("GREY", "RED", "BLUE", "YELLOW", "ORANGE", "PURPLE", "GREEN") var platform_color: String = "GREY"

@onready var _follow: PathFollow2D = $Path2D/PathFollow2D
@onready var _body: AnimatableBody2D = $Platform
@onready var _sprite: Sprite2D = $Platform/Sprite2D
@onready var _shape: CollisionShape2D = $Platform/CollisionShape2D

var _direction: float = 1.0
var _pause_left: float = 0.0


func _ready() -> void:
	_follow.rotates = false
	_follow.loop = false

	# La Curve2D del prefab es un SubResource compartido por todas las
	# instancias. Sin duplicarla, modificar una plataforma cambiaria todas.
	var path := _follow.get_parent() as Path2D
	if path != null and path.curve != null:
		path.curve = path.curve.duplicate() as Curve2D

	# La distancia siempre es positiva: el signo lo pone `direction`.
	var distance := absf(platform_distance)
	if distance > 0.0:
		_apply_distance(distance)
	if direction != "right":
		_apply_direction(direction)

	var length := _path_length()
	_follow.progress = clampf(start_progress, 0.0, 1.0) * length
	_direction = -1.0 if is_equal_approx(start_progress, 1.0) else 1.0
	set_physics_process(auto_start)

	_sprite.texture = _make_platform_texture(platform_color)
	if not GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.connect(_on_color_changed)
	_on_color_changed(GameManager.get_color_name())

	_sync_body()


func _exit_tree() -> void:
	if GameManager.color_changed.is_connected(_on_color_changed):
		GameManager.color_changed.disconnect(_on_color_changed)


func _on_color_changed(color: String) -> void:
	# Igual que los tiles de color: GREY es permanente y los demas solo
	# existen mientras su color esta activo.
	var shown := platform_color == "GREY" or color == platform_color
	_body.visible = shown
	_shape.disabled = not shown


func _make_platform_texture(color: String) -> AtlasTexture:
	var region_info: Array = PLATFORM_REGIONS.get(color, PLATFORM_REGIONS["GREY"])
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = ATLAS_BASE if region_info[0] == 0 else ATLAS_COMBO
	atlas_texture.region = Rect2(region_info[1] * 32, region_info[2] * 32, 96, 32)
	atlas_texture.filter_clip = true
	return atlas_texture


# Estira la curva hasta `distance` px en horizontal, manteniendo la altura del
# ultimo punto. Solo toca el ultimo punto, asi los intermedios se conservan.
func _apply_distance(distance: float) -> void:
	var path := _follow.get_parent() as Path2D
	if path == null or path.curve == null:
		return

	var curve: Curve2D = path.curve
	var last: int = curve.get_point_count() - 1
	if last < 1:
		return

	var point: Vector2 = curve.get_point_position(last)
	point.x = distance
	curve.set_point_position(last, point)


# Orienta la curva segun `dir`. Los puntos son relativos al nodo, asi que el
# origen se mantiene y solo cambia hacia donde crece el recorrido:
#   right: ( x,  y)   left: (-x,  y)
#   up:    ( y, -x)   down: (-y,  x)
# Ademas de los puntos se giran los handles para conservar la forma de la curva.
func _apply_direction(dir: String) -> void:
	var path := _follow.get_parent() as Path2D
	if path == null or path.curve == null:
		return

	var curve: Curve2D = path.curve
	for i in curve.get_point_count():
		curve.set_point_position(i, _oriented(curve.get_point_position(i), dir))
		curve.set_point_in(i, _oriented(curve.get_point_in(i), dir))
		curve.set_point_out(i, _oriented(curve.get_point_out(i), dir))


func _oriented(v: Vector2, dir: String) -> Vector2:
	match dir:
		"left":
			return Vector2(-v.x, v.y)
		"up":
			return Vector2(v.y, -v.x)
		"down":
			return Vector2(-v.y, v.x)
		_:
			return v


func _sync_body() -> void:
	# Mover el cuerpo directamente (no dejar que herede la transformacion del
	# PathFollow2D) es necesario para que el servidor de fisicas actualice la
	# colision: con sync_to_physics el cuerpo arrastra al jugador.
	_body.global_position = _follow.global_position


func _physics_process(delta: float) -> void:
	var length := _path_length()
	if length <= 0.0:
		return

	if _pause_left > 0.0:
		_pause_left -= delta
		_sync_body()
		return

	if ping_pong:
		var next := _follow.progress + speed * delta * _direction
		if next >= length:
			_follow.progress = length
			_direction = -1.0
			_pause_left = pause_at_ends
			reached_end.emit()
		elif next <= 0.0:
			_follow.progress = 0.0
			_direction = 1.0
			_pause_left = pause_at_ends
			reached_start.emit()
		else:
			_follow.progress = next
		_sync_body()
		return

	_follow.progress += speed * delta
	if _follow.progress >= length:
		_follow.progress = length
		reached_end.emit()
		set_physics_process(false)
	_sync_body()


func _path_length() -> float:
	var path := _follow.get_parent() as Path2D
	var curve: Curve2D = path.curve if path != null else null
	return curve.get_baked_length() if curve != null else 0.0


func start() -> void:
	set_physics_process(true)


func stop() -> void:
	set_physics_process(false)


func go_to_progress(ratio: float) -> void:
	_follow.progress = clampf(ratio, 0.0, 1.0) * _path_length()
	_sync_body()
