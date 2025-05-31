class_name LivesProp
extends PropertyBase

@export var lives: int


func _ready() -> void:
	value = lives


func try_die() -> bool:
	value -= 1
	return value <= 0
