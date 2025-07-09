class_name SpreadProp
extends PropertyBase
## Defined as the atan value of an angle from a center line, where said angle
## denotes the spread angle.

@export var _spread: float = 1.0

var _atan_angle: float

func _ready() -> void:
	changed.connect(func(_from, to): _atan_angle = 2 * atan(to))
	min_value = 0
	value = _spread


func get_angle() -> float:
	return _atan_angle
