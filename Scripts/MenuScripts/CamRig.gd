extends Node3D

@export_category("Camera Movement Properties")
@export var rig_limit_1: Vector2
@export var rig_limit_2: Vector2

@export var menu_layer_size: Vector2
@export var menu_layer_offset: Vector3
@export var menu_layer_anim_time: float
@export_range(0.0, 1.0, 0.05) var cam_move_weight: float

@export_category("UI Panel Properties")
@export var menu_panels: Array[MenuPanel]

@onready var _screen_size: Vector2 = get_viewport().get_visible_rect().size
@onready var _move_disable: bool = false
@onready var _cur_panel: int = 0
@onready var menu_ui_node: Control = $MainMenuUI
@onready var _level_loader: LevelLoader = get_node("/root/SceneLoaderAutoload")

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
		var mouse_percent_x = _mouse_pos.x  / _screen_size.x
		var mouse_percent_y = _mouse_pos.y  / _screen_size.y
		
		#var mouse_percent: Vector2 = Vector2(mouse_percent_x, mouse_percent_y)
		var menu_layer_pos: Vector2 = Vector2(\
				menu_layer_size.x * mouse_percent_x,\
				menu_layer_size.y * mouse_percent_y * -1)
		var menu_anchor_pos: Vector2 = rig_limit_1\
				+ Vector2(menu_layer_offset.x, menu_layer_offset.y)\
				 * 0
		var target_pos = menu_anchor_pos + menu_layer_pos
		var cur_pos = Vector2(position.x, position.y)
		var next_pos = lerp(cur_pos,target_pos,menu_layer_anim_time)
		
		position = Vector3(next_pos.x, next_pos.y, position.z)


func _on_menu_panel_change_menu_layer(layer_index):
	change_menu_layer(layer_index)


func change_menu_layer(next_menu_layer: int):
	var target_layer_position = menu_layer_offset * next_menu_layer + Vector3(rig_limit_1.x, rig_limit_1.y, 1)
	var initial_menu_size = menu_ui_node.size
	var hidden_menu_size = Vector2(initial_menu_size.x, 0)
	var cur_panel_node = menu_panels[_cur_menu_layer]
	var new_panel_node = menu_panels[next_menu_layer]
	
	print(cur_panel_node)
	
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(menu_ui_node,"size",hidden_menu_size,0.5)
	tween.tween_callback(func():
			cur_panel_node.set_inputs_disabled(true)
			cur_panel_node.visible = false
			
			new_panel_node.set_inputs_disabled(false)
			new_panel_node.visible = true
			
			_cur_menu_layer = next_menu_layer
	)
	tween.tween_property(menu_ui_node,"size",initial_menu_size,0.5)


func _on_play_button_pressed():
	
	var transition_mat = $MenuCam/CamEyelids.material
	
	var transfer_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	transfer_tween.tween_callback(func():
			#Disable Came movement
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			#Put cam on the same parent-child heirarchy as all of ther player objects
			
			print("TODO: Make Sound")
			
			transition_mat.set_shader_parameter("close_amount", 0.0)
			transition_mat.set_shader_parameter("lid_transparency", 1.0)
	)
	
	#Start the eyelids closing after a time
	transfer_tween.tween_property(transition_mat,"shader_parameter/lid_transparency",0.0,0.6)
	transfer_tween.tween_callback(func():
			_level_loader.goto_scene("res://Scenes/Levels/level_1.tscn")
	)

