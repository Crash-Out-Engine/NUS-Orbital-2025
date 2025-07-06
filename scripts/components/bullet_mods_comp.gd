class_name BulletModsComp
extends Node

@export var mods: Array[ModBase]
@export var bullet: Bullet

func _ready() -> void:
	assert(is_instance_valid(bullet) and bullet.has_node(^"Properties"),
			"Entity should have a Properties child node.")

func setup_mods() -> void:
	if !is_node_ready():
		await ready

	var bullet_properties := bullet.get_node(^"Properties").get_children()
	for upgrade in ModBase.compile_upgrades(mods, Upgrade.Target.BULLET):
		for prop_node in bullet_properties:
			upgrade.apply_upgrade(prop_node)
