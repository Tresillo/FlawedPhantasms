extends StaticBody3D
class_name LevelGoal

@export_file("*.tscn") var next_level_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func end_level():
	print("hit end level trigger")
	get_tree().quit()
