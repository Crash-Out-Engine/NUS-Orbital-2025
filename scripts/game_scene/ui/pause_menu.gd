extends Control

@export var game : Game

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _master_vol_slider = (
		$PanelContainer/VBoxContainer/VolumeSliders/VBoxContainer/MasterVolume/MasterVolumeSlider)
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _music_vol_slider = (
		$PanelContainer/VBoxContainer/VolumeSliders/VBoxContainer/MusicVolume/MusicVolumeSlider)
@onready var _sfx_bus = AudioServer.get_bus_index("SFX")
@onready var _sfx_vol_slider = (
	$PanelContainer/VBoxContainer/VolumeSliders/VBoxContainer/SFXVolume/SFXVolumeSlider)


func _ready() -> void:
	visible = get_tree().paused

	$PanelContainer/VBoxContainer/Resume.pressed.connect(resume)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(restart)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(quit)
	$PanelContainer/VBoxContainer/Close.pressed.connect(close_game)

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
	get_tree().paused = false
	Functions.load_screen_to_scene("res://scenes/game.tscn")

func quit():
	get_tree().paused = false
	Functions.load_screen_to_scene("res://scenes/game_menu.tscn")

func close_game():
	get_tree().quit()


func try_esc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_bus, value)
