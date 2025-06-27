class_name Game
extends Node2D # TODO: Remember to turn on master volume when releasing

const _PLAYER_SCENE = preload("res://scenes/player.tscn")

signal game_over(message: String) #message contains the cause of the game over

var transitioning: bool
var game_seed: int
var _local_player: Player

@onready var target_provider := load("res://resources/target_provider.tres") as TargetProvider
@onready var entity_manager := $EntityManager as EntityManager
@onready var power_manager := $PowerManager as PowerManager

func _ready() -> void:
	add_players()
	transitioning = true
	await get_tree().process_frame # TODO(multiplayer): Specify load sequences
	power_manager.power_depleted.connect(func():
		end_game("Power has run out")
	)
	target_provider.set_entity_manager(entity_manager)
	$WorldGenSystem.setup(get_seed(), get_local_player())
	$EnemySpawner.setup(get_local_player(), entity_manager)
	$Camera2D.setup(get_local_player())
	$UI/HUDBars.setup(get_local_player(), power_manager)
	$UI/HUDMap.setup(get_local_player(), entity_manager)
	$UI/InventoryUI.setup(get_local_player())
	$UI/DebugPanel.setup(get_local_player())
	

func add_players() -> void:
	if not is_multiplayer_authority():
		return
	
	var peer_player: Dictionary[int, Player] = {}
	var ids = [1]
	ids.append_array(multiplayer.get_peers())
	for i in range(ids.size()):
		var player = _PLAYER_SCENE.instantiate()
		player.position.x += 40 * i # HACK: Should implement proper collision detection
		var peer = ids[i]
		entity_manager.add_entity(player, self)
		peer_player.set(peer, player)
	
	call_deferred("_register_players", peer_player)


func _register_players(peer_player: Dictionary[int, Player]) -> void:
	var peer_player_path: Dictionary[int, NodePath] = {}
	for peer in peer_player:
		peer_player_path.set(peer, peer_player[peer].get_path())
	_sync_register_players.rpc(peer_player_path)
	

@rpc("any_peer", "call_local", "reliable")
func _sync_register_players(peer_player_path: Dictionary[int, NodePath]) -> void:
	for peer in peer_player_path:
		var player = get_tree().root.get_node(peer_player_path[peer])
		player.set_multiplayer_authority(peer)
		if player.is_multiplayer_authority():
			_local_player = player
		else:
			player.get_node(^"Components").process_mode = Node.PROCESS_MODE_DISABLED


func get_power() -> float:
	return power_manager.get_power()


func end_game(message: String) -> void:
	game_over.emit(message)
	power_manager.active = false
	for entity in entity_manager.get_children():
		if entity.has_method("deactivate"):
			entity.deactivate()


func get_local_player() -> Player:
	assert(_local_player != null, "Player should not be null.")
	return _local_player


func get_seed() -> int:
	if game_seed == 0: # TODO(multiplayer): implement seed synchronization
		game_seed = randi()
	return game_seed
