extends Control

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
	_master_vol_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	_music_vol_slider.value = AudioServer.get_bus_volume_linear(_music_bus)
	_sfx_vol_slider.value = AudioServer.get_bus_volume_linear(_sfx_bus)


func setup(game: Game) -> void:
	game.state_changed.connect(_handle_state_changed)

	$PanelContainer/VBoxContainer/Resume.pressed.connect(game.resume_game)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(game.restart_game)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(
			func(): game.exit_game(Game.ExitScene.GAME_MENU))
	$PanelContainer/VBoxContainer/Close.pressed.connect(game.exit_game)


func _handle_state_changed(from: Game.State, to: Game.State) -> void:
	match from:
		Game.State.PAUSED:
			visible = false
	match to:
		Game.State.PAUSED:
			$PauseSound.play()
			visible = true


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_bus, value)
