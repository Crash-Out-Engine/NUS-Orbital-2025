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
	var motion_tracker := target.get_node(^"MotionTracker") as MotionTracker
	var predicted_position = _predict_position(motion_tracker.position,
			motion_tracker.velocity, Bullet.SPEED)
	look_at(predicted_position)

	var bullet: Bullet = _BULLET_SCENE.instantiate()
	bullet.effects.assign(effects)
	bullet.target_filter = target_filter
	bullet.global_position = barrel.global_position
	bullet.direction = barrel.global_position.angle_to_point(predicted_position)

	ranged_cooldown.do_ranged()
	bullet_spawned.emit(bullet)


func _predict_position(target_pos: Vector2, target_vel: Vector2, bullet_speed: float) -> Vector2:
	var bullet_pos = barrel.global_position
	var a = target_vel.length_squared() - bullet_speed ** 2
	var b = 2 * target_vel.dot(target_pos - bullet_pos)
	var c = (target_pos - bullet_pos).length_squared()
	var t = (-b - sqrt(b ** 2 - 4 * a * c)) / (2 * a)

	return target_pos + target_vel * t
