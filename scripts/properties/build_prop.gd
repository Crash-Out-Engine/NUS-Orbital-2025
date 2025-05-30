class_name BuildProp
extends PropertyBase

signal just_changed(new_value: float)

@export var repair_progress: float = 0.0;

var _prev_value: float

func _ready() -> void:
	value = repair_progress
	_prev_value = value


func _physics_process(_delta: float) -> void:
	if value != _prev_value:
		just_changed.emit(value)
	_prev_value = value

func reset() -> void:
	value = 0
	_prev_value = 0
