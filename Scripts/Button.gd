@tool
extends StaticBody3D

@export var connected_objects: Array[Door]
@export_flags_3d_render var visibility_flags
@export var button_material: Material:
	set(val):
		button_material = val
		if find_child("ButtonMesh") != null:
			$ButtonMesh.mesh.material = val
@export_range(1.0,3.0,0.25) var button_size: float = 2.0:
	set(val):
		button_size = val
		update_button_size()
@export_range(0.05,0.3,0.05) var margin_size: float = 0.1:
	set(val):
		margin_size = val
		update_button_size()
	
var _pressed: bool

signal button_activated()
signal button_deactivated()


func _ready():
	if not Engine.is_editor_hint():
		_pressed = false
		#Setup visibilities and materials
		($BaseMesh as MeshInstance3D).layers = visibility_flags
		($ButtonMesh as MeshInstance3D).layers = visibility_flags
		($ButtonMesh as MeshInstance3D).mesh.material = button_material
		
		#Chain signals through from button activation area
		($Activation as Area3D).body_entered.connect(func(body): manage_button(true, body))
		($Activation as Area3D).body_exited.connect(func(body): manage_button(false, body))
		
		collision_layer = visibility_flags
		set_collision_layer_value(1,true)
		
		#Waits for the scene root to finish running before continuing
		await owner.ready
		
		#Attaches all objects that are to be controlled by this button
		for obj in connected_objects:
			if obj.has_method("open"):
				button_activated.connect(obj.open)
			else:
				push_warning(str(obj) + " is connected to a button without an open() function")
			
			if obj.has_method("close"):
				button_deactivated.connect(obj.close)
			else:
				push_warning(str(obj) + " is connected to a button without a close() function")
			
			if obj.has_method("button_handshake"):
				obj.button_handshake()


func manage_button(activate:bool, body: Node3D):
	#cutton functionality
	if activate and not _pressed and $Activation.has_overlapping_bodies():
		_pressed = true
		button_activated.emit()
	elif not activate and _pressed and not $Activation.has_overlapping_bodies():
		_pressed = false
		button_deactivated.emit()


func update_button_size():
	var base_mesh
	if find_child("BaseMesh") != null:
		base_mesh = ((find_child("BaseMesh")\
				 as MeshInstance3D).mesh as BoxMesh)
	
	var collision_box
	if find_child("ButtonCollision") != null:
		collision_box = ((find_child("ButtonCollision")\
				 as CollisionShape3D).shape as BoxShape3D)
	
	var button_mesh
	if find_child("ButtonMesh") != null:
		button_mesh = ((find_child("ButtonMesh")\
				 as MeshInstance3D).mesh as BoxMesh)
	
	var activation_box
	if find_child("Activation/CollisionShape3D") != null:
		activation_box = ((find_child("Activation/CollisionShape3D")\
				as CollisionShape3D).shape as BoxShape3D)
	
	var inner_size = button_size - margin_size - margin_size
	if inner_size <= 0.1:
		inner_size = 0.1
	
	base_mesh.size.x = button_size
	base_mesh.size.z = button_size
	
	collision_box.size.x = button_size
	collision_box.size.z = button_size
	
	button_mesh.size.x = inner_size
	button_mesh.size.z = inner_size
	
	activation_box.size.x = inner_size
	activation_box.size.z = inner_size
