class_name MultiplayerManager
extends Node

const DEFAULT_PORT := 8899
const MAX_PLAYER_COUNT := 5
const _PLAYER_SCENE := preload("res://scenes/player.tscn")
const _GAME_SCENE := preload("res://scenes/game.tscn")

var player_count: int = 1
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


func start_game_for_all() -> void:
	_world_seed = randi() # TODO: Add menu to regenerate seed.
	_start_game.rpc()


@rpc("any_peer", "call_local", "reliable")
func _start_game() -> void:
	var game = _GAME_SCENE.instantiate()
	game.multiplayer_manager = self
	add_child(game)


func _connected(id: int) -> void:
	print("someone %s joined, I'm %s" % [id, multiplayer.get_unique_id()])
	if is_multiplayer_authority():
		player_count += 1


func _disconnected(id: int) -> void:
	print("someone %s disconnected, I'm %s" % [id, multiplayer.get_unique_id()])
	if is_multiplayer_authority():
		player_count -= 1


func _server_connected() -> void:
	pass


func _server_connection_failed() -> void:
	pass


func _server_disconnected() -> void:
	pass
