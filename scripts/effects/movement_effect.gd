## A MovementEffect should be applied to Movement.
class_name MovementEffect extends Effect
	
func _can_effect(property: Effectable) -> bool:
	return property is Movement
