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

	var explosion_properties := explosion.get_node(^"Properties").get_children()
	for upgrade in ModBase.compile_upgrades(mods, Upgrade.Target.EXPLOSION):
		for prop_node in explosion_properties:
			upgrade.apply_upgrade(prop_node)
