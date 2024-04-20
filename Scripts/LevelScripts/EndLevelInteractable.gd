extends StaticBody3D
class_name LevelGoal

@onready var _level_loader: LevelLoader = get_node("/root/SceneLoaderAutoload")

signal level_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func end_level():
	print("hit end level trigger")
	level_finished.emit()
	
	_level_loader.goto_next_level()
