class_name RangedAI
extends RangedBase

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")

@onready var has_gun_anim = has_node('GunSprite')
@onready var has_gun_sound = has_node('GunSound')


func _ready() -> void:
	if has_gun_anim:
		bullet_spawned.connect(animate_fire)
	if has_gun_sound:
		bullet_spawned.connect(play_fire)


func play_idle() -> void:
	if(has_gun_anim):
		$GunSprite.play("idle")


func _physics_process(_delta: float) -> void:
	if !active or !ranged_cooldown.can_ranged():
		play_idle()
		return
	
	var team = ""
	if target_priority != null:
		team = target_priority.team
	var target_provider := load("res://resources/target_provider.tres") as TargetProvider
	var target = target_provider.get_target(get_parent().global_position, team)
	if target == null:
		play_idle()
		return
	if has_gun_anim:
		look_at(target.global_position)
		$GunSprite.flip_v = target.global_position < global_position
	
	var bullet: Bullet = _BULLET_SCENE.instantiate()
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


func play_fire(_bullet):
	$GunSound.play()
