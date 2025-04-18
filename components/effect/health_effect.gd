class_name HealthEffect extends Effect

func _init(timer: Timer, factor: float, repeat: int) -> void:
	self.timer = timer
	self.factor = factor
	self.repeat = repeat

static func create_instant(damage: float = 0.0) -> HealthEffect:
	return HealthEffect.new(null, -damage, 0)

static func create_lasting(body: Node, damage: float, total_duration: float = 0.0, interval: float = 0.0) -> HealthEffect:
	var health_effect = HealthEffect.new(null, -damage, total_duration / interval)
	
	health_effect.timer = Timer.new()
	health_effect.timer.wait_time = interval
	body.add_child(health_effect.timer)
	
	return health_effect
