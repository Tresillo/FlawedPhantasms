extends "res://Scripts/MenuScripts/MenuPanel.gd"

func _on_quit_button_pressed():
	get_tree().call_deferred("quit")


func _on_level_button_pressed():
	change_menu_layer.emit(1)


func _on_options_button_pressed():
	change_menu_layer.emit(1)
