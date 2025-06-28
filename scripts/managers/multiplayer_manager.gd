class_name MultiplayerManager
extends Node

const DEFAULT_PORT := 8899
const MAX_PLAYER_COUNT := 5

var ready_player_count: int
var _peer: ENetMultiplayerPeer
var _world_seed: int


func _ready() -> void:
	multiplayer.peer_connected.connect(_connected)
	multiplayer.peer_disconnected.connect(_disconnected)
	multiplayer.connected_to_server.connect(_server_connected)
	multiplayer.connection_failed.connect(_server_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)


func set_host() -> bool:
	_peer = ENetMultiplayerPeer.new()

	var err := _peer.create_server(DEFAULT_PORT, MAX_PLAYER_COUNT - 1)
	if err != OK:
		print("Can't host, address in use.")
		return false

	multiplayer.multiplayer_peer = _peer

	return true


func set_client(address: String) -> bool:
	if not address.is_valid_ip_address():
		print("IP address is invalid.")
		return false

	_peer = ENetMultiplayerPeer.new()
	_peer.create_client(address, DEFAULT_PORT)
	multiplayer.multiplayer_peer = _peer

	return true


func disconnect_multiplayer() -> void:
	multiplayer.peer = null


func get_seed() -> int:
	return _world_seed


func player_ready(_id: int) -> void:
	_broadcast_player_ready.rpc()


@rpc("any_peer", "call_local", "reliable")
func _broadcast_player_ready() -> void:
	ready_player_count += 1
	$"..".update_status()

	if is_multiplayer_authority():
		if ready_player_count == multiplayer.get_peers().size() + 1:
			start_game_for_all()


func start_game_for_all() -> void:
	var session_config = Game.SessionConfig.new()
	session_config.game_seed = randi() # TODO: Add menu to regenerate seed.
	_start_game.rpc(session_config.save())


@rpc("any_peer", "call_local", "reliable")
func _start_game(session_config_data: PackedByteArray) -> void:
	Functions.load_screen_to_scene("res://scenes/game.tscn",
			{"session_config_data": session_config_data})


func _connected(id: int) -> void:
	print("%s joined, I'm %s" % [id, multiplayer.get_unique_id()])


func _disconnected(id: int) -> void:
	print("%s disconnected, I'm %s" % [id, multiplayer.get_unique_id()])


func _server_connected() -> void:
	pass


func _server_connection_failed() -> void:
	pass


func _server_disconnected() -> void:
	pass
