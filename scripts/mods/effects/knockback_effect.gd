class_name KnockbackEffect
extends EffectBase

func _can_effect(property: PropertyBase) -> bool:
	return property is KnockbackProp
