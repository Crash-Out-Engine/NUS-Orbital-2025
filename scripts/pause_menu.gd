extends Control

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _master_vol_slider = $PanelContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _music_vol_slider = $PanelContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var _sfx_bus = AudioServer.get_bus_index("SFX")
@onready var _sfx_vol_slider = $PanelContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider


func _ready() -> void:
	visible = get_tree().paused
	_master_vol_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	_music_vol_slider.value = AudioServer.get_bus_volume_linear(_music_bus)
	_sfx_vol_slider.value = AudioServer.get_bus_volume_linear(_sfx_bus)


func resume():
	visible = false
	get_tree().paused = false


func pause():
	$PauseSound.play()
	get_tree().paused = true
	visible = true


func restart():
	get_tree().reload_current_scene()


func try_esc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	restart()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_bus, value)


func _on_quit_pressed() -> void:
	get_tree().quit() # Replace with function body.
