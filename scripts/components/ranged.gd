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
@export var aim_at_mouse: bool = false
@export var target_priority: TargetPriority = null
@export var effect_mods: Array[EffectMod] = []
@export var active: bool = false

signal bullet_spawned(bullet: Node2D)

func _ready() -> void:
	var parent = get_parent()
	assert(parent is Node2D, "Parent must extend Node2D.")
	assert(
		parent.get_property_list().any(func (x): return x["name"] == "target_provider"),
		"Parent must have property target_provider: TargetProvider.")

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
	var target_provider: TargetProvider = get_parent().target_provider
	var target = target_provider.get_target(get_parent().global_position, target_priority.team if target_priority != null else "") if target_provider != null else null
	if active and (target != null or aim_at_mouse) and ranged_cooldown.try_ranged():
		var bullet: Bullet = bullet_scene.instantiate()
		bullet.effects.assign(
			effect_mods
			.map(func (effect_mod: EffectMod): return effect_mod.get_effects())
			.reduce(func(acc, e): 
				acc.append_array(e)
				return acc,
				[])) # TODO: Consider whether to deep copy effects (to preserve them in the event the entity despawns)
		bullet.team = target_priority.team if target_priority != null else ""
		bullet.global_position = barrel.global_position
		bullet.direction = get_parent().global_position.angle_to_point(
			get_global_mouse_position() if aim_at_mouse else target.global_position
			)
		bullet.direction = (get_parent().global_position.angle_to_point(get_global_mouse_position())
			if aim_at_mouse else
			barrel.global_position.angle_to_point(target.global_position))

		bullet_spawned.emit(bullet)
