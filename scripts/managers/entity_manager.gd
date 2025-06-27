class_name EntityManager
extends MultiplayerSpawner

const _ENTITY_PACKED_SCENE: Dictionary[String, PackedScene] = {
	"Player": preload("res://scenes/player.tscn"),
	"Enemy": preload("res://scenes/enemy.tscn"),
	"Turret": preload("res://scenes/turret.tscn"),
	"Bullet": preload("res://scenes/bullet.tscn"),
	"Explosion": preload("res://scenes/explosion.tscn"),
	"Loot": preload("res://scenes/loot.tscn"),
	"Fault": preload("res://scenes/fault.tscn"),
}

@export var _power_manager: PowerManager

var _entity_count: Dictionary[NodePath, int] = {}
var _load_queue: Dictionary[NodePath, PackedByteArray] = {}


func add_entity(entity: Node2D, source: Node) -> void:
	if source.is_multiplayer_authority():
		if is_multiplayer_authority():
			_add_entity_in_server(entity)
		else:
			_add_remote_entity.rpc_id(get_multiplayer_authority(),
					entity.get_script().get_global_name(), entity.save_scene())


func remove_entity(entity: Node2D) -> void:
	assert(entity in get_children(), "Entity is not a child and cannot be removed.")
	_sync_increment_entity_count.rpc(entity.get_path(), true)
	_remove_remote_entity.rpc(get_path_to(entity))


@rpc("any_peer", "call_local", "reliable")
func _remove_remote_entity(path: NodePath) -> void:
	var entity = get_node_or_null(path)
	if is_multiplayer_authority() and entity != null:
		entity.queue_free()


func connect_entity_spawned(entity: Node2D) -> void:
	if !entity.is_inside_tree():
		await entity.tree_entered
	if entity.has_signal("entity_spawned") and entity.is_multiplayer_authority():
		entity.entity_spawned.connect(func(new_entity): add_entity(new_entity, entity))


@rpc("any_peer", "call_local", "reliable")
func _add_remote_entity(entity_type_string: String, data: PackedByteArray) -> void:
	if is_multiplayer_authority():
		var entity = _ENTITY_PACKED_SCENE[entity_type_string].instantiate()

		entity.load_saved_scene(data)
		_add_entity_in_server(entity)


@rpc("authority", "call_remote", "reliable")
func _queue_remote_load(entity_path: NodePath, data: PackedByteArray) -> void:
	_load_queue.set(entity_path, data)


func _add_entity_in_server(entity: Node2D) -> void:
	if is_multiplayer_authority():
		entity.ready.connect(func():
				_sync_increment_entity_count.rpc(entity.get_path())
				_queue_remote_load.rpc(entity.get_path(), entity.save_scene())
		)

		call_deferred("add_child", entity, true)
		if entity is Fault:
			_power_manager.register_fault(entity)
		call_deferred("connect_entity_spawned", entity)
		MotionTracker.attach_to(entity)


func _on_remote_spawned(node: Node) -> void:
	if node.get_path() in _load_queue:
		node.load_saved_scene(_load_queue[node.get_path()])
		_sync_increment_entity_count.rpc(node.get_path())
		_load_queue.erase(node.get_path())

	call_deferred("connect_entity_spawned", node)


@rpc("any_peer", "call_local", "reliable")
func _sync_increment_entity_count(node_path: NodePath, reset: bool = false) -> void:
	_entity_count.set(node_path, 0 if reset else _entity_count.get(node_path, 0) + 1)
	if _entity_count[node_path] == multiplayer.get_peers().size() + 1:
		pass # For any possible setup rpc calls
