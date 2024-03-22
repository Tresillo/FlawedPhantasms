@tool
extends Area3D
@export_category("Visibility Properties")
@export var size: Vector3 = Vector3(1,1,1):
	set(val):
		size = val
		$CollisionShape3D.shape.size = val
		$MeshInstance3D.mesh.size = val
		($MeshInstance3D as MeshInstance3D).material_override.set_shader_parameter("scroll_speed", 3.0 * pow(val.x,-1))


func _on_body_entered(body):
	if body is Player:
		(body as Player).void_out()
