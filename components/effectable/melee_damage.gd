class_name MeleeDamage extends Effectable

@export var damage: float = 20.0

func _ready() -> void:
	value  = damage

func get_effect() -> HealthEffect:
	return HealthEffect.create_instant(value)
