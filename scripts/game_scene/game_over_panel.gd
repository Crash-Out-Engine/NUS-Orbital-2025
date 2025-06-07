extends Control

@export var game_scene : Game

func _ready() -> void:
	visible = false
	game_scene.game_over.connect(display)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(restart)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(quit)
	$PanelContainer/VBoxContainer/Close.pressed.connect(close_game)

func display(message: String) -> void:
	$PanelContainer/VBoxContainer/MessageLabel.text = message
	visible = true

func restart():
	get_tree().paused = false
	Functions.load_screen_to_scene("res://scenes/game.tscn")

func quit():
	Functions.load_screen_to_scene("res://scenes/game_menu.tscn")

func close_game():
	get_tree().quit()
