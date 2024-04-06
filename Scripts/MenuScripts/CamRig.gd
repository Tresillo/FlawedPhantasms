extends Node3D

@export var rig_limit_1: Vector2
@export var rig_limit_2: Vector2

@export var menu_layer_size: Vector2
@export var menu_layer_offset: Vector3
@export var menu_layer_anim_time: float
@export_range(0.0, 1.0, 0.05) var cam_move_weight: float

@onready var _screen_size: Vector2 = get_viewport().get_visible_rect().size
@onready var _move_disable: bool = false

var _mouse_pos: Vector2 = Vector2(0,0)
var _cur_menu_layer: int = 0

func _ready():
	global_position = Vector3(rig_limit_1.x, rig_limit_1.y, 1)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event):
	#Input for mouse
	if event is InputEventMouseMotion and not _move_disable:
		#move camera rig
		_mouse_pos = event.global_position


func _process(delta):
	if not _move_disable:
		var mouse_percent_x = _mouse_pos.x * menu_layer_size.x / _screen_size.x
		var mouse_percent_y = _mouse_pos.y * menu_layer_size.y / _screen_size.y
		
		var mouse_percent: Vector2 = Vector2(mouse_percent_x, mouse_percent_y)
		var menu_layer_pos: Vector2 = Vector2(\
				menu_layer_size.x * mouse_percent_x,\
				menu_layer_size.y * mouse_percent_y)
		var menu_anchor_pos: Vector2 = rig_limit_1\
				+ Vector2(menu_layer_offset.x, menu_layer_offset.y)\
				 * _cur_menu_layer
		var target_pos = menu_anchor_pos + menu_layer_pos
		var cur_pos = Vector2(position.x, position.y)
		var next_pos = lerp(cur_pos,target_pos,menu_layer_anim_time)
		
		position = Vector3(next_pos.x, next_pos.y, position.z)


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	if Input.is_action_just_pressed("interact"):
		pass
