class_name MovementEffect
extends Effect
## A MovementEffect should be applied to Movement.
	

func _can_effect(property: Effectable) -> bool:
	return property is Movement
