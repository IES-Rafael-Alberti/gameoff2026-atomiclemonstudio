extends Control

@onready var label: Label = $Label
var visibility_tween: Tween


func _ready() -> void:
	visible = false
	update_label()
	GameManager.carrot_collected.connect(_on_carrot_collected)
	modulate.a = 0.0


func update_label() -> void:
	label.text = str(GameManager.carrots_picked) + "/" + str(GameManager.number_of_carrots)


func _on_carrot_collected() -> void:
	update_label()
	visible = true

	if visibility_tween and visibility_tween.is_valid():
		visibility_tween.kill()

	modulate.a = 0.0
	visibility_tween = create_tween()
	visibility_tween.tween_property(self, "modulate:a", 1.0, 0.25)
	visibility_tween.tween_interval(2.0)
	visibility_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	visibility_tween.finished.connect(_on_fade_finished)


func _on_fade_finished() -> void:
	visible = false
