class_name ModSlotComp
extends Node
## ModSlotComp overrides the attack_comp's effects.

signal modslots_updated(mods: int, capacity: int)

@export var capacity: int
@export var initial_mods: Array[ModBase]
@export var entity: Node
@export var attack_comp: Node

var _mods: Array[ModBase]
var _readonly_mods: Array[ModBase]

func _ready() -> void:
	assert(is_instance_valid(entity) and entity.get_node_or_null(^"Properties") != null,
			"Entity should have a Properties child node.")
	assert(is_instance_valid(attack_comp) and "effects" in attack_comp,
			"Attack component should have an effects variable.")

	# Workaround to ensure turrets don't share the same array instance.
	_mods = initial_mods.duplicate()
	_handle_mods_changed()

func set_slot(index: int, mod: ModBase) -> void:
	_mods[index] = mod
	_handle_mods_changed()

func get_mods() -> Array[ModBase]:
	return _readonly_mods

func _handle_mods_changed() -> void:
	_readonly_mods = _mods.duplicate()
	_readonly_mods.make_read_only()
	if !is_node_ready():
		await ready
	if !attack_comp.is_node_ready():
		await attack_comp.ready

	var upgrade_mods: Array[UpgradeMod]
	var effect_mods: Array[EffectMod]
	var application_mods: Array # TODO: Implement application mod
	upgrade_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.UPGRADE))
	effect_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.EFFECT))
	application_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.APPLICATION))

	var entity_properties := entity.get_node(^"Properties").get_children()
	for upgrade in UpgradeMod.compile_upgrades(upgrade_mods):
		for prop_node in entity_properties:
			upgrade.apply_upgrade(prop_node)

	var effects := EffectMod.compile_effects(effect_mods)
	attack_comp.effects.assign(effects)

	if "application_mods" in attack_comp:
		attack_comp.application_mods.assign(application_mods)

	modslots_updated.emit(_mods.size(), capacity)

func change_capcity(value: int):
	capacity += value
	modslots_updated.emit(_mods.size(), capacity)
