extends Control

var mouse_over = false

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _master_vol_slider = (
		$PanelContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider)
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _music_vol_slider = (
		$PanelContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider)
@onready var _sfx_bus = AudioServer.get_bus_index("SFX")
@onready var _sfx_vol_slider = $PanelContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider

func _ready() -> void:
	_master_vol_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	_music_vol_slider.value = AudioServer.get_bus_volume_linear(_music_bus)
	_sfx_vol_slider.value = AudioServer.get_bus_volume_linear(_sfx_bus)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if mouse_over:
			visible = false
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			visible = false


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_bus, value)


func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
