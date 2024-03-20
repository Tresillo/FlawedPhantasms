@tool
extends Area3D
@export_category("Visibility Properties")
@export var size: Vector3 = Vector3(1,1,1):
	set(val):
		size = val
		$CollisionShape3D.shape.size = val
		$MeshInstance3D.mesh.size = val


func _on_body_entered(body):
	if body is Player:
		(body as Player).void_out()
