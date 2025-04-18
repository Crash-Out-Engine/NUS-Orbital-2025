class_name MovementEffect extends Effect

func _init(timer: Timer, factor: float, repeat: int) -> void:
	self.timer = timer
	self.factor = factor
	self.repeat = repeat

static func create_freeze(node: Node, duration: float) -> MovementEffect:
	var timer = Timer.new()
	timer.wait_time = duration
	node.add_child(timer)
	return MovementEffect.new(timer, float("-1.79769e308"), 0)
