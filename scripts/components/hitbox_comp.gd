class_name HitboxComp
extends Node


func trigger(effect: EffectBase, source: Node2D = null) -> void:
	for prop_node in $"../../Properties".get_children():
		effect.apply_effect(prop_node)
	
	if effect is HealthEffect and source != null and $"../../" is Player: # HACK: knockback should not be applied manually
		$"../../".apply_knockback(source)
