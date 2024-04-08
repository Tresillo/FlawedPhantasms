extends ColorRect

class_name MenuPanel

var menu_input_objects: Array[BaseButton]

signal change_menu_layer(layer_index: int)

func _ready():
	for c in get_children(true):
		if c is BaseButton:
			menu_input_objects.append(c as BaseButton)

func set_inputs_disabled(disable: bool):
	menu_input_objects.map(func(btn): btn.disabled = disable)
