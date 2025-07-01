class_name InventoryComp
extends Node
## Inventory component within a player.
##
## This component requires that each distinct [class ModBase] exists as a single
## shared [class Resource] instance across the game, as it matches with the
## object reference of the [class ModBase].

signal scraps_changed(from: int, to: int)
signal slots_updated(size: int, capacity: int)
signal collected_mod(mod: ModBase)

@export var initial_mods: Array[ModBase]
@export var initial_scraps: int

@export var mod_targeting_comp: ModTargetingComp
@export var blueprint_comp: BlueprintComp

## Authority variable.
var _entity: Node2D
## Authority variable.
var _entity_slot: ModSlotComp
## Synced variable.
var _mods: Dictionary[ModBase, int]
## Synced variable.
var _scraps: int:
	set(value):
		var prev_value = _scraps
		if prev_value != value:
			_scraps = value
			scraps_changed.emit(prev_value, value)


func _ready() -> void:
	for mod in initial_mods:
		_local_add_mod(mod)
	_scraps = initial_scraps


func register_item(item: Item):
	Utils.assert_authority(self)
	match item.type:
		Item.Type.SCRAP:
			_synced_set_scraps.rpc(_scraps + (item as Item.ScrapItem).count)
		Item.Type.MOD:
			add_mod((item as Item.ModItem).mod)


## Allows the entity (typically Player) to access another entity's ModSlotComp,
## throws an error if not found.
func access_entity() -> void:
	Utils.assert_authority(self)
	var entity := mod_targeting_comp.get_target()

	assert(entity != null
		and entity.has_node(^"Components/ModSlotComp"),
		"Entity accessed should have ModSlotComp.")

	_entity = entity
	_entity_slot = entity.get_node(^"Components/ModSlotComp")
	_entity_slot.updated.connect(slots_updated.emit)
	slots_updated.emit(_entity_slot.get_mods().size(), _entity_slot.get_capacity())


func unaccess_entity() -> void:
	Utils.assert_authority(self)
	_entity_slot.updated.disconnect(slots_updated.emit)
	_entity = null
	_entity_slot = null


func is_entity_turret() -> bool:
	return _entity is Turret


func disassemble_turret() -> bool:
	Utils.assert_authority(self)
	if is_entity_turret():
		(_entity as Turret).disassemble()
		return true

	return false


func get_mods() -> Dictionary[ModBase, int]:
	var duped_mods = _mods.duplicate()
	duped_mods.make_read_only()
	return duped_mods


func get_scraps() -> int:
	return _scraps


func auth_use_scraps(amount: int) -> void:
	assert(amount >= 0, "Amount used should not be a negative number.")
	_synced_set_scraps(_scraps - amount)


func use_scraps(amount: int) -> void:
	Utils.assert_authority(self)
	assert(amount >= 0, "Amount used should not be a negative number.")
	_synced_set_scraps(_scraps - amount)


func get_blueprints() -> Array[ModBase]:
	return blueprint_comp.get_blueprints()


#region Entity slots

func get_slots_comp() -> ModSlotComp:
	return _entity_slot


func get_slots_mods() -> Array[ModBase]:
	return _entity_slot.get_mods()


func get_slots_upgrade_cost() -> int:
	return _entity_slot.get_upgrade_cost()


func can_upgrade_slots() -> bool:
	return _scraps >= _entity_slot.get_upgrade_cost()


func upgrade_slots() -> bool:
	Utils.assert_authority(self)

	if _scraps < _entity_slot.get_upgrade_cost():
		return false

	_synced_set_scraps.rpc(_scraps - _entity_slot.get_upgrade_cost())
	_entity_slot.increment_capacity()
	return true

#endregion


func equip_mod(mod: ModBase):
	Utils.assert_authority(self)
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")

	assert(not _entity_slot.is_full(),
			"No empty slots left in entity.")

	_mods[mod] -= 1
	_entity_slot.add_mod(mod)


func unequip_mod(mod: ModBase):
	Utils.assert_authority(self)
	assert(mod != null, "Mod not found in entity mod slot.")

	add_mod(mod)
	_entity_slot.remove_mod(mod)


func recycle_mod(mod: ModBase):
	Utils.assert_authority(self)
	_synced_remove_mod(mod.save())
	_synced_set_scraps(_scraps + mod.get_recycle_value())


func add_mod(mod: ModBase) -> void:
	Utils.assert_authority(self)
	_synced_add_mod.rpc(mod.save())


func remove_mod(mod: ModBase) -> void:
	Utils.assert_authority(self)
	assert(mod in _mods and _mods[mod] > 0,
			"Mod not found in inventory.")
	_synced_remove_mod.rpc(mod.save())


func _local_add_mod(mod: ModBase) -> void:
	_mods[mod] = _mods.get_or_add(mod, 0) + 1
	collected_mod.emit(mod)


func _local_remove_mod(mod: ModBase) -> void:
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")
	_mods[mod] -= 1


#region Sync

@rpc("any_peer", "call_local", "reliable")
func _synced_set_scraps(value: int) -> void:
	_scraps = value


@rpc("any_peer", "call_local", "reliable")
func _synced_add_mod(mod_data: PackedByteArray) -> void:
	var mod = ModBase.from_saved(mod_data)
	_local_add_mod(mod)


@rpc("any_peer", "call_local", "reliable")
func _synced_remove_mod(mod_data: PackedByteArray) -> void:
	var mod = ModBase.from_saved(mod_data)
	_local_remove_mod(mod)

#endregion
