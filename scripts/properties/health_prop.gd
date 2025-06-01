class_name HealthProp
extends PropertyBase

signal emptied
signal reduced(by: float)

@export var health: float = 20.0;
@export var _health_capacity_prop: HealthCapacityProp


func _ready() -> void:
	if _health_capacity_prop != null:
		assert(0 <= health and health <= _health_capacity_prop.value,
				"Initial health value should be between 0 and health capacity.")
	value = health
	changed.connect(_check_empty)
	changed.connect(_check_reduced)


func _check_empty(old_value: float, new_value: float) -> void:
	if new_value <= 0 and old_value > 0:
		emptied.emit()


func _check_reduced(old_value: float, new_value: float) -> void:
	if old_value > new_value:
		reduced.emit(old_value - new_value)
