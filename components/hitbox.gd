class_name Hitbox extends Node

func trigger(effect: Effect) -> void:
	for node in get_parent().get_children():
		if node is Effectable:
			node._apply_effect(effect)
