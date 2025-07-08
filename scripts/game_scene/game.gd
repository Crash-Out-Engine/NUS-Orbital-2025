class_name Game
extends Node2D

## Emitted when the game is over, [param message] contains the reason of game over.
signal game_over(message: String)
signal state_changed(from: State, to: State)

enum State {
	DEFAULT,
	INIT,
	PLAYING,
	PAUSED,
	GAME_OVER,
	EXIT,
}

enum InitSequence {
	PLAYERS,
	WORLD_GEN,
	CAMERA,
	UI,
}

enum ExitScene {
	NONE,
	GAME_MENU,
}

var parameters: Dictionary
var transitioning: bool
var game_seed: int
var _local_player: Player
var _state: State:
	set(value):
		var prev_value = _state
		if prev_value != value:
			_state = value
			state_changed.emit(prev_value, value)
			_handle_state_changed(prev_value, value)

@onready var start_time := Time.get_ticks_msec() as int
@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var entity_manager := $EntityManager as EntityManager
@onready var power_manager := $PowerManager as PowerManager

func _ready() -> void:
	target_provider.set_entity_manager(entity_manager)
	if not "session_config_data" in parameters:
		_state = State.INIT
	else:
		var session_config_data = parameters["session_config_data"]
		load_saved_scene(session_config_data)


func _unhandled_key_input(event: InputEvent) -> void:
	if transitioning:
		return

	match _state:
		State.PLAYING:
			if event.is_action_pressed("esc"):
				get_viewport().set_input_as_handled()
				if not $UI/InventoryUI.is_open():
					pause_game()
				else:
					$UI/InventoryUI.defocus_element()

			if event.is_action_pressed("debug"): # Debug action should be propagated to DebugVisualsBase.
				$UI/DebugPanel.toggle_debug()

			if event.is_action_pressed("inventory"):
				get_viewport().set_input_as_handled()
				if not $UI/InventoryUI.is_open() and _local_player.state == Player.State.PLAYING:
					_local_player.state = Player.State.INVENTORY
					$UI/InventoryUI.open().connect(
							func():
								if _local_player.state == Player.State.INVENTORY:
									_local_player.state = Player.State.PLAYING
					, ConnectFlags.CONNECT_ONE_SHOT)
				else:
					$UI/InventoryUI.defocus_element()

		State.PAUSED:
			if event.is_action_pressed("esc"):
				get_viewport().set_input_as_handled()
				resume_game()


func _handle_state_changed(from: State, to: State) -> void:
	if to == State.PAUSED:
		get_tree().paused = true
	if from == State.PAUSED:
		get_tree().paused = false

	match [from, to]:
		[State.DEFAULT, State.INIT]:
			await _setup(InitSequence.PLAYERS)
			await _setup(InitSequence.WORLD_GEN)
			await _setup(InitSequence.CAMERA)
			await _setup(InitSequence.UI)
			power_manager.power_depleted.connect(func():
					end_game("Power has run out")
			)
			_local_player.lives_depleted.connect(func(): end_game("%s died" % _local_player.name))
			_state = State.PLAYING
			state_changed.connect(func(_from, _to): _sync_state.rpc(_to))
		[State.INIT, State.PLAYING]:
			pass
		[State.PAUSED, State.PLAYING], [State.PLAYING, State.PAUSED]:
			pass
		[State.PAUSED, State.EXIT], [State.GAME_OVER, State.EXIT]:
			pass ## Possible teardown code
		[State.PLAYING, State.GAME_OVER]:
			power_manager.active = false
			for entity in entity_manager.get_children():
				if entity.has_method("deactivate"):
					entity.deactivate()
		[_, _]:
			assert(false,
					"The state change from %s to %s is unhandled."
					% [State.find_key(from), State.find_key(to)])


func _setup(sequence: InitSequence) -> void:
	match sequence:
		InitSequence.PLAYERS:
			if is_multiplayer_authority():
				_add_players()
			while _local_player == null:
				await get_tree().process_frame
			assert(_local_player != null, "Player should not be null.")
		InitSequence.WORLD_GEN:
			$WorldGenSystem.setup(get_seed(), get_local_player())
			$EnemySpawner.setup(get_local_player(), entity_manager)
		InitSequence.CAMERA:
			$Camera2D.setup(get_local_player())
		InitSequence.UI:
			$UI/HUDBars.setup(get_local_player(), power_manager)
			$UI/HUDMap.setup(get_local_player(), entity_manager)
			$UI/InventoryUI.setup(self, get_local_player())
			$UI/DebugPanel.setup(get_local_player(), entity_manager, power_manager, $EnemySpawner)
			$UI/PauseMenu.setup(self)
			$UI/GameOverPanel.setup(self)


