class_name MovementEffect
extends EffectBase
## A MovementEffect should be applied to SpeedProp.


func _can_effect(property: PropertyBase) -> bool:
	return property is SpeedProp
