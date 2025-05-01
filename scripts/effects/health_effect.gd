class_name HealthEffect extends Effect

func _init(interval: float, repeat: int, factor: float) -> void:
	_interval = interval
	_repeat = repeat
	_factor = factor
	
func _can_effect(property: Effectable) -> bool:
	return property is Health

static func create_instant(damage: float = 0.0) -> HealthEffect:
	return HealthEffect.new(-1, 0, -damage)

static func create_lasting(damage: float, total_duration: float = 0.0, interval: float = 0.0) -> HealthEffect:	
	return HealthEffect.new(interval, int(total_duration / interval), -damage)
