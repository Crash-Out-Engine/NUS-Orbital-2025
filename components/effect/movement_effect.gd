## A MovementEffect should be applied to Movement.
class_name MovementEffect extends Effect

func _init(interval: float, repeat: int, factor: float) -> void:
	_interval = interval
	_repeat = repeat
	_factor = factor
	
func _can_effect(property: Effectable) -> bool:
	return property is Movement

static func create_freeze(duration: float) -> MovementEffect:
	return MovementEffect.new(duration, 0, -INF)
