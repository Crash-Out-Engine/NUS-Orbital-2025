## The [Movement] node is responsible for controlling the movement of its parent.
## 
## The parent should extend [CharacterBody2D] to allow movements, and have a
## property [code]direction: (delta: float) -> [Vector2][/code] that specifies 
## its ongoing direction.
class_name Movement extends Effectable

## The initial speed of the entity.
@export var initial_speed: float = 200.0

@export var is_player: bool = false

func _ready() -> void:
	assert(get_parent() is RigidBody2D or (is_player and get_parent() is CharacterBody2D), "Movement's parent should be a RigidBody2D or CharacterBody2D.")
	#assert(get_parent().direction is Callable, "Movement's parent should have a direction.")
	
	value = initial_speed

func _physics_process(delta: float) -> void:
	
	
	if is_player:
		var parent: CharacterBody2D = get_parent()
		parent.velocity = parent.direction.call(delta).normalized() * value
		parent.move_and_collide(parent.velocity * delta)
	
	else:
		var parent: RigidBody2D = get_parent()
		var target_priority: TargetPriority = parent.get_node_or_null(^"TargetPriority")
		var target_provider := load("res://resources/target_provider.tres")

		if target_priority != null:
			var target = target_provider.get_target(parent.global_position, target_priority.team)
			if target != null:
				var impulse = parent.global_position.direction_to(target.global_position).normalized() * parent.mass * value
				parent.apply_central_impulse(impulse - parent.linear_velocity * parent.mass)
	
	
