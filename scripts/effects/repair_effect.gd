class_name RepairEffect
extends EffectBase

func _can_effect(property: PropertyBase) -> bool:
	return property is RepairProp
