extends MenuPanel


func _on_back_button_pressed():
	change_menu_layer.emit(0)
