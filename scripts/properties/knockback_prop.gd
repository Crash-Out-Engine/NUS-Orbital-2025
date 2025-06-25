class_name KnockbackProp
extends PropertyBase

@export var knockback: float = 0.0

func _ready() -> void:
	value = knockback

func get_knockback() -> float:
	var prev_value = value
	value = 0.0
	return prev_value
