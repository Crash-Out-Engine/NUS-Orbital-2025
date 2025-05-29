class_name SabotageEffect
extends EffectBase

func _can_effect(property: PropertyBase) -> bool:
	return property is SabotageProp
