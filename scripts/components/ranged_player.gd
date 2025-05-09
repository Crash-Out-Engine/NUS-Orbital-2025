class_name RangedPlayer extends RangedBase

var _bullet_scene = preload("res://scenes/bullet.tscn")

@onready var gun_anim = $GunSprite

func _ready() -> void:
	bullet_spawned.connect(animate_fire)

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	gun_anim.flip_v = get_global_mouse_position().x < global_position.x
	gun_anim.offset.y = -1 if (get_global_mouse_position().x < global_position.x) else 1
	
	if !active or !ranged_cooldown.can_ranged():
		return
	
	var team = ""
	
	if target_priority != null:
		team = target_priority.team
	
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
	bullet.direction = global_position.angle_to_point(get_global_mouse_position())
	
	ranged_cooldown.do_ranged()
	
	bullet_spawned.emit(bullet)

func animate_fire(_bullet):
	gun_anim.sprite_frames.set_animation_speed("fire", 4.0 / ranged_cooldown.value)
	gun_anim.play("fire")
