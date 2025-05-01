class_name TargetProvider extends Resource

var _get_entities: Callable = func(): return []

var entities_cache: Dictionary[String, Array] = {}

func set_get_entities(get_entities: Callable) -> void:
	_get_entities = get_entities
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
	var valid_entities = (_get_entities
		.call()
		.get_children()
		.filter(func(entity):
			return (entity is Node2D and
				entity.get_node_or_null(^"TargetPriority") != null and
				entity.get_node_or_null(^"TargetPriority").team != null
				)
			)
		)
	
	for entity in valid_entities:
		var entity_priority: TargetPriority = entity.get_node_or_null(^"TargetPriority")
		entities_cache.get_or_add(entity_priority.team, []).append(entity)
