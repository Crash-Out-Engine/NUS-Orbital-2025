## The [Movement] node is responsible for controlling the movement of its parent.
## 
## The parent should extend [CharacterBody2D] to allow movements, and have a
## property [code]direction: (delta: float) -> [Vector2][/code] that specifies 
## its ongoing direction.
class_name Movement extends Effectable

## The initial speed of the entity.
@export var initial_speed: float = 200.0
## The lerp weight between calculated velocity and actual velocity.
## [code]0.0[/code] means to use calculated velocity.
## [code]1.0[/code] means to use actual velocity (i.e. calculated velocity has no effect).
@export var lerp_weight: float = 0.0

@export var is_player: bool = false

func _ready() -> void:
	assert(get_parent() is CharacterBody2D, "Movement's parent should be a CharacterBody2D.")
	#assert(get_parent().direction is Callable, "Movement's parent should have a direction.")
	
	value = initial_speed

func _physics_process(delta: float) -> void:
	var parent: CharacterBody2D = get_parent()
	
	if is_player:
		parent.velocity = parent.direction.call(delta).normalized() * value
		parent.velocity = lerp(parent.velocity, parent.get_real_velocity(), lerp_weight)
	
	else:
		var targeting: Targeting = parent.get_node_or_null(^"Targeting")
		var target_priority: TargetPriority = parent.get_node_or_null(^"TargetPriority")

		if targeting != null and target_priority != null:
			var target = targeting.get_target(parent.global_position, target_priority.team)
			if target != null:
				parent.velocity = parent.global_position.direction_to(target.global_position).normalized() * value
			parent.velocity = lerp(parent.velocity, parent.get_real_velocity(), lerp_weight)
	
	parent.move_and_slide()
