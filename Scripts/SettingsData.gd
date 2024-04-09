extends Resource
class_name SettingsData

var music_vol: int
var sfx_vol: int
var mouse_sense: float

func _init(m_music_vol: int = 10, m_sfx_vol: int = 10, m_mouse_sense: float = 1.0):
	music_vol = m_music_vol
	sfx_vol = m_sfx_vol
	mouse_sense = m_mouse_sense
