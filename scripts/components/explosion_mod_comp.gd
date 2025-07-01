class_name ExplosionModComp
extends Node

@export var mods: Array[ModBase]
@export var explosion: Explosion

func _ready() -> void:
	assert(is_instance_valid(explosion) and explosion.has_node(^"Properties"),
			"Entity should have a Properties child node.")

func setup_mods() -> void:
	if !is_node_ready():
		await ready

	var upgrade_mods: Array[UpgradeMod]
	var behavioural_mods: Array # TODO: Implement behavioural mod
	upgrade_mods.assign(
			mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.UPGRADE))
	behavioural_mods.assign(
			mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.BEHAVIOURAL))

	var explosion_properties := explosion.get_node(^"Properties").get_children()
	for upgrade in UpgradeMod.compile_upgrades(upgrade_mods, Upgrade.Target.EXPLOSION):
		for prop_node in explosion_properties:
			upgrade.apply_upgrade(prop_node)
