class_name Destroyable
extends Effectable

@export var lives: int

func _ready() -> void:
	value = lives

func try_die() -> bool:
	value -= 1
	return value <= 0
