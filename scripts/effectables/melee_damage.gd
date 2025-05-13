class_name MeleeDamage extends Effectable

@export var damage: float = 20.0

func _ready() -> void:
	value = damage

func get_effect() -> Effect:
	var effect = load("res://resources/effects/health.tres").duplicate()
	effect._change_factor(-damage)
	return effect
