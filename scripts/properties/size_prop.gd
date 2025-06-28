class_name SizeProp
extends PropertyBase

const MIN_SIZE: float = 0.1

@export var _size: float = 1.0
## If set to true, SizeProp will automatically resize entity's children when changed.
@export var _auto: bool = true

@onready var _entity = $"../.." as Node2D

func _ready() -> void:
	min_value = MIN_SIZE
	value = _size
	if _auto:
		changed.connect(change_entity_size)


func change_entity_size(from: float, to: float, duration: float = 0.0) -> void:
	var time_passed := 0.0

	while time_passed < duration:
		await get_tree().process_frame
		time_passed += get_process_delta_time()
		for child in _entity.get_children():
			if child is Node2D:
				child.scale = (
						lerp(from, to * Vector2.ONE, clampf(time_passed / duration, 0.0, 1.0)))

	for child in _entity.get_children():
		if child is Node2D:
			child.scale = to * Vector2.ONE
