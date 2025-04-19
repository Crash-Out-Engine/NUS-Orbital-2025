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
@export var targeting: Targeting
@export var aim_at_mouse: bool = false
@export var target_priority: TargetPriority = null
@export var effects: Array[Effect] = []

@export var active: bool = false

func _ready() -> void:
	assert(get_parent() is Node2D, "Parent must extend Node2D.")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not get_parent() is Node2D:
		warnings.append("Parent must extend Node2D.")
	if ranged_cooldown == null:
		warnings.append("Ranged Cooldown must be specified.")
	if barrel == null:
		warnings.append("Barrel must be specified.")
	return warnings

func _physics_process(_delta: float) -> void:
	var target = targeting.get_target(get_parent().global_position, target_priority.team if target_priority != null else "") if targeting != null else null
	if active and (target != null or aim_at_mouse) and ranged_cooldown.try_ranged():
		var bullet = bullet_scene.instantiate()
		bullet.effects.append_array(effects)
		bullet.team = target_priority.team if target_priority != null else ""
		bullet.global_position = barrel.global_position
		bullet.direction = get_parent().global_position.angle_to_point(
			get_global_mouse_position() if aim_at_mouse else target.global_position
			)
		bullet.direction = (get_parent().global_position.angle_to_point(get_global_mouse_position())
			if aim_at_mouse else
			barrel.global_position.angle_to_point(target.global_position))

		$/root/Game.add_child(bullet)
