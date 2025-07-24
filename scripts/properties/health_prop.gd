class_name HealthProp
extends PropertyBase

signal emptied
signal reduced(by: float)

@export var _initial_health: float = 20.0;
@export var _health_capacity_prop: HealthCapacityProp


func _ready() -> void:
	if _health_capacity_prop != null:
		assert(0 <= _initial_health and _initial_health <= _health_capacity_prop._initial_health_capacity,
				"Initial _initial_health value should be between 0 and initial _initial_health capacity")
		max_value = _health_capacity_prop._initial_health_capacity
		min_value = 0.0
		_health_capacity_prop.changed.connect(func(_from, to): max_value = to)
	value = _initial_health
	changed.connect(_check_empty)
	changed.connect(_check_reduced)


func reset() -> void:
	value = _initial_health


func _check_empty(old_value: float, new_value: float) -> void:
	if new_value <= 0 and old_value > 0:
		emptied.emit()


func _check_reduced(old_value: float, new_value: float) -> void:
	if old_value > new_value:
		reduced.emit(old_value - new_value)
