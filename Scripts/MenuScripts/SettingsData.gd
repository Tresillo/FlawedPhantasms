extends Resource
class_name SettingsData

var music_vol: int
var sfx_vol: int
var mouse_sense: float
var reduced_motion: bool

func _init(m_music_vol: int = 10, m_sfx_vol: int = 10, m_mouse_sense: float = 3.0, m_reduced_motion: bool = false):
	music_vol = m_music_vol
	sfx_vol = m_sfx_vol
	mouse_sense = m_mouse_sense
	reduced_motion = m_reduced_motion
