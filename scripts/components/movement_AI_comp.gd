class_name MovementAIComp
extends MovementBaseComp

@export var target_filter: TargetFilter


func _physics_process(delta: float) -> void:
	var target_provider := load("res://resources/target_provider.tres") as TargetProvider
	var target = target_provider.get_target(entity.global_position, target_filter)
	if target != null:
		movement_direction = entity.global_position.direction_to(target.global_position)
	else:
		movement_direction = Vector2.ZERO

	super._physics_process(delta)
