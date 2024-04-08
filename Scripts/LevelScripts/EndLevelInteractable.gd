extends StaticBody3D
class_name LevelGoal

@export_file("*.tscn") var next_level_path: String

@onready var _level_loader: LevelLoader = get_node("/root/SceneLoaderAutoload")

signal level_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func end_level():
	print("hit end level trigger")
	level_finished.emit()
	
	if next_level_path != "" and next_level_path != null:
		_level_loader.goto_scene(next_level_path)
		push_warning("Eventually put this into background loading")
	else:
		get_tree().quit()
