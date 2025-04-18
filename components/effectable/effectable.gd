class_name Effectable extends Node

var effects: Array[Effect] = []

var value

var _counter: int

func _should_be_effected(_effect: Effect) -> bool:
	return false
	
func _apply_effect(effect: Effect) -> void:
	if _should_be_effected(effect):
		var actual_factor = -value if value + effect.factor < 0 else effect.factor
		if effect.repeat == 0:
			value += actual_factor
			if effect.timer != null:
				effect.timer.stop()
				effect.timer.one_shot = true
				effect.timer.timeout.connect(
					func():
						value -= actual_factor
						)
				effect.timer.start()
		
		elif effect.timer == null:
			return
				
		else: # effect.repeat != 0 and effect.timer != null
			_counter = effect.repeat
			effect.timer.stop()
			effect.timer.one_shot = false
			effect.timer.timeout.connect(
				func():
					if _counter == 0:
						effect.timer.one_shot = true
						effect.timer.stop()
					else:
						value += actual_factor
						value = max(value, 0)
						_counter -= 1
					)
			effect.timer.start()
