@tool
extends StaticBody3D
class_name RectWall

@export var size: Vector3 = Vector3(1,1,1):
	set(val):
		size = val
		$CollisionShape3D.shape.size = val
		$MeshInstance3D.mesh.size = val
@export var display_material: StandardMaterial3D:
	set(val):
		display_material = val
		if find_child("MeshInstance3D") != null:
			$MeshInstance3D.mesh.material = val
@export_flags_3d_render var visibility_flags
@export var is_window: bool;


func _ready():
	if not Engine.is_editor_hint():
		($MeshInstance3D as MeshInstance3D).layers = visibility_flags
		collision_layer = visibility_flags
		set_collision_layer_value(1,true)
		
		if is_window:
			add_to_group("window")
