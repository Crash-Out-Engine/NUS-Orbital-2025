class_name MovementPlayerComp
extends MovementBaseComp


func _physics_process(delta: float) -> void:
	if not entity.is_multiplayer_authority():
		return

	super._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	var actions: Array[String] = ["left", "right", "up", "down"]

	if actions.any(func(action): return event.is_action(action)):
		movement_direction = Vector2(
				Input.get_axis("left", "right"),
				Input.get_axis("up", "down")
				).normalized()
