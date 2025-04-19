class_name HealthEffect extends Effect

func _init(_timer: Timer, _factor: float, _repeat: int) -> void:
	timer = _timer
	factor = _factor
	repeat = _repeat
	
func _can_effect(property: Effectable) -> bool:
	return property is Health

static func create_instant(damage: float = 0.0) -> HealthEffect:
	return HealthEffect.new(null, -damage, 0)

static func create_lasting(damage: float, total_duration: float = 0.0, interval: float = 0.0) -> HealthEffect:	
	var _timer = Timer.new()
	_timer.wait_time = interval
	
	return HealthEffect.new(_timer, -damage, int(total_duration / interval))
