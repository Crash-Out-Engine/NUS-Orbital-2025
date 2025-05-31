class_name BuildProp
extends PropertyBase

signal just_changed(from: float, to: float)

@export var build_progress: float = 0.0;

var _prev_value: float

func _ready() -> void:
	value = build_progress
	_prev_value = value


func _physics_process(_delta: float) -> void:
	if value != _prev_value:
		print(value)
		just_changed.emit(_prev_value, value)
	_prev_value = value


func reset() -> void:
	value = 0.0
	_prev_value = 0.0
