class_name Game
extends Node2D # TODO: Remember to turn on master volume when releasing

const _PLAYER_SCENE := preload("res://scenes/player.tscn")

var multiplayer_manager: MultiplayerManager
#$ Server variable.
var _players: Dictionary[int, Player]
var _local_player: Player

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider


func _ready() -> void:
	target_provider.set_entity_manager($EntityManager)
	if is_multiplayer_authority():
		if multiplayer_manager != null:
			var ids = [1]
			ids.append_array(multiplayer.get_peers()) # FIXME: Too tired to write good code rn.
			for i in range(multiplayer_manager.player_count):
				var player = _PLAYER_SCENE.instantiate()
				player.position.x += 40 * i
				var peer = ids[i]
				$EntityManager.add_entity(player, self)
				_players.set(peer, player)
		else:
			var player = _PLAYER_SCENE.instantiate()
			$EntityManager.add_entity(player, self)
			_players.set(1, player)

		call_deferred("register_players")


@rpc("authority", "call_local", "reliable")
func register_players() -> void:
	var peer_player_path: Dictionary[int, NodePath] = {}
	for peer in _players:
		peer_player_path.set(peer, _players[peer].get_path())
	_register_players.rpc(peer_player_path)


@rpc("any_peer", "call_local", "reliable")
func _register_players(peer_player: Dictionary[int, NodePath]) -> void:
	for peer in peer_player:
		var player = get_tree().root.get_node(peer_player[peer])
		player.set_multiplayer_authority(peer)
		if player.is_multiplayer_authority():
			_local_player = player
		else:
			player.get_node(^"Components").process_mode = Node.PROCESS_MODE_DISABLED


func get_local_player() -> Player:
	assert(_local_player != null, "Local player should not be null.")
	return _local_player


func get_seed() -> int:
	if multiplayer_manager == null:
		return randi()

	return multiplayer_manager.get_seed()
