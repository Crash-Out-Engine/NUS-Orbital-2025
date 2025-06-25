class_name SizeProp
extends PropertyBase

const MIN_SIZE: float = 0.1
const GROWTH_SPEED: float = 1.0

@export var _size: float = 1.0

@onready var _entity = $"../.." as Node2D

func _ready() -> void:
	changed.connect(_handle_size_changed)
	min_value = MIN_SIZE
	value = _size


func _handle_size_changed(_from, to: float) -> void:
	_entity.scale = to * Vector2.ONE
	