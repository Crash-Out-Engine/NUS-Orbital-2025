@tool
class_name Ranged extends Node2D

var bullet_scene = preload("res://scenes/bullet.tscn")

@export var ranged_cooldown: RangedCooldown:
	set(value):
		ranged_cooldown = value
		update_configuration_warnings()
@export var ranged_damage: float = 0.0
@export var barrel: Node2D:
	set(value):
		barrel = value
		update_configuration_warnings()
@export var target: Node2D
@export var group: String
@export var effects: Array[Effect] = []

var _is_active: bool = false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if ranged_cooldown == null:
		warnings.append("Ranged Cooldown must be specified.")
	if barrel == null:
		warnings.append("Barrel must be specified.")
	return warnings

func set_active(active: bool):
	_is_active = active

func _physics_process(_delta: float) -> void:
	if _is_active and ranged_cooldown.try_ranged():
		var bullet = bullet_scene.instantiate()
		bullet.effects.append_array(effects)
		bullet.group = group
		bullet.global_position = barrel.global_position
		bullet.direction = global_position.angle_to_point(target.global_position if target != null else get_global_mouse_position())

		$/root/Game.add_child(bullet)
