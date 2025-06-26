class_name RangedPlayerComp
extends RangedBaseComp

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")

@export var player: Player


func _physics_process(_delta: float) -> void:
	if !player.hand.locked:
		rotation = player.hand.rotation

	if !active or !ranged_cooldown.can_ranged():
		return

	var interval = spread.value / (bullet_count.value + 1)
	var angle = interval
	for i in bullet_count.value:
		var bullet: Bullet = _BULLET_SCENE.instantiate()
		bullet.effects.assign(effects)
		bullet.assign_mods(mods)
		bullet.target_filter = target_filter
		bullet.global_position = barrel.global_position
		bullet.direction = global_rotation
		bullet.direction += PI * (angle - spread.value / 2) / 180
		angle += interval
		bullet_spawned.emit(bullet)

	ranged_cooldown.do_ranged()
