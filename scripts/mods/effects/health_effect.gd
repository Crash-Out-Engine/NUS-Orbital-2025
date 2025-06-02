class_name HealthEffect
extends EffectBase


func _can_effect(property: PropertyBase) -> bool:
	return property is HealthProp
