class_name MeleeDamage extends Effectable

@export var damage: float = 20.0

func _ready() -> void:
	value = damage

func get_effect() -> HealthEffect:
	var effect = load("res://resources/effects/health.tres").duplicate()
	effect.factor = -damage
	return effect
