class_name RepeatProp
extends PropertyBase

@export var repetitions: int = 1


func _ready() -> void:
	value = repetitions


func check_empty() -> bool:
	value -= 1
	return value <= 0
