class_name GameStateManager
extends Node

signal game_state_changed(from: GameState, to: GameState)

enum GameState {
	INIT,
	PLAYING,
	PAUSED,
	EXIT,
}

var game_state: GameState:
	set(value):
		var prev_value = game_state
		game_state = value
		_handle_game_state_changed(prev_value, value)
		game_state_changed.emit(prev_value, value)


func _ready() -> void:
	get_tree().paused = true # TODO: Add loading screen when initializing things
	game_state = GameState.PLAYING


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			game_state = GameState.PLAYING
		else:
			game_state = GameState.PAUSED


func _handle_game_state_changed(prev_state: GameState, curr_state: GameState) -> void:
	match [prev_state, curr_state]:
		[GameState.INIT, GameState.PLAYING]:
			_resume()
		[GameState.PAUSED, GameState.PLAYING]:
			_resume()
		[GameState.PLAYING, GameState.PAUSED]:
			_pause()
		[GameState.PAUSED, GameState.EXIT]:
			_exit()
		[GameState.PAUSED, GameState.INIT]:
			_restart()
		[_,_]:
			assert(false, "This game state change is unhandled.")


func _pause() -> void:
	get_tree().paused = true


func _resume() -> void:
	get_tree().paused = false


func _restart() -> void:
	get_tree().reload_current_scene()


func _exit() -> void:
	get_tree().quit()
