extends Node

class_name DataLoader

const number_of_levels: int = 3
var save_data: SaveData

func _ready():
	save_data = SaveData.new(number_of_levels)
