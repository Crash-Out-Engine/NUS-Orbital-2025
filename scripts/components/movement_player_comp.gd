class_name MovementPlayerComp
extends MovementBaseComp


func _physics_process(delta: float) -> void:
	if entity.is_multiplayer_authority():
		movement_direction = Vector2(
				Input.get_axis("left", "right"),
				Input.get_axis("up", "down")
			).normalized()
	super._physics_process(delta)
