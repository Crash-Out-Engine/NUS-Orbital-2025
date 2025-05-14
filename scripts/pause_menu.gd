extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var master_vol_slider = $PanelContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var music_vol_slider = $PanelContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var sfx_vol_slider = $PanelContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider

func _ready() -> void:
	visible = get_tree().paused
	master_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

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
	if Input.is_action_just_pressed("esc") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:	
	resume()
	restart()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))


func _on_quit_pressed() -> void:
	get_tree().quit() # Replace with function body.
