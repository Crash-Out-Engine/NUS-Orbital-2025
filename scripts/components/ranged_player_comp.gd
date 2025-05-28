class_name RangedPlayerComp
extends RangedBaseComp

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if !active or !ranged_cooldown.can_ranged():
		return
	
	var team = ""
	
	if target_priority != null:
		team = target_priority.team
	
	var bullet: Bullet = _BULLET_SCENE.instantiate()
	bullet.effects.assign(effect_mods
			.map(func(effect_mod: EffectMod): return effect_mod.get_effects())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[])) # TODO: Consider whether to deep copy effects (to preserve them in the event the entity despawns)
	bullet.team = team
	bullet.global_position = barrel.global_position
	bullet.direction = global_rotation
	
	ranged_cooldown.do_ranged()
	
	bullet_spawned.emit(bullet)
