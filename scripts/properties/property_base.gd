class_name PropertyBase
extends Node
## An abstract base class which specifies properties that can be changed by [class EffectBase]s.

signal changed(from: float, to: float)

## The value that gets changed by any [EffectBase].
var value: float:
	set(_value):
		_value = clampf(_value, min_value, max_value)
		var prev_value = value
		if _value != prev_value:
			value = _value
			changed.emit(prev_value, value)
var min_value: float = - INF
var max_value: float = INF


func _init() -> void:
	assert(get_class() != "PropertyBase",
			"PropertyBase is an abstract base class and cannot be instantiated.")
