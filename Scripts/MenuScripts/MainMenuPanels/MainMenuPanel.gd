extends MenuPanel

func _on_quit_button_pressed():
	get_tree().call_deferred("quit")
	button_clicked.emit()


func _on_level_button_pressed():
	change_menu_layer.emit(2)
	button_clicked.emit()


func _on_options_button_pressed():
	change_menu_layer.emit(1)
	button_clicked.emit()


func _on_play_button_pressed():
	button_clicked.emit()
