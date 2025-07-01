class_name RangedBaseComp
extends Node2D

signal bullet_spawned(bullet: Bullet)

const _BULLET_SCENE = preload("res://scenes/bullet.tscn")

@export var active: bool = false
@export var barrel: Node2D
@export var target_filter: TargetFilter
@export var mods: Array[ModBase]
@export var effects: Array[Effect]

@export_group("Entity nodes")
@export var _entity: Node2D
@export_subgroup("Properties")
@export var _copy_prop: CopyProp
@export var _spread_prop: SpreadProp
@export var _ranged_cooldown_prop: RangedCooldownProp


func _init() -> void:
	assert(get_class() != "RangedBaseComp",
			"RangedBaseComp is an abstract base class and cannot be instantiated.")


func _ready() -> void:
	var parent = $"../../"
	assert(parent is Node2D, "Grandparent must extend Node2D.")
	assert(_ranged_cooldown_prop != null, "Ranged Cooldown Prop must be specified.")
	assert((_copy_prop != null and _spread_prop != null),
			"Copy Prop and Spread Prop must be specified.")
	assert(barrel != null, "Barrel must be specified.")


func activate() -> void:
	if !is_multiplayer_authority():
		return

	if !_ranged_cooldown_prop.can_ranged():
		return
	
	var attack = Attack.from(_entity, effects, target_filter)
	var bullet_count: int = max(1, int(_copy_prop.value) * 2 - 1)
	var interval: float = _spread_prop.get_angle() / (bullet_count - 1) if bullet_count > 1 else 0.0
	var starting_angle: float = (global_rotation
			- (_spread_prop.get_angle() / 2 if bullet_count > 1 else 0.0))
	
	for i in bullet_count:
		var bullet := _BULLET_SCENE.instantiate() as Bullet
		bullet.attack = Attack.from(_entity, effects, target_filter)
		bullet.assign_mods(mods)
		bullet.global_position = barrel.global_position
		bullet.direction = starting_angle + i * interval
		bullet_spawned.emit(bullet)

	_ranged_cooldown_prop.do_ranged()
