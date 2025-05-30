extends Control

const MAP_SCALE = Vector2(8.0, 8.0)

@export var player : Player
@export var icon_template : Sprite2D
@export var map : Panel

var _center : Vector2
var _map_size: Vector2
var _icons : Array[Sprite2D] = []
var _buildings: Array[Node2D] = []

func _ready() -> void:
	_map_size = map.size
	_center = _map_size / Vector2(2, 2)
	var player_icon = icon_template.duplicate() as Sprite2D
	player_icon.frame = 0
	player_icon.position = _center
	player_icon.z_index = 1
	player_icon.visible = true
	map.add_child(player_icon)
	_buildings.append(player)
	_icons.append(player_icon)

func _process(_delta: float) -> void:
	for icon in map.get_children():
		icon.position = to_map_coord(find_reference(icon).global_position)
		icon.visible = within_map(icon.position)

func get_building_type(node: Node) -> int: #HACK: Objects in the map should be collected in a group
	if node is Player:
		return 0
	if node is Fault:
		return 1
	if node is Turret:
		return 2
	return -1

func to_map_coord(pos: Vector2) -> Vector2:
	return (pos - player.global_position) / MAP_SCALE + _center

func find_reference(icon: Sprite2D) -> Node2D:
	return _buildings[_icons.find(icon)]

func within_map(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x <= _map_size.x and pos.y >= 0 and pos.y <= _map_size.y

func _on_entity_container_child_entered_tree(node: Node) -> void:
	var i = get_building_type(node)
	if i >= 0:
		_buildings.append(node)
		var icon = icon_template.duplicate() as Sprite2D
		icon.frame = i
		map.add_child(icon)
		_icons.append(icon)

func _on_entity_container_child_exiting_tree(node: Node) -> void:
	var i = _buildings.find(node)
	if i >= 0:
		_icons.remove_at(i)
		_buildings.remove_at(i)
