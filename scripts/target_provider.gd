class_name TargetProvider extends Resource

var _entity_container: Node = null

var entities_cache: Dictionary[String, Array] = {}

func set_entity_container(entity_container: Node) -> void:
	_entity_container = entity_container
	_entity_container.child_order_changed.connect(refresh)
	refresh()

func get_target(from: Vector2, team: String) -> Node2D:
	var min_target: Node2D = null
	var min_weightage: float = INF
	
	var not_teams = entities_cache.keys().filter(func(t): return t != team)
	for not_team in not_teams:
		for target in entities_cache.get(not_team):
			if target != null:
				var target_priority = target.get_node_or_null(^"TargetPriority")
				var weightage = 1.0 / target_priority.value * from.distance_squared_to(target.global_position)
				if min_target == null or min_weightage > weightage:
					min_target = target
					min_weightage = weightage
				
	return min_target

func refresh() -> void:
	entities_cache.clear()
	var valid_entities = (_entity_container
		.get_children()
		.filter(func(entity):
			return (entity is Node2D and
				entity.get_node_or_null(^"TargetPriority") != null and
				entity.get_node_or_null(^"TargetPriority").team != null and
				(!"turret_active" in entity or entity.turret_active)
				)
			)
		)
	
	for entity in valid_entities:
		var entity_priority: TargetPriority = entity.get_node_or_null(^"TargetPriority")
		entities_cache.get_or_add(entity_priority.team, []).append(entity)
