extends Control

@export var game_state_manager: GameStateManager

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _master_vol_slider = (
		$PanelContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider)
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _music_vol_slider = (
		$PanelContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider)
@onready var _sfx_bus = AudioServer.get_bus_index("SFX")
@onready var _sfx_vol_slider = $PanelContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider


func _ready() -> void:
	visible = game_state_manager.game_state == GameStateManager.GameState.PAUSED

	game_state_manager.game_state_changed.connect(
			func(_from, to): 
				if to == GameStateManager.GameState.PAUSED:
					_on_pause()
	)
	$PanelContainer/VBoxContainer/Resume.pressed.connect(_handle_resume)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(_handle_restart)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(_handle_quit)

	_master_vol_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	_music_vol_slider.value = AudioServer.get_bus_volume_linear(_music_bus)
	_sfx_vol_slider.value = AudioServer.get_bus_volume_linear(_sfx_bus)


func _handle_resume():
	visible = false
	game_state_manager.game_state = GameStateManager.GameState.PLAYING


func _handle_restart():
	game_state_manager.game_state = GameStateManager.GameState.INIT


func _handle_quit():
	game_state_manager.game_state = GameStateManager.GameState.EXIT


func _on_pause():
	$PauseSound.play()
	visible = true


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_bus, value)
