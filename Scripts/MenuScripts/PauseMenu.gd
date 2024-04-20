extends Container

@export var col_found_texture: CompressedTexture2D
@export var col_unfound_texture: CompressedTexture2D

@onready var top_info_node = $PauseFade/TopPanelContainer
@onready var bottom_info_node = $PauseFade/BottomPanelContainer
@onready var collectible_icon = $PauseFade/TopPanelContainer/MarginContainer/HBoxContainer/CollectibleFoundLabel
@onready var level_title_node = $PauseFade/TopPanelContainer/MarginContainer/HBoxContainer/LevelNameLabel

var panel_dist: float = 100
var transition_mat


func pause_game(eyelids_mat):
	print("Paused")
	transition_mat = eyelids_mat
	var pause_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	
	var top_info_panel_size = Vector2(top_info_node.custom_minimum_size.x, panel_dist)
	var bottom_info_panel_size = Vector2(bottom_info_node.custom_minimum_size.x, panel_dist)
	
	pause_tween.tween_callback(func():
			transition_mat.set_shader_parameter("close_amount", 0.0)
			transition_mat.set_shader_parameter("lid_transparency", 1.0)
			
			var init_top_min_size = Vector2(top_info_node.custom_minimum_size.x, 0.0)
			var init_bottom_min_size = Vector2(bottom_info_node.custom_minimum_size.x, 0.0)
			top_info_node.custom_minimum_size = init_top_min_size
			bottom_info_node.custom_minimum_size = init_bottom_min_size
			
			#Show mouse
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
			self.visible = true
			
			get_tree().paused = true
	)
	pause_tween.tween_property(transition_mat,"shader_parameter/lid_transparency",0.45,0.2)
	pause_tween.parallel().tween_property(top_info_node, "custom_minimum_size", top_info_panel_size, 0.2)
	pause_tween.parallel().tween_property(bottom_info_node, "custom_minimum_size", bottom_info_panel_size, 0.2)


func resume_game(eyelids_mat):
	transition_mat = eyelids_mat
	var pause_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	
	var top_info_panel_size = Vector2(top_info_node.custom_minimum_size.x, 0.0)
	var bottom_info_panel_size = Vector2(bottom_info_node.custom_minimum_size.x, 0.0)
	
	pause_tween.tween_callback(func():
			var init_top_min_size = Vector2(top_info_node.custom_minimum_size.x, panel_dist)
			var init_bottom_min_size = Vector2(bottom_info_node.custom_minimum_size.x, panel_dist)
			top_info_node.custom_minimum_size = init_top_min_size
			bottom_info_node.custom_minimum_size = init_bottom_min_size
	)
	pause_tween.tween_property(transition_mat,"shader_parameter/lid_transparency",1.0,0.2)
	pause_tween.parallel().tween_property(top_info_node, "custom_minimum_size", top_info_panel_size, 0.2)
	pause_tween.parallel().tween_property(bottom_info_node, "custom_minimum_size", bottom_info_panel_size, 0.2)
	pause_tween.tween_callback(func():
			transition_mat.set_shader_parameter("close_amount", 0.0)
			transition_mat.set_shader_parameter("lid_transparency", 1.0)
			
			get_tree().paused = false
			self.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		_on_resume_button_pressed()


func _on_resume_button_pressed():
	resume_game(transition_mat)


func _on_restart_button_pressed():
	var _level_loader = get_node("/root/SceneLoaderAutoload")
	
	var transfer_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	transfer_tween.tween_callback(func():
			#Disable Cam movement
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	)
	transfer_tween.tween_property(transition_mat,"shader_parameter/lid_transparency",0.0,0.4)
	transfer_tween.tween_callback(func():
			_level_loader.goto_scene(_level_loader.current_scene_path)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			self.visible = false
	)


func _on_main_menu_button_pressed():
	var _level_loader = get_node("/root/SceneLoaderAutoload")
	
	var transfer_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	transfer_tween.tween_callback(func():
			#Disable Came movement
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	)
	transfer_tween.tween_property(transition_mat,"shader_parameter/lid_transparency",0.0,0.4)
	transfer_tween.tween_callback(func():
			_level_loader.goto_scene("res://Scenes/main_menu.tscn")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			self.visible = false
	)


func update_collectible_icon(found: bool):
	if found:
		collectible_icon.texture = col_found_texture
	else:
		collectible_icon.texture = col_unfound_texture


func update_level_title(name: String):
	if name != "":
		level_title_node.text = name
	else:
		level_title_node.text = "Unnamed Level"
	
