extends MenuPanel

@onready var _data_loader_node = get_node("/root/DataLoaderAutoload")
@onready var _music_volume_label_node = %MusicVolumeAmount
@onready var _sfx_volume_label_node = %SFXVolumeAmount
@onready var _cam_sensitivity_label_node = %CamSensitivityAmount

var music_vol: int
var sfx_vol: int
var cam_sense: float
var reduced_motion: bool


func _ready():
	var settings: SettingsData = (_data_loader_node.save_data.settings as SettingsData)
	music_vol = settings.music_vol
	sfx_vol = settings.sfx_vol
	cam_sense = settings.mouse_sense
	reduced_motion = settings.reduced_motion
	
	_update_display()


func _on_back_button_pressed():
	change_menu_layer.emit(0)

#region Sound Settings

func _on_sfx_left_button_pressed():
	sfx_vol = clampi(sfx_vol - 1, 0, 10)
	_set_audio_bus_volume(AudioServer.get_bus_index("SFX"), sfx_vol)
	_update_display()


func _on_sfx_right_button_pressed():
	sfx_vol = clampi(sfx_vol + 1, 0, 10)
	_set_audio_bus_volume(AudioServer.get_bus_index("SFX"), sfx_vol)
	_update_display()


func _on_music_left_button_pressed():
	music_vol = clampi(music_vol - 1, 0, 10)
	_set_audio_bus_volume(AudioServer.get_bus_index("Music"), music_vol)
	_update_display()


func _on_music_right_button_pressed():
	music_vol = clampi(music_vol + 1, 0, 10)
	_set_audio_bus_volume(AudioServer.get_bus_index("Music"), music_vol)
	_update_display()


func _map_volume_to_audio_bus_level(value: int) -> float:
	match value:
		10: return -1 
		9: return -3 
		8: return -6 
		7: return -8 
		6: return -12 
		5: return -16 
		4: return -21 
		3: return -28 
		2: return -37 
		1: return -49 
		0: return -100 
	return 1


func _set_audio_bus_volume(bus_idx: int, volume_gain: float):
	var volume_db: float = _map_volume_to_audio_bus_level(volume_gain)
	if volume_db <= -100.0 or volume_db > 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, true)
	
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

#endregion

#region Gameplay Settings

func _on_cam_sensitivity_slider_value_changed(value):
	cam_sense = value / 100
	_update_display()


func _on_reduced_motion_box_toggled(toggled_on):
	reduced_motion = toggled_on
	_update_display()

#endregion

func _update_display():
	var settings: SettingsData = (_data_loader_node.save_data.settings as SettingsData)
	settings.music_vol = music_vol
	settings.sfx_vol = sfx_vol
	settings.mouse_sense = cam_sense
	settings.reduced_motion = reduced_motion
	
	%MusicVolumeAmount.text = str("%02d" % music_vol)
	%SFXVolumeAmount.text = str("%02d" % sfx_vol)
	%CamSensitivityAmount.text = str("%03.2f" % cam_sense)
	%CamSensitivitySlider.value = cam_sense * 100

