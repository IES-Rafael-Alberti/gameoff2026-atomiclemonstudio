@tool
extends Node2D

## Keeps the color-filter overlay hidden while editing the level.

func _ready() -> void:
	var glasses := get_node_or_null("Overlay/ColorGlasses") as CanvasItem
	if glasses:
		glasses.visible = not Engine.is_editor_hint()
