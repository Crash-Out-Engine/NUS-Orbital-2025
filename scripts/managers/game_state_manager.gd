class_name GameStateManager
extends Node

signal game_state_changed(from: State, to: State)

enum State {
	INIT,
	PLAYING,
	PAUSED,
	EXIT,
}

const _HUD_MAP_SCENE := preload("res://scenes/ui/hud_map.tscn")
const _HUD_BARS_SCENE := preload("res://scenes/ui/hud_bars.tscn")
const _INVENTORY_SCENE := preload("res://scenes/ui/inventory.tscn")
const _DEBUG_PANEL_SCENE := preload("res://scenes/ui/debug_panel.tscn")
const _PAUSE_MENU_SCENE := preload("res://scenes/ui/pause_menu.tscn")

var game_state: State:
	set(value):
		var prev_value = game_state
		game_state = value
		_handle_game_state_changed(prev_value, value)
		game_state_changed.emit(prev_value, value)

var _game: Game


func _ready() -> void:
	get_tree().paused = true # TODO: Add loading screen when initializing things
	_game = get_parent() as Game
	_game.ready.connect(func(): call_deferred("_start_init"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			game_state = State.PLAYING
		else:
			game_state = State.PAUSED


func _start_init() -> void:
	await GameLoader.load(_game, GameLoader.LoadSequence.PLAYERS)
	await GameLoader.load(_game, GameLoader.LoadSequence.WORLD_GEN)
	await GameLoader.load(_game, GameLoader.LoadSequence.CAMERA)
	await GameLoader.load(_game, GameLoader.LoadSequence.UI)
	game_state = State.PLAYING


func _handle_game_state_changed(prev_state: State, curr_state: State) -> void:
	match [prev_state, curr_state]:
		[State.INIT, State.PLAYING]:
			_resume()
		[State.PAUSED, State.PLAYING]:
			_resume()
		[State.PLAYING, State.PAUSED]:
			_pause()
		[State.PAUSED, State.EXIT]:
			_exit()
		[State.PAUSED, State.INIT]:
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


class GameLoader:
	enum LoadSequence {
		PLAYERS,
		WORLD_GEN,
		CAMERA,
		UI,
	}

	static func load(game: Game, sequence: LoadSequence) -> void:
		match sequence:
			LoadSequence.PLAYERS:
				while game._local_player == null:
					await game.get_tree().process_frame
				assert(game._local_player != null)
			LoadSequence.WORLD_GEN:
				var world_gen_system := game.get_node(^"WorldGenSystem") as WorldGenSystem
				world_gen_system.setup()

				var enemy_spawner := game.get_node(^"EnemySpawner") as EnemySpawner
				enemy_spawner.setup(game)
			LoadSequence.CAMERA:
				var camera := game.get_node(^"Camera2D") as Camera
				camera.setup(game)
			LoadSequence.UI:
				var ui_node = game.get_node(^"UI") as CanvasLayer

				var hud_bars := ui_node.get_node(^"HUDBars") as HUDBars
				hud_bars.setup(game, game.get_node(^"PowerManager"))

				var hud_map := ui_node.get_node(^"HUDMap") as HUDMap
				hud_map.setup(game, game.get_node(^"EntityManager"))

				var pause_menu := ui_node.get_node(^"PauseMenu") as PauseMenu
				pause_menu.setup(game.get_node(^"GameStateManager"))

				var inventory := ui_node.get_node(^"Inventory") as Inventory
				inventory.setup()

				var debug_panel := ui_node.get_node(^"DebugPanel") as DebugPanel
				debug_panel.setup(game)
