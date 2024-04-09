extends Control
class_name MainMenuController

@onready var _data_loader_node = get_node("/root/DataLoaderAutoload")

var music_vol: int
var sfx_vol: int
var mouse_sense: float

func _ready():
	music_vol = 0
	sfx_vol = 0 
	mouse_sense = 1.0
