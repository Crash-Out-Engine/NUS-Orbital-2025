## A MovementEffect should be applied to Movement.
class_name MovementEffect extends Effect

func _init(_timer: Timer, _factor: float, _repeat: int) -> void:
	timer = _timer
	factor = _factor
	repeat = _repeat
	
func _can_effect(property: Effectable) -> bool:
	return property is Movement

static func create_freeze(duration: float) -> MovementEffect:
	var _timer = Timer.new()
	_timer.wait_time = duration
	return MovementEffect.new(_timer, -INF, 0)
