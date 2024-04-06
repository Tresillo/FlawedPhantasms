@tool
extends StaticBody3D

@export var connected_objects: Array[Door]
@export_flags_3d_render var visibility_flags
@export var button_material: Material:
	set(val):
		button_material = val
		if get_node("ButtonMesh") != null and Engine.is_editor_hint():
			$ButtonMesh.mesh.material = val
@export_range(1.0,3.0,0.2) var button_size: float = 2.0:
	set(val):
		button_size = val
		update_button_size()
@export_range(0.05,0.3,0.05) var margin_size: float = 0.1:
	set(val):
		margin_size = val
		update_button_size()
@export var pitch_shift: float = 0.2

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
	#button functionality
	if activate and not _pressed and $Activation.has_overlapping_bodies():
		_pressed = true
		
		if $PressAudio.playing:
			$PressAudio.stop()
		$PressAudio.pitch_scale = 1.0
		$PressAudio.play()
		
		button_activated.emit()
	elif not activate and _pressed and not $Activation.has_overlapping_bodies():
		_pressed = false
		
		if $PressAudio.playing:
			$PressAudio.stop()
		$PressAudio.pitch_scale = 1.0 - pitch_shift
		$PressAudio.play()
		
		button_deactivated.emit()


func update_button_size():
	var invalid = false
	
	var base_mesh
	if get_node("BaseMesh") != null:
		base_mesh = ((get_node("BaseMesh")\
				 as MeshInstance3D).mesh as BoxMesh)
	else:
		print("BaseMesh not found")
		invalid = true
	
	var collision_box
	if get_node("ButtonCollision") != null:
		collision_box = ((get_node("ButtonCollision")\
				 as CollisionShape3D).shape as BoxShape3D)
	else:
		print("Collisionbox not found")
		invalid = true
	
	var button_mesh
	if get_node("ButtonMesh") != null:
		button_mesh = ((get_node("ButtonMesh")\
				 as MeshInstance3D).mesh as BoxMesh)
	else:
		print("ButtonMesh not found")
		invalid = true
	
	var activation_box
	if get_node("Activation/CollisionShape3D") != null:
		activation_box = ((get_node("Activation/CollisionShape3D")\
				as CollisionShape3D).shape as BoxShape3D)
	else:
		print("Activation Box not found")
		invalid = true
	
	if not invalid:
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
	
