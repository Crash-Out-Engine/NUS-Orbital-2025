class_name HitboxComp
extends Node

@export var _entity: Node2D
@export var team: Enums.Team

@export_group("Components")
@export var movement: MovementBaseComp


func trigger(effect: EffectBase, _source: Node2D = null) -> void:
	for prop_node in $"../../Properties".get_children():
		effect.apply_effect(prop_node)


func is_targeted_by(target_filter: TargetFilter):
	return team in target_filter.targets


func apply_knockback(from: Vector2) -> void:
	if movement != null:
		movement.apply_knockback(from.direction_to(_entity.global_position))
