class_name HitboxComp
extends Node

signal hit_by(entity: Node2D, effects: Array[Effect])

@export var _entity: Node2D
@export var team: Enums.Team

@export_group("Components")
@export var movement: MovementBaseComp


func trigger(effects: Array[Effect], by: Node2D) -> void:
	if by.is_multiplayer_authority():
		for effect in effects:
			for prop_node in $"../../Properties".get_children():
				effect.apply_effect(prop_node)
	
		hit_by.emit(by, effects)


func is_targeted_by(target_filter: TargetFilter):
	return team in target_filter.targets


func apply_knockback(from: Vector2) -> void:
	if movement != null:
		movement.apply_knockback(from.direction_to(_entity.global_position))
