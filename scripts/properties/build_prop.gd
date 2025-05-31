class_name BuildProp
extends PropertyBase

@export var build_progress: float = 0.0;


func _ready() -> void:
	value = build_progress


func reset() -> void:
	value = 0.0
