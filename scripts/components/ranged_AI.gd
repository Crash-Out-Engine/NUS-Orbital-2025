class_name RangedAI extends RangedBase

var _bullet_scene = preload("res://scenes/bullet.tscn")

func _physics_process(_delta: float) -> void:
	if !active or !ranged_cooldown.can_ranged():
		return
	
	var team = ""
	if target_priority != null:
		team = target_priority.team
	var target_provider := load("res://resources/target_provider.tres") as TargetProvider
	var target = target_provider.get_target(get_parent().global_position, team)
	if target == null:
		return
			
	var bullet: Bullet = _bullet_scene.instantiate()
	bullet.effects.assign(
		effect_mods
		.map(func(effect_mod: EffectMod): return effect_mod.get_effects())
		.reduce(func(acc, e):
			acc.append_array(e)
			return acc,
			[])) # TODO: Consider whether to deep copy effects (to preserve them in the event the entity despawns)
	bullet.team = team
	bullet.global_position = barrel.global_position
	bullet.direction = barrel.global_position.angle_to_point(target.global_position)
	
	ranged_cooldown.do_ranged()
	bullet_spawned.emit(bullet)
