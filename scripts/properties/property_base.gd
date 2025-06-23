class_name PropertyBase
extends Node
## An abstract base class which specifies properties that can be changed by [class EffectBase]s.

signal changed(from: float, to: float)
signal source_changed(new_source: Node2D)

## The value that gets changed by any [EffectBase].
var value: float:
	set(_value):
		var prev_value = value
		if _value != prev_value:
			value = _value
			changed.emit(prev_value, value)

var _last_source: Node2D = null:
	set(_value):
		var prev_value = _last_source
		if _value != prev_value:
			_last_source = _value
			source_changed.emit(_last_source)

func _init() -> void:
	assert(get_class() != "PropertyBase",
			"PropertyBase is an abstract base class and cannot be instantiated.")
