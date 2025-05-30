class_name BuildEffect
extends EffectBase


func _can_effect(property: PropertyBase) -> bool:
	return property is BuildProp
