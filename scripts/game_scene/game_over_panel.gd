extends Control


func setup(game: Game):
	game.game_over.connect(_display)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(game.restart_game)
	$PanelContainer/VBoxContainer/Quit.pressed.connect(
			func(): game.exit_game(Game.ExitScene.GAME_MENU))
	$PanelContainer/VBoxContainer/Close.pressed.connect(game.exit_game)


func _display(message: String) -> void:
	$PanelContainer/VBoxContainer/MessageLabel.text = message
	visible = true
