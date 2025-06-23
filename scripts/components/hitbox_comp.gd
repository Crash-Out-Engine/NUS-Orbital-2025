class_name HitboxComp
extends Node

@export var team: Enums.Team


func trigger(effect: EffectBase, source: Node2D = null) -> void:
	for prop_node in $"../../Properties".get_children():
		effect.apply_effect(prop_node, source)


func is_targeted_by(target_filter: TargetFilter):
	return team in target_filter.targets
