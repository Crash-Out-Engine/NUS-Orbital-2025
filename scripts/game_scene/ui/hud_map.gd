extends Control

const MAP_SCALE = Vector2(8.0, 8.0)

@export var player : Player
@export var icon_template : MapIcon
@export var map : Panel

var _center : Vector2
var _map_size: Vector2
var _icons : Array[Sprite2D] = []
var _buildings: Array[Node2D] = []

func _ready() -> void:
	_map_size = map.size
	_center = _map_size / Vector2(2, 2)

func _process(_delta: float) -> void:
	for icon in map.get_children():
		icon.position = to_map_coord(find_reference(icon).global_position)
		icon.visible = within_map(icon.position)

func create_building_icon(node: Node) -> MapIcon:
	var icon = icon_template.duplicate() as MapIcon
	if node is Player:
		icon.frame = 1
		return icon
	if node is Fault:
		icon.frame = 2
		return icon
	if node is Turret:
		icon.frame = 0
		icon.set_map([-1, Turret.State.PLANNED, Turret.State.OPERATIONAL], [0, 3, 4])
		node.state_changed.connect(func(_from, to): icon.swap_icon(to))
		return icon
	return null

func to_map_coord(pos: Vector2) -> Vector2:
	return (pos - player.global_position) / MAP_SCALE + _center

func find_reference(icon: Sprite2D) -> Node2D:
	return _buildings[_icons.find(icon)]

func within_map(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x <= _map_size.x and pos.y >= 0 and pos.y <= _map_size.y

func _on_entity_container_child_entered_tree(node: Node) -> void:
	var icon = create_building_icon(node)
	if icon != null:
		_buildings.append(node)
		map.add_child(icon)
		_icons.append(icon)

func _on_entity_container_child_exiting_tree(node: Node) -> void:
	var i = _buildings.find(node)
	if i >= 0:
		var icon = _icons[i]
		_icons.remove_at(i)
		icon.queue_free()
		_buildings.remove_at(i)
