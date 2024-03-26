@tool
extends AnimatableBody3D
class_name Door

@export_category("Visibility Properties")
@export var size: Vector3 = Vector3(1,1,1):
	set(val):
		size = val
		$CollisionShape3D.shape.size = val
		$MeshInstance3D.mesh.size = val
		$EditorVisualisation/StartMesh.mesh.size = val
		$EditorVisualisation/EndMesh.mesh.size = val
@export var display_material: StandardMaterial3D:
	set(val):
		display_material = val
		if find_child("MeshInstance3D") != null:
			$MeshInstance3D.mesh.material = val
@export_flags_3d_render var visibility_flags

@export_category("Movement Properties")
@export var final_offset: Vector3 = Vector3(0,0,0):
	set(val):
		final_offset = val
		$EditorVisualisation/EndMesh.position = val
@export_range(0.1,3.0,0.1) var speed: float = 1.0
@export_range(0,1.0,0.01) var test_interpolation: float = 0.0:
	set(val):
		test_interpolation = val
		check_movement_by_lerp(val)
@export var opening_logic: DOOR_LOGIC = DOOR_LOGIC.OR

enum DOOR_STATE{
	OPENING,
	CLOSING,
	IDLE
}
enum DOOR_LOGIC{
	OR,
	AND
}

var _cur_state: DOOR_STATE = DOOR_STATE.IDLE
var _interp_val: float = 0.0
var _init_pos: Vector3

var _open_limit: int = -1
var _open_count: int = 0

func _ready():
	if Engine.is_editor_hint():
		$EditorVisualisation.visible = true
	
	if not Engine.is_editor_hint():
		$EditorVisualisation.visible = false
		check_movement_by_lerp(0.0)
		_init_pos = global_position
		($MeshInstance3D as MeshInstance3D).layers = visibility_flags
		collision_layer = visibility_flags
		set_collision_layer_value(1,true)
		_open_count = 0


func _process(delta):
	if not Engine.is_editor_hint():
		var position_mod = 0.0
		if _cur_state == DOOR_STATE.OPENING and _interp_val < 1.0:
			position_mod = delta * speed
		elif _cur_state == DOOR_STATE.CLOSING and _interp_val > 0.0:
			position_mod = delta * -speed
		
		if position_mod != 0.0:
			_interp_val = clamp(_interp_val + position_mod, 0.0, 1.0)
			global_position = lerp(_init_pos,_init_pos + final_offset, _interp_val)


func check_movement_by_lerp(amount: float):
	clamp(amount,0.0,1.0)
	$MeshInstance3D.position = lerp(Vector3(0,0,0),Vector3(0,0,0) + final_offset, amount)


func button_handshake():
	#runs every time a button connects its signals to this door
	match opening_logic:
		DOOR_LOGIC.OR:
			_open_limit = 0
		DOOR_LOGIC.AND:
			_open_limit += 1
		_:
			_open_limit = 0


func open():
	_open_count += 1
	if _open_count > _open_limit:
		_cur_state = DOOR_STATE.OPENING


func close():
	_open_count -= 1
	if _open_count <= _open_limit:
		_cur_state = DOOR_STATE.CLOSING
