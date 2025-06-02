class_name RangedBaseComp
extends Node2D

signal bullet_spawned(bullet: Node2D)

@export var active: bool = false
@export var barrel: Node2D
@export var ranged_cooldown: RangedCooldownProp
@export var target_filter: TargetFilter
@export var effects: Array[EffectBase] = []


func _init() -> void:
	assert(get_class() != "RangedBaseComp",
			"RangedBaseComp is an abstract base class and cannot be instantiated.")


func _ready() -> void:
	var parent = $"../../"
	assert(parent is Node2D, "Grandparent must extend Node2D.")
	assert(ranged_cooldown != null, "Ranged Cooldown must be specified.")
	assert(barrel != null, "Barrel must be specified.")
