class_name TargetProvider
extends Resource

var _entity_container: Node = null
var _entities_cache: Dictionary[Enums.Team, Array] = {}


func set_entity_container(entity_container: Node) -> void:
	_entity_container = entity_container
	_entity_container.child_order_changed.connect(refresh)
	refresh()


func get_target(from: Vector2, target_filter: TargetFilter) -> Node2D:
	var min_target: Node2D = null
	var min_weightage: float = INF

	for targeted_team in target_filter.targets:
		for target in _entities_cache.get(targeted_team, []):
			if target != null:
				var target_priority = target.get_node_or_null(^"Properties/TargetPriorityProp")
				var weightage = 1.0 / target_priority.value * from.distance_squared_to(target.global_position)
				if min_target == null or min_weightage > weightage:
					min_target = target
					min_weightage = weightage

	return min_target


func refresh() -> void:
	_entities_cache.clear()
	var valid_entities = (_entity_container
		.get_children()
		.filter(func(entity):
				return (entity is Node2D
						and entity.get_node_or_null(^"Components/HitboxComp") != null
						and entity.get_node(^"Components/HitboxComp").team != null)))

	for entity in valid_entities:
		var entity_team: Enums.Team = entity.get_node(^"Components/HitboxComp").team
		_entities_cache.get_or_add(entity_team, []).append(entity)
