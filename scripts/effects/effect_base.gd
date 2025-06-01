class_name EffectBase
extends Resource

## Interval between repetitions (if any) in seconds.
## Taken to be equivalent to null if a non-positive value is supplied.
@export var _interval: float
@export var _repeat: int
@export var _factor: float

var _counter: int


func set_factor(value: float) -> void:
	_factor = value


func apply_effect(property: PropertyBase) -> void:
	if _can_effect(property):
		var timer: Timer
		if _interval != null and _interval > 0:
			timer = Timer.new()
			timer.wait_time = _interval
			property.add_child(timer)

		var actual_factor = - property.value if property.value + _factor < 0 else _factor
		if _repeat == 0:
			property.value += actual_factor
			if timer != null:
				timer.stop()
				timer.one_shot = true
				timer.timeout.connect(func():
						if property != null:
							property.value -= actual_factor
				)
				timer.start()

		elif timer == null:
			return

		else: # effect.repeat != 0 and effect.timer != null
			_counter = _repeat
			timer.stop()
			timer.one_shot = false
			timer.timeout.connect(_countdown(timer, property, actual_factor))
			timer.start()


func _can_effect(_property: PropertyBase) -> bool:
	return false


func _countdown(timer: Timer, property: PropertyBase, factor: float) -> Callable:
	return func():
			if _counter == 0 or property == null:
				timer.one_shot = true
				timer.stop()
			else:
				property.value += factor
				property.value = max(property.value, 0)
				_counter -= 1
