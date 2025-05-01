class_name HealthEffect extends Effect
	
func _can_effect(property: Effectable) -> bool:
	return property is Health
