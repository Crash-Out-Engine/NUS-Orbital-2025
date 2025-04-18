class_name MovementEffect extends Effect

func _init(_timer: Timer, _factor: float, _repeat: int) -> void:
	timer = _timer
	factor = _factor
	repeat = _repeat

static func create_freeze(node: Node, duration: float) -> MovementEffect:
	var _timer = Timer.new()
	_timer.wait_time = duration
	node.add_child(_timer)
	return MovementEffect.new(_timer, float("-1.79769e308"), 0)
