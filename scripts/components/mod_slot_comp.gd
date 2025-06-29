class_name ModSlotComp
extends Node
## ModSlotComp overrides the attack_comp's effects.

signal updated(size: int, capacity: int)

@export var initial_capacity: int
@export var initial_mods: Array[ModBase]
@export var entity: Node
@export var attack_comp: Node

var upgrade_cost: int = 100
var _capacity: int
var _mods: Array[ModBase]
var _readonly_mods: Array[ModBase]

func _ready() -> void:
	_capacity = initial_capacity
	assert(is_instance_valid(entity) and entity.has_node(^"Properties"),
			"Entity should have a Properties child node.")
	assert(is_instance_valid(attack_comp) and "effects" in attack_comp,
			"Attack component should have an effects variable.")

	# Workaround to ensure turrets don't share the same array instance.
	_mods = initial_mods.duplicate()
	_setup_mods()


func get_mods() -> Array[ModBase]:
	return _readonly_mods


func get_capacity() -> int:
	return _capacity


func is_full() -> bool:
	return _mods.size() == _capacity


func increment_capacity() -> void:
	_synced_increment_capacity.rpc()

func get_upgrade_cost() -> int:
	return upgrade_cost

func add_mod(mod: ModBase) -> bool:
	if is_full():
		return false

	_synced_add_mod.rpc(mod.save())
	return true

func remove_mod(mod: ModBase) -> bool:
	if not mod in _mods:
		return false

	_synced_remove_mod.rpc(mod.save())
	return true


func _setup_mods() -> void:
	_readonly_mods = _mods.duplicate()
	_readonly_mods.make_read_only()
	if !is_node_ready():
		await ready
	if !attack_comp.is_node_ready():
		await attack_comp.ready

	var upgrade_mods: Array[UpgradeMod]
	var effect_mods: Array[EffectMod]
	var behavioural_mods: Array # TODO: Implement behavioural mod
	upgrade_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.UPGRADE))
	effect_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.EFFECT))
	behavioural_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.BEHAVIOURAL))

	var entity_properties := entity.get_node(^"Properties").get_children()
	for upgrade in UpgradeMod.compile_upgrades(upgrade_mods, Upgrade.Target.ENTITY):
		for prop_node in entity_properties:
			upgrade.apply_upgrade(prop_node)

	var effects := EffectMod.compile_effects(effect_mods)
	attack_comp.effects.assign(effects)

	if "behavioural_mods" in attack_comp:
		attack_comp.behavioural_mods.assign(behavioural_mods)

	attack_comp.mods = _mods
	updated.emit(_mods.size(), _capacity)


func _cleanup_mods() -> void:
	var upgrade_mods: Array[UpgradeMod]
	var effect_mods: Array[EffectMod]
	var behavioural_mods: Array # TODO: Implement behavioral mod
	upgrade_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.UPGRADE))
	effect_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.EFFECT))
	behavioural_mods.assign(
			_mods.filter(func(mod): return mod != null and mod.type == ModBase.Type.BEHAVIOURAL))

	var entity_properties := entity.get_node(^"Properties").get_children()
	for upgrade in UpgradeMod.compile_upgrades(upgrade_mods, Upgrade.Target.ENTITY):
		for prop_node in entity_properties:
			upgrade.unapply_upgrade(prop_node)

	var effects := EffectMod.compile_effects(effect_mods)
	attack_comp.effects.assign([])

	if "behavioural_mods" in attack_comp:
		attack_comp.behavioural_mods.assign(behavioural_mods)

	attack_comp.mods = _mods
	updated.emit(_mods.size(), _capacity)


#region Sync

@rpc("any_peer", "call_local", "reliable")
func _synced_increment_capacity() -> void:
	_capacity += 1
	upgrade_cost *= 2
	updated.emit(_mods.size(), _capacity)


@rpc("any_peer", "call_local", "reliable")
func _synced_add_mod(mod_data: PackedByteArray) -> void:
	var mod = ModBase.from_saved(mod_data)

	_cleanup_mods()
	_mods.append(mod)
	_setup_mods()
	updated.emit(_mods.size(), _capacity)


@rpc("any_peer", "call_local", "reliable")
func _synced_remove_mod(mod_data: PackedByteArray) -> void:
	var mod = ModBase.from_saved(mod_data)

	_cleanup_mods()
	_mods.erase(mod)
	_setup_mods()
	updated.emit(_mods.size(), _capacity)

#endregion
