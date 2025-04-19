class_name Effect extends Node

@export var timer: Timer
@export var factor: float
@export var repeat: int

var _counter: int

func _can_effect(_property: Effectable) -> bool:
	return false
	
func _apply_effect(property: Effectable) -> void:
	if _can_effect(property):
		if timer != null:
			property.get_parent().add_child(timer)
		
		var actual_factor = -property.value if property.value + factor < 0 else factor
		if repeat == 0:
			property.value += actual_factor
			if timer != null:
				timer.stop()
				timer.one_shot = true
				timer.timeout.connect(
					func():
						if property != null:
							property.value -= actual_factor
						)
				timer.start()
		
		elif timer == null:
			return
				
		else: # effect.repeat != 0 and effect.timer != null
			_counter = repeat
			timer.stop()
			timer.one_shot = false
			timer.timeout.connect(
				func():
					if _counter == 0 or property == null:
						timer.one_shot = true
						timer.stop()
					else:
						property.value += actual_factor
						property.value = max(property.value, 0)
						_counter -= 1
					)
			timer.start()
