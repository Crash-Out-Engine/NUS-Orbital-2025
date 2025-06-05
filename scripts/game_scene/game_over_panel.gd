extends Control

@export var game_scene : Game

func _ready() -> void:
	visible = false
	game_scene.game_over.connect(display)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(restart)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(quit)
	

func display(message: String) -> void:
	$PanelContainer/VBoxContainer/MessageLabel.text = message
	visible = true

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit():
	get_tree().quit()
