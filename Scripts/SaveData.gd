extends Resource
class_name SaveData

var number_of_levels: int
var level_data: Array[LevelData]

func _init(m_number_of_levels: int = 0, m_level_data:Array[LevelData] = []):
	number_of_levels = m_number_of_levels
	level_data = m_level_data
	
	for lvl_indx in range(number_of_levels):
		var new_level_data = LevelData.new()
		level_data.append(new_level_data)
