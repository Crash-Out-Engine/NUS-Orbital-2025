class_name HealthProp
extends PropertyBase

signal just_emptied
signal just_reduced(by: float)
signal just_changed(old_value: float, new_value: float)

@export var health_capacity: float = 20.0;

var _health_emptied: bool
var _prev_value: float


func _ready() -> void:
	value = health_capacity
	_prev_value = value
	_health_emptied = false


func _physics_process(_delta: float) -> void:
	if value <= 0 and !_health_emptied:
		just_emptied.emit()
		_health_emptied = true

	if value != _prev_value and !_health_emptied:
		just_reduced.emit(_prev_value - value)
		just_changed.emit(_prev_value, value)

	_prev_value = value
