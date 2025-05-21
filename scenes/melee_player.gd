class_name RangedMelee
extends Melee

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