func _add_players() -> void:
	if not is_multiplayer_authority():
		return

	const _PLAYER_SCENE = preload("res://scenes/player.tscn")

	var peer_player: Dictionary[int, Player] = {}
	var ids = [1]
	ids.append_array(multiplayer.get_peers())
	for i in range(ids.size()):
		var player = _PLAYER_SCENE.instantiate()
		player.position.x += 40 * i # HACK: Should implement proper collision detection
		var peer = ids[i]
		entity_manager.server_add_entity(player, self)
		peer_player.set(peer, player)

	call_deferred("_register_players", peer_player)


func _register_players(peer_player: Dictionary[int, Player]) -> void:
	var peer_player_path: Dictionary[int, NodePath] = {}
	for peer in peer_player:
		peer_player_path.set(peer, peer_player[peer].get_path())
	_synced_register_players.rpc(peer_player_path)


func pause_game() -> void:
	assert(_state == State.PLAYING, "State should be PLAYING if pause_game is called")
	_state = State.PAUSED


func resume_game() -> void:
	assert(_state == State.PAUSED, "State should be PAUSED if resume_game is called")
	_state = State.PLAYING


func restart_game() -> void:
	_synced_restart.rpc()


func end_game(message: String) -> void:
	_state = State.GAME_OVER
	var seconds = (Time.get_ticks_msec() - start_time) / 1000 as int
	var minutes = floor(seconds / 60)
	seconds -= minutes * 60
	var time_message = "" as String
	if minutes > 0:
		time_message = "\nYou lasted %d minutes %d seconds" % [minutes, seconds]
	else:
		time_message = "\nYou lasted %d seconds" % seconds
	_synced_game_over.rpc(message + time_message)


func exit_game(to: ExitScene = ExitScene.NONE) -> void:
	_state = State.EXIT
	match to:
		ExitScene.NONE:
			get_tree().quit()
		ExitScene.GAME_MENU:
			Functions.load_screen_to_scene("res://scenes/game_menu.tscn")


#region Forwarding

func get_state() -> State:
	return _state


func get_power() -> float:
	return power_manager.get_power()


func get_local_player() -> Player:
	assert(_local_player != null, "Player should not be null.")
	return _local_player


func get_seed() -> int:
	if game_seed == 0:
		game_seed = randi()
	return game_seed

#endregion


#region Sync

@rpc("any_peer", "call_local", "reliable")
func _synced_register_players(peer_player_path: Dictionary[int, NodePath]) -> void:
	for peer in peer_player_path:
		var player = get_tree().root.get_node(peer_player_path[peer])
		player.set_multiplayer_authority(peer)
		if player.is_multiplayer_authority():
			_local_player = player
		else:
			player.get_node(^"Components").process_mode = Node.PROCESS_MODE_DISABLED


@rpc("any_peer", "call_local", "reliable")
func _synced_restart() -> void:
	get_tree().paused = false
	Functions.load_screen_to_scene("res://scenes/game.tscn", parameters)


@rpc("any_peer", "call_remote", "reliable")
func _sync_state(state: State, message: String = "") -> void:
	_state = state
	if state == State.GAME_OVER:
		game_over.emit(message)


@rpc("any_peer", "call_local", "reliable")
func _synced_game_over(message: String) -> void:
	game_over.emit(message)

#endregion


#region save

# TODO(Save): Saving other managers should be more sophisticated
func save_scene() -> PackedByteArray:
	var session_config := SessionConfig.new()
	session_config.game_seed = game_seed
	session_config.state = _state
	session_config.power = get_power()
	session_config.entities_data = entity_manager.save()
	return session_config.save()


## Takes in a SessionConfig in the form of PackedByteArray.
func load_saved_scene(data: PackedByteArray) -> void:
	var session_config := SessionConfig.from_saved(data)
	game_seed = session_config.game_seed
	_state = session_config.state
	if is_multiplayer_authority():
		power_manager._power = session_config.power
		entity_manager.load_saved(session_config.entities_data)

#endregion


class SessionConfig:
	var game_seed: int
	var state: State = Game.State.INIT
	var power: float = 100.0
	var entities_data: PackedByteArray = var_to_bytes([])


	func save() -> PackedByteArray:
		var dict := {}
		dict["game_seed"] = game_seed
		dict["state"] = state
		dict["power"] = power
		dict["entities_data"] = entities_data
		return var_to_bytes(dict)


	static func from_saved(data: PackedByteArray) -> SessionConfig:
		var dict := bytes_to_var(data) as Dictionary
		var session_config = new()

		session_config.game_seed = dict["game_seed"]
		session_config.state = dict["state"]
		session_config.power = dict["power"]
		session_config.entities_data = dict["entities_data"]
		return session_config
