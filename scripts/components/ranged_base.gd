class_name RangedBase extends Node2D

@export var active: bool = false
@export var ranged_cooldown: RangedCooldown
@export var barrel: Node2D
@export var gunAnim: AnimatedSprite2D
@export var target_priority: TargetPriority = null
@export var effect_mods: Array[EffectMod] = []

signal bullet_spawned(bullet: Node2D)

func _ready() -> void:
	var parent = get_parent()
	assert(parent is Node2D, "Parent must extend Node2D.")
	assert(ranged_cooldown != null, "Ranged Cooldown must be specified.")
	assert(barrel != null, "Barrel must be specified.")
