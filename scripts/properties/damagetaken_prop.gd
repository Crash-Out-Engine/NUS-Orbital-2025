class_name DamageTakenProp
extends PropertyBase

signal emptied
signal reduced(by: float)

@export var damage_taken: float = 0.0;
@export var _health_capacity_prop: HealthCapacityProp


func _ready() -> void:
	if _health_capacity_prop != null:
		assert(0 <= damage_taken and damage_taken <= _health_capacity_prop.value,
				"Initial health value should be between 0 and health capacity.")
	value = damage_taken
	changed.connect(_check_empty)
	changed.connect(_check_damaged)


func _check_empty(old_value: float, new_value: float) -> void:
	if new_value >= _health_capacity_prop.value and old_value < _health_capacity_prop.value:
		emptied.emit()


func _check_damaged(old_value: float, new_value: float) -> void:
	if new_value > old_value:
		reduced.emit(new_value - old_value)
	if new_value < 0:
		value = 0
