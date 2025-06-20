class_name RangedCooldownEffect
extends EffectBase


func _can_effect(property: PropertyBase) -> bool:
	return property is RangedCooldownProp
