class_name RangedAIComp
extends RangedBaseComp

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")


func _physics_process(_delta: float) -> void:
	if !active or !ranged_cooldown.can_ranged():
		return
	
	var target_provider := load("res://resources/target_provider.tres") as TargetProvider
	var target = target_provider.get_target($"../../".global_position, target_filter)
	if target == null:
		return

	# Ranged now has a valid target and can fire.
	look_at(target.global_position)
	
	var bullet: Bullet = _BULLET_SCENE.instantiate()
	bullet.effects.assign(effects)
	bullet.target_filter = target_filter
	bullet.global_position = barrel.global_position
	bullet.direction = barrel.global_position.angle_to_point(target.global_position)
	
	ranged_cooldown.do_ranged()
	bullet_spawned.emit(bullet)
