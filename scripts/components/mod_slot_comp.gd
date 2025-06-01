class_name ModSlotComp
extends Node
## ModSlotComp overrides the attack_comp's effects.

@export var mods: Array[ModBase]:
	set(value):
		mods = value
		_handle_mods_changed()
@export var entity: Node
@export var attack_comp: Node


func _ready() -> void:
	assert(is_instance_valid(entity) and entity.get_node_or_null(^"Properties") != null,
			"Entity should have a Properties child node.")
	assert(is_instance_valid(attack_comp) and "effects" in attack_comp,
			"Attack component should have an effects variable.")


func _handle_mods_changed() -> void:
	if !is_node_ready():
		await ready

	var upgrade_mods: Array[UpgradeMod]
	var effect_mods: Array[EffectMod]
	var application_mods: Array # TODO: Implement application mod
	upgrade_mods.assign(mods.filter(func(mod): return mod.type == ModBase.Type.UPGRADE))
	effect_mods.assign(mods.filter(func(mod): return mod.type == ModBase.Type.EFFECT))
	application_mods.assign(mods.filter(func(mod): return mod.type == ModBase.Type.APPLICATION))

	var entity_properties := entity.get_node(^"Properties").get_children()
	for upgrade in UpgradeMod.compile_upgrades(upgrade_mods):
		for prop_node in entity_properties:
			upgrade.apply_upgrade(prop_node)

	var effects := EffectMod.compile_effects(effect_mods)
	attack_comp.effects.assign(effects)

	if "application_mods" in attack_comp:
		attack_comp.application_mods.assign(application_mods)
