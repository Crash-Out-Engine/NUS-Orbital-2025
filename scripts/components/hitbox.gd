class_name Hitbox extends Node

func trigger(effect: Effect, source: Node2D = null) -> void:
	for node in get_parent().get_children():
		if node is Effectable:
			effect._apply_effect(node)
	if(effect is HealthEffect and source != null):
		get_parent().get_knockedback(source)
