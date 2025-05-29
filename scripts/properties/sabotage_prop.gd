class_name SabotageProp
extends PropertyBase

signal just_changed(new_value: bool)

@export var sabotaged: float = 1.0;

var _prev_value: float

func _ready() -> void:
	value = sabotaged
	_prev_value = value


func _physics_process(_delta: float) -> void:
	if value != _prev_value:
		just_changed.emit(value > _prev_value)
	_prev_value = value

func repair() -> void:
	value = 0.0
