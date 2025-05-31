class_name RepairProp
extends PropertyBase

signal just_changed()

var _prev_value: float

func _ready() -> void:
	value = 0.0
	_prev_value = value


func _physics_process(_delta: float) -> void:
	if value != _prev_value:
		just_changed.emit(value > _prev_value)
	_prev_value = value
