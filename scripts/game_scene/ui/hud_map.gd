extends Control

const _MAP_ICON_SCENE := preload("res://scenes/map_icon.tscn")

@export var map_scale : float

var active: bool = false
var _player: Player
var _entity_manager: EntityManager
var _center: Vector2
var _map_size: Vector2
var _entities_icons: Dictionary[Node2D, Sprite2D] = {}

@onready var map := $Map as Panel


func _ready() -> void:
	_map_size = map.size
	_center = _map_size / Vector2(2, 2)


func setup(player: Player, entity_manager: EntityManager) -> void:
	_entity_manager = entity_manager
	_player = player

	# Ensures that node order is irrelevant to its function.
	_entity_manager.child_entered_tree.connect(setup_icon)
	for entity in _entity_manager.get_children():
		setup_icon(entity)

	active = true


func _process(_delta: float) -> void:
	if active:
		for entity: Node2D in _entities_icons.keys():
			var icon = _entities_icons.get(entity) as MapIcon
			icon.position = _to_map_coord(entity.global_position)
			icon.visible = _is_within_map(icon.position)


func setup_icon(node: Node) -> void:
	if node in _entities_icons:
		return

	if not (node is Player or node is Fault or node is Turret or node is Enemy or node is LootCrate):
		return

	var icon = _MAP_ICON_SCENE.instantiate()

	if node is Player:
		icon.frame = MapIcon.Icon.PLAYER
		icon.z_index = 1
	elif node is Fault:
		icon.frame = MapIcon.Icon.FAULT
	elif node is Turret:
		var icon_map: Dictionary[Turret.State, MapIcon.Icon] = {
				Turret.State.PLANNED: icon.Icon.PLANNED_TURRET,
				Turret.State.OPERATIONAL: icon.Icon.BUILT_TURRET
				}
		var swapper = func(_from, to: Turret.State):
				icon.swap(icon_map.get(to, icon.Icon.EMPTY))
		node.state_changed.connect(swapper)
	elif node is Enemy:
		icon.frame = MapIcon.Icon.ENEMY
	elif node is LootCrate:
		if (node as LootCrate).type == LootCrate.Type.BURIED:
			icon.queue_free()
			return
		icon.frame = MapIcon.Icon.LOOT_CRATE
	else: # Node is not an entity to be mapped.
		assert(false, "This should be unreachable.")

	# Adding icon to map
	map.add_child(_entities_icons.get_or_add(node, icon))

	# Setting up cleanup function
	node.tree_exiting.connect(_cleanup(icon, node))


func _to_map_coord(pos: Vector2) -> Vector2:
	return (pos - _player.global_position) / Vector2(map_scale, map_scale) + _center


func _is_within_map(mapped_pos: Vector2) -> bool:
	return (mapped_pos.x >= 0
			and mapped_pos.x <= _map_size.x
			and mapped_pos.y >= 0
			and mapped_pos.y <= _map_size.y)

func _cleanup(icon: MapIcon, node: Node2D) -> Callable:
	return func():
		icon.queue_free()
		_entities_icons.erase(node)
