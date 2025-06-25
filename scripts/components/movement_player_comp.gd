class_name MovementPlayerComp
extends MovementBaseComp


func _physics_process(delta: float) -> void:
	if not entity.is_multiplayer_authority():
		return
		
	movement_direction = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		).normalized()
	super._physics_process(delta)
