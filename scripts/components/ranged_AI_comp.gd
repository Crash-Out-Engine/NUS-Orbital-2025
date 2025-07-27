class_name RangedAIComp
extends RangedBaseComp

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if !active:
		return

	var target_provider := load("res://resources/target_provider.tres")
	var target = target_provider.get_target($"../..".global_position, target_filter)
	if target == null:
		return

	var motion_tracker := target.get_node(^"MotionTracker") as MotionTracker

	var bullet_speed = Bullet.DEFAULT_SPEED
	var bullet_lifetime = Bullet.DEFAULT_TIMEOUT
	var upgrades = Mod.compile_upgrades(mods, Upgrade.Target.BULLET) as Array[Upgrade]
	for upgrade in upgrades:
		if upgrade._can_upgrade_string("SpeedProp"):
			bullet_speed += upgrade._factor
		if upgrade._can_upgrade_string("TimeoutProp"):
			bullet_lifetime += upgrade._factor
	var predicted_position = _predict_position(motion_tracker.position,
			motion_tracker.velocity, bullet_speed)

	if is_nan(predicted_position.x) or is_nan(predicted_position.y) or (
		predicted_position.distance_to(barrel.global_position) > bullet_speed * bullet_lifetime):
		return # Formula failed or target too far away

	# Ranged now has a valid target and can fire.
	look_at(predicted_position)
	activate()


func _predict_position(target_pos: Vector2, target_vel: Vector2, bullet_speed: float) -> Vector2:
	var bullet_pos = barrel.global_position
	var a = target_vel.length_squared() - bullet_speed ** 2
	var b = 2 * target_vel.dot(target_pos - bullet_pos)
	var c = (target_pos - bullet_pos).length_squared()
	var t = (-b - sqrt(b ** 2 - 4 * a * c)) / (2 * a)

	return target_pos + target_vel * t
