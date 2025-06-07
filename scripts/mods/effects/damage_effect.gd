class_name DamageEffect
extends EffectBase


func _can_effect(property: PropertyBase) -> bool:
	return property is DamageTakenProp
