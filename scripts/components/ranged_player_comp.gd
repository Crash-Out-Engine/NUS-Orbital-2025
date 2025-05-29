class_name RangedPlayerComp
extends RangedBaseComp

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if !active or !ranged_cooldown.can_ranged():
		return
	
	var bullet: Bullet = _BULLET_SCENE.instantiate()
	bullet.effects.assign(effects)
	bullet.target_filter = target_filter
	bullet.global_position = barrel.global_position
	bullet.direction = global_rotation
	
	ranged_cooldown.do_ranged()
	
	bullet_spawned.emit(bullet)
