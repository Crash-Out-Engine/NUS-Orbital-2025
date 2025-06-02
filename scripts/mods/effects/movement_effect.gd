class_name MovementEffect
extends EffectBase
## A MovementEffect should be applied to MovementProp.


func _can_effect(property: PropertyBase) -> bool:
	return property is MovementProp
