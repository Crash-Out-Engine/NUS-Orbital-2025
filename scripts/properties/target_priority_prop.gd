class_name TargetPriorityProp
extends PropertyBase

@export var initial_priority: float = 1.0
@export var team: String


func _ready() -> void:
	value = initial_priority
