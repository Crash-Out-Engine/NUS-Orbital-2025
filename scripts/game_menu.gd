extends Control

func _on_start_game_pressed() -> void:
	Functions.load_screen_to_scene("res://scenes/game.tscn")

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	$SettingsMenu.visible = true


func _on_start_multiplayer_pressed() -> void:
	$MultiplayerLobbyMenu.visible = true
