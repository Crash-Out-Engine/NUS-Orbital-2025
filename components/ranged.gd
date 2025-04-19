class_name Ranged extends Node2D

var bullet_scene = preload("res://scenes/bullet.tscn")

@export var ranged_cooldown: RangedCooldown
@export var ranged_damage: float
@export var barrel: Node2D
@export var group: String

var is_active: bool = false

func set_active(active: bool):
	is_active = active

func _physics_process(delta: float) -> void:
	if is_active and ranged_cooldown.try_ranged():
		var bullet = bullet_scene.instantiate()
		bullet.group = group
		bullet.global_position = barrel.global_position
		bullet.direction = barrel.global_position.angle_to_point(get_global_mouse_position())

		$/root/Game.add_child(bullet)
