extends StaticBody3D

@export var connected_objects: Array

var _pressed: bool

signal button_activated()
signal button_deactivated()


func _ready():
	_pressed = false
	($Activation as Area3D).body_entered.connect(func(body): manage_button(true, body))
	($Activation as Area3D).body_exited.connect(func(body): manage_button(false, body))
	
	for obj in connected_objects:
		if obj.has_method("open"):
			button_activated.connect(obj.open)
		else:
			push_warning(str(obj) + " is connected to a button without an open() function")
		if obj.has_method("close"):
			button_activated.connect(obj.close)
		else:
			push_warning(str(obj) + " is connected to a button without an close() function")


func manage_button(activate:bool, body: Node3D):
	if activate and not _pressed and $Activation.has_overlapping_bodies():
		_pressed = true
		button_activated.emit()
	elif not activate and _pressed and not $Activation.has_overlapping_bodies():
		_pressed = false
		button_deactivated.emit()
