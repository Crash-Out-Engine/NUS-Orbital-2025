class_name RangedAI extends RangedBase

var _bullet_scene = preload("res://scenes/bullet.tscn")

var has_gun_anim

func _ready() -> void:
	has_gun_anim = has_node('GunSprite')
	if(has_gun_anim):
		bullet_spawned.connect(animate_fire)

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
	if(has_gun_anim):
		look_at(target.global_position)
		$GunSprite.flip_v = target.global_position < global_position
	
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

func animate_fire(_bullet):
	$GunSprite.sprite_frames.set_animation_speed("fire", 4.0 / ranged_cooldown.value)
	$GunSprite.play("fire")
