@icon("node_name_label_icon.svg")
extends Label

class_name DialogicNode_NameLabel

# If true, the label will be hidden if no character speaks.
@export var hide_when_empty := true
@export var name_label_root: Node = self
@export var use_character_color := true

func _ready() -> void:
	add_to_group('dialogic_name_label')
	if hide_when_empty:
		name_label_root.visible = false
	text = ""

func set_dialogic_text(value: String) -> void:
	text = value
	if name_label_root is Control:
		var root_control := name_label_root as Control
		root_control.size = root_control.get_combined_minimum_size()
	if hide_when_empty:
		name_label_root.visible = not value.is_empty()
	else:
		name_label_root.show()
