extends Node2D


func _on_area_2d_body_entered(body) -> void:
	if not body.is_in_group("player"):
		return
	get_parent().queue_free()
