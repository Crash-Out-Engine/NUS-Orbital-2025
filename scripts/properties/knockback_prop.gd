class_name KnockbackProp
extends PropertyBase

@export var knockback: float = 0.0
@export var knockback_resistance_prop: KnockbackResistanceProp

var knockback_direction: Vector2 = Vector2(0, 0)

func _ready() -> void:
	value = knockback
	source_changed.connect(set_knockback_direction)

func _physics_process(delta: float) -> void:
	if value > 0:
		value -= delta * knockback_resistance_prop.value
		if value < 0:
			value = 0.0

func get_knockback() -> Vector2:
	return value * knockback_direction

func set_knockback_direction(source: Node2D):
	var parent := $"../../" as Node2D
	knockback_direction = (parent.global_position - source.global_position).normalized()
