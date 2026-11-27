extends Node2D
## Small self-contained "poof" puff. It needs no external art and cleans
## itself up when the animation is over.

const LIFETIME: float = 0.45
const PUFF_COUNT: int = 7

var _progress: float = 0.0
var _offsets: Array[Vector2] = []
var _sizes: Array[float] = []


func _ready() -> void:
	z_index = 10

	for i in PUFF_COUNT:
		var angle: float = (
			TAU * float(i) / float(PUFF_COUNT) + randf_range(-0.35, 0.35)
		)
		_offsets.append(Vector2.from_angle(angle) * randf_range(0.7, 1.25))
		_sizes.append(randf_range(0.8, 1.3))

	var tween := create_tween()
	tween.tween_property(self, "_progress", 1.0, LIFETIME)
	tween.tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var fade: float = 1.0 - _progress
	var spread: float = 8.0 + 24.0 * _progress

	for i in PUFF_COUNT:
		var radius: float = (3.5 + 3.5 * _progress) * _sizes[i]
		draw_circle(_offsets[i] * spread, radius, Color(1.0, 0.95, 0.82, fade * 0.9))

	draw_circle(Vector2.ZERO, 5.0 + 9.0 * _progress, Color(1.0, 1.0, 1.0, fade * 0.55))
