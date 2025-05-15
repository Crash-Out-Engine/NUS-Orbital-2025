class_name Hitbox
extends Node


func trigger(effect: Effect, source: Node2D = null) -> void:
	for node in get_parent().get_children():
		if node is Effectable:
			effect.apply_effect(node)
	
	if effect is HealthEffect and source != null and get_parent() is Player:
		get_parent().apply_knockback(source)
