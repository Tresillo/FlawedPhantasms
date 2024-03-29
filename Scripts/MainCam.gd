extends Camera3D

var _cur_mask_id: int = 1
var lens_shader_material: ShaderMaterial:
	set(val):
		lens_shader_material = val
		if get_node("CamLens") != null:
			(get_node("CamLens") as MeshInstance3D).material_override = lens_shader_material
var cam_eyelids_node: ColorRect
var view_fogged:bool = false

func _ready():
	for i in range(1,21):
		set_cull_mask_value(i, false)
	
	set_cull_mask_value(1, true)
	_cur_mask_id = 1
	cam_eyelids_node = $UI/CamEyelids
	$UI/CameraFog.visible = false


func fog_cam_view(fog: bool):
	if $UI/CameraFog != null:
		$UI/CameraFog.visible = fog
		view_fogged = fog


func update_cull_mask(new_id: int):
	if new_id >= 1 and new_id <= 20:
		#updates the visibility layers for changing between players
		set_cull_mask_value(_cur_mask_id, false)
		set_cull_mask_value(new_id, true)
		set_cull_mask_value(1, true)
		
		_cur_mask_id = new_id
	else:
		push_error("Visibility cull mask for main cam is set out of range (" + str(new_id) + ")")
