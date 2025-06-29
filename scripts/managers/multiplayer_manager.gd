class_name MultiplayerManager
extends Node

signal ready_players_changed()
signal server_disconnected()
signal player_disconnected()
signal player_joined()
signal state_changed(from: State, to: State)

enum State {
	DEFAULT,
	HOSTING,
	JOINING,
	JOINED,
	READY,
	ALL_READY,
}

const DEFAULT_PORT := 8899
const MAX_PLAYER_COUNT := 5

var state: State:
	set(value):
		if value != state:
			var prev_state = state
			state = value
			state_changed.emit(prev_state, state)
var ready_players: Dictionary[int, bool] = {}
var _peer: ENetMultiplayerPeer
var _world_seed: int
var _local_player_ready: bool = false


func _ready() -> void:
	multiplayer.connected_to_server.connect(_handle_connected_to_server)
	multiplayer.peer_connected.connect(_handle_peer_connected)
	multiplayer.peer_disconnected.connect(_handle_peer_disconnected)


func set_host() -> bool:
	assert(state in [State.DEFAULT],
			"set_host cannot be called when state is %s." % State.find_key(state))

	_peer = ENetMultiplayerPeer.new()

	var err := _peer.create_server(DEFAULT_PORT, MAX_PLAYER_COUNT - 1)
	if err != OK:
		match err:
			ERR_ALREADY_IN_USE:
				print("Can't host, address in use.")
		return false

	multiplayer.multiplayer_peer = _peer
	ready_players.set(multiplayer.get_unique_id(), false)
	state = State.HOSTING

	return true


func set_client(address: String) -> bool:
	assert(state in [State.DEFAULT],
			"set_client cannot be called when state is %s." % State.find_key(state))

	if not address.is_valid_ip_address():
		print("IP address is invalid.")
		return false

	_peer = ENetMultiplayerPeer.new()
	_peer.create_client(address, DEFAULT_PORT)
	multiplayer.multiplayer_peer = _peer
	state = State.JOINING

	return true


func disconnect_multiplayer() -> void:
	if multiplayer.multiplayer_peer == null or _peer == null:
		return

	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			_peer.disconnect_peer(peer)
	_peer.close()
	multiplayer.multiplayer_peer = null
	ready_players = {}

	state = State.DEFAULT


func set_player_ready() -> void:
	assert(state in [State.DEFAULT, State.HOSTING, State.JOINED],
			"set_client cannot be called when state is %s." % State.find_key(state))

	_local_player_ready = true
	_register_player_ready.rpc_id(1, multiplayer.get_unique_id())
	_peer.refuse_new_connections = true
	state = State.READY


func start_game_for_all() -> void:
	var session_config = Game.SessionConfig.new()
	session_config.game_seed = randi() # TODO: Add menu to regenerate seed.
	_start_game.rpc(session_config.save())


func get_ready_count() -> int:
	return ready_players.values().filter(func(flag): return flag).size()

func get_player_count() -> int:
	return ready_players.size()


func get_seed() -> int:
	return _world_seed


@rpc("any_peer", "call_local", "reliable")
func _register_player_ready(id: int) -> void:
	if not is_multiplayer_authority():
		return

	ready_players[id] = true
	_synced_ready_players.rpc(ready_players)


@rpc("any_peer", "call_local", "reliable")
func _synced_ready_players(_ready_players: Dictionary[int, bool]) -> void:
	ready_players = _ready_players
	ready_players_changed.emit()

	if get_ready_count() == get_player_count():
		state = State.ALL_READY


@rpc("any_peer", "call_local", "reliable")
func _start_game(session_config_data: PackedByteArray) -> void:
	Functions.load_screen_to_scene("res://scenes/game.tscn",
			{"session_config_data": session_config_data})


func _handle_connected_to_server() -> void:
	assert(state in [State.JOINING],
			"set_client cannot be called when state is %s." % State.find_key(state))

	state = State.JOINED


func _handle_peer_connected(id: int) -> void:
	print("%s joined, I'm %s" % [id, multiplayer.get_unique_id()])
	if is_multiplayer_authority():
		ready_players.set(id, false)
		for player in ready_players:
			ready_players.set(player, false)
		_synced_ready_players.rpc(ready_players)
	player_joined.emit()
	_peer.refuse_new_connections = false
	state = State.HOSTING if multiplayer.is_server() else State.JOINED


func _handle_peer_disconnected(id: int) -> void:
	print("%s disconnected, I'm %s" % [id, multiplayer.get_unique_id()])
	if id == 1:
		server_disconnected.emit()
		disconnect_multiplayer()
	else:
		ready_players.erase(id)
		for player in ready_players:
			ready_players.set(player, false)
		_synced_ready_players.rpc(ready_players)
		player_disconnected.emit()
		_peer.refuse_new_connections = false
		state = State.HOSTING if multiplayer.is_server() else State.JOINED
