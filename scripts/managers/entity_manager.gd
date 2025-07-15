class_name EntityManager
extends MultiplayerSpawner
## Server class.
## [br]
## This class's state includes its children entities.

const _ENTITY_PACKED_SCENE: Dictionary[String, PackedScene] = {
	"Player": preload("res://scenes/player.tscn"),
	"Enemy": preload("res://scenes/enemy.tscn"),
	"Turret": preload("res://scenes/turret.tscn"),
	"Bullet": preload("res://scenes/bullet.tscn"),
	"Explosion": preload("res://scenes/explosion.tscn"),
	"Loot": preload("res://scenes/loot.tscn"),
	"Fault": preload("res://scenes/fault.tscn"),
	"LootCrate": preload("res://scenes/structures/loot_crate.tscn"),
	"Wall": preload("res://scenes/structures/wall.tscn"),
}

@export var _power_manager: PowerManager
@export var _structure_gen_manager: StructureGenManager

## Synced variable to record entity spawn status across clients.
## [br]
## Resets to zero when [method server_remove_entity] is called.
var _entity_count: Dictionary[NodePath, int] = {}

## Local variable to record pending entity loads in clients.
var _load_queue: Dictionary[NodePath, PackedByteArray] = {}


func _ready() -> void:
	assert(!is_multiplayer_authority() or multiplayer.is_server(), "Server should be authority.")
	spawned.connect(_on_remote_spawned)


## Loads an entity to the game based on [param load_data] .
## [br]
## Note: method call will be ignored if [param source] is not authority.
func server_load_entity(entity_type_string: String, load_data: PackedByteArray, source: Node) -> void:
	assert(entity_type_string in _ENTITY_PACKED_SCENE, "\"%s\" is not a valid entity type." % entity_type_string)
	if not source.is_multiplayer_authority():
		return

	if is_multiplayer_authority():
		_server_add_entity(entity_type_string, load_data)
	else:
		_server_add_entity.rpc_id(1, entity_type_string, load_data)


## Adds an [param entity] to the game.
## [br]
## Note: method call will be ignored if [param source] is not authority.
func server_add_entity(entity: Node2D, source: Node) -> void:
	if not source.is_multiplayer_authority():
		return

	if is_multiplayer_authority():
		_add_entity(entity)
	else:
		_server_add_entity.rpc_id(1, entity.get_script().get_global_name(), entity.save_scene())


func server_remove_entity(entity: Node2D) -> void:
	assert(entity in get_children(), "Entity is not a child and cannot be removed.")
	_synced_update_entity_count.rpc(entity.get_path(), true)
	_server_remove_entity.rpc(get_path_to(entity))


func create_entity(entity_type_string: String, load_data) -> Node2D:
	assert(entity_type_string in _ENTITY_PACKED_SCENE, "\"%s\" is not a valid entity type." % entity_type_string)
	var entity = _ENTITY_PACKED_SCENE[entity_type_string].instantiate()
	entity.load_saved_scene(load_data)
	return entity


@rpc("any_peer", "call_local", "reliable")
func _server_add_entity(
		entity_type_string: String,
		data: PackedByteArray,
		) -> void:
	if not is_multiplayer_authority():
		return

	var entity = _ENTITY_PACKED_SCENE[entity_type_string].instantiate()

	entity.load_saved_scene(data)
	_add_entity(entity)


@rpc("any_peer", "call_local", "reliable")
func _server_remove_entity(path: NodePath) -> void:
	var entity = get_node_or_null(path)
	if is_multiplayer_authority() and entity != null:
		entity.queue_free()


func _connect_entity_spawned(entity: Node2D) -> void:
	if !entity.is_inside_tree():
		await entity.tree_entered
	if entity.has_signal("entity_spawned") and entity.is_multiplayer_authority():
		entity.entity_spawned.connect(func(new_entity): server_add_entity(new_entity, entity))


## Used to share load data to [member _load_queue] in clients.
@rpc("authority", "call_remote", "reliable")
func _queue_remote_load(entity_path: NodePath, data: PackedByteArray) -> void:
	_load_queue.set(entity_path, data)


func _add_entity(entity: Node2D) -> void:
	if not is_multiplayer_authority():
		return

	entity.ready.connect(func():
			_synced_update_entity_count.rpc(entity.get_path())
			_queue_remote_load.rpc(entity.get_path(), entity.save_scene())
	)

	call_deferred("add_child", entity, true)
	if entity is Fault:
		_power_manager.register_fault(entity)
	if entity is Player:
		_structure_gen_manager.register_player(entity)
	call_deferred("_connect_entity_spawned", entity)
	MotionTracker.attach_to(entity)


func _on_remote_spawned(node: Node) -> void:
	if node.get_path() in _load_queue:
		node.load_saved_scene(_load_queue[node.get_path()])
		_synced_update_entity_count.rpc(node.get_path())
		_load_queue.erase(node.get_path())

	call_deferred("_connect_entity_spawned", node)


#region Sync

@rpc("any_peer", "call_local", "reliable")
func _synced_update_entity_count(node_path: NodePath, reset: bool = false) -> void:
	_entity_count.set(node_path, 0 if reset else _entity_count.get(node_path, 0) + 1)
	if _entity_count[node_path] == multiplayer.get_peers().size() + 1:
		pass # For any possible setup rpc calls

#endregion


#region Save/load

func save() -> PackedByteArray:
	if not is_multiplayer_authority():
		assert(false, "Method cannot be called at non-authority.")

	var array: Array[PackedByteArray] = []
	for entity in get_children():
		array.append(save_entity(entity))
	return var_to_bytes(array)


func load_saved(data: PackedByteArray) -> void:
	if not is_multiplayer_authority():
		assert(false, "Method cannot be called at non-authority.")

	var array: Array = bytes_to_var(data)
	for entity_data: PackedByteArray in array:
		var entity = entity_from_saved(entity_data)
		server_add_entity(entity, self)


static func save_entity(entity: Node2D) -> PackedByteArray:
	var dict := {}
	dict["entity_type"] = entity.get_script().get_global_name()
	dict["entity.name"] = entity.name
	dict["saved"] = entity.save_scene()
	return var_to_bytes(entity)


static func entity_from_saved(data: PackedByteArray) -> Node2D:
	var dict := bytes_to_var(data) as Dictionary
	var entity_type = dict["entity_type"]
	var entity = _ENTITY_PACKED_SCENE[entity_type].instantiate()
	entity.name = dict["entity.name"]
	entity.load_saved_scene(dict["saved"])
	return entity

#endregion
