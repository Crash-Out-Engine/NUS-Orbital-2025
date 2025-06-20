class_name KnockbackProp
extends PropertyBase

@export var knockback: float = 0.0

var knockback_direction: Vector2 = Vector2(0, 0)

func _ready() -> void:
	value = knockback
	changed.connect(func(_from, _to): set_knockback_direction())

func _physics_process(delta: float) -> void:
	if value > 0:
		value -= delta * 500
		if value < 0:
			value = 0.0

func get_knockback() -> Vector2:
	return value * knockback_direction

func set_knockback_direction():
	var parent := $"../../" as Node2D
	knockback_direction = (parent.global_position - _last_source.global_position).normalized()
