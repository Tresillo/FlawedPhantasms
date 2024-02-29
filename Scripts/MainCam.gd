extends Camera3D

var _cur_mask_id: int = 1


func _ready():
	for i in range(1,21):
		set_cull_mask_value(i, false)
	
	set_cull_mask_value(1, true)
	_cur_mask_id = 1


func update_cull_mask(new_id: int):
	if new_id >= 1 and new_id <= 20:
		set_cull_mask_value(_cur_mask_id, false)
		set_cull_mask_value(new_id, true)
		
		_cur_mask_id = new_id
	else:
		push_error("Visibility cull mask for main cam is set out of range (" + str(new_id) + ")")
