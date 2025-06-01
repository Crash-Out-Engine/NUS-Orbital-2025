class_name SabotageProp
extends PropertyBase

@export var sabotaged: float = 1.0;


func _ready() -> void:
	value = sabotaged


func reset() -> void:
	value = 0.0
