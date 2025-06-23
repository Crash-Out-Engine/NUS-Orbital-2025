class_name SizeProp
extends PropertyBase

signal size_changed(value: float)

const MIN_SIZE: float = 0.1
const GROWTH_SPEED: float = 1.0

@export var _size: float = 1.0

func _ready() -> void:
	value = _size
	changed.connect(_check_min)

func _check_min(_old_value: float, new_value: float) -> void:
	if new_value < MIN_SIZE:
		size_changed.emit(MIN_SIZE)
	else:
		size_changed.emit(new_value)
