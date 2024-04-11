extends Container

@onready var top_info_node = $PauseFade/TopPanelContainer
@onready var bottom_info_node = $PauseFade/BottomPanelContainer

var panel_dist: float = 100
var transition_mat


func pause_game(eyelids_mat):
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
	)
