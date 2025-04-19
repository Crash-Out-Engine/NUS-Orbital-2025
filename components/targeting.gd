class_name Targeting extends Node

func get_target(from: Vector2, team: String) -> Node2D:
	var min_target: Node2D = null
	var min_weightage: float = INF
	for target in $/root/Game/Enemies.get_children() + $/root/Game/Allies.get_children():
		var target_priority = target.get_node_or_null(^"TargetPriority")
		if target is Node2D and target_priority != null and target_priority.team != team:
			var weightage = target_priority.value * from.distance_squared_to(target.global_position)
			if min_target == null or min_weightage > weightage:
				min_target = target
				min_weightage = weightage
				
	return min_target
