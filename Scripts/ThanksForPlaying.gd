extends Node2D

var text_label: Label
var fade_rect: ColorRect
var _level_loader: LevelLoader

func _ready():
	
	text_label = $CanvasLayer/PanelContainer/CenterContainer/ThanksText
	fade_rect = $CanvasLayer/PanelContainer/FadeRect
	_level_loader = get_node("/root/SceneLoaderAutoload")
	
	var fade_col_default = fade_rect.color
	var fade_col_trans = Color(fade_col_default, 0)
	
	var display_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	display_tween.tween_callback(func():
			fade_rect.color = fade_col_default
	)
	display_tween.tween_property(fade_rect, "color", fade_col_trans, 1.0)
	display_tween.tween_interval(2.5)
	display_tween.tween_property(fade_rect, "color", fade_col_default, 1.0)
	display_tween.tween_interval(0.25)
	display_tween.tween_callback(func():
			_level_loader.goto_scene("res://Scenes/main_menu.tscn")
	)
