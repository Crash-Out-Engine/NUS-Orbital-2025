class_name SpeedProp
extends PropertyBase

## The initial speed of the entity.
@export var initial_speed: float = 200.0


func _ready() -> void:
	value = initial_speed
	min_value = 0.0
