class_name LevelData

var completed: bool
var runs: Array[Dictionary]
var collectible_found: bool


func _init(m_completed: bool = false, m_runs: Array[Dictionary] = [], m_collectible_found: bool = false):
	completed = m_completed
	runs = m_runs
	collectible_found = m_collectible_found
