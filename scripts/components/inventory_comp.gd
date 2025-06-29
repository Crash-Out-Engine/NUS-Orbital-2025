class_name InventoryComp
extends Node
## Inventory component within a player.
##
## This component requires that each distinct [class ModBase] exists as a single
## shared [class Resource] instance across the game, as it matches with the
## object reference of the [class ModBase].

signal scraps_changed(from: int, to: int)
signal slots_updated(size: int, capacity: int)

@export var initial_mods: Array[ModBase]
@export var initial_scraps: int

@export var mod_targeting_comp: ModTargetingComp
@export var blueprint_comp: BlueprintComp

var inventory_ui: Control
var _entity: Node2D
var _entity_slot: ModSlotComp
var _mods: Dictionary[ModBase, int]
var _scraps: int:
	set(value):
		var prev_value = _scraps
		_scraps = value
		scraps_changed.emit(prev_value, _scraps)


func _ready() -> void:
	for mod in initial_mods:
		_add_mod(mod)
	_scraps = initial_scraps


func register_item(item: Item):
	match item.type:
		Item.Type.SCRAP:
			_scraps += (item as Item.ScrapItem).count
		Item.Type.MOD:
			_add_mod((item as Item.ModItem).mod)


## Allows the entity (typically Player) to access another entity's ModSlotComp,
## throws an error if not found.
func access_entity() -> void:
	var entity := mod_targeting_comp.get_target()

	assert(entity != null
		and entity.has_node(^"Components/ModSlotComp"),
		"Entity accessed should have ModSlotComp.")

	_entity = entity
	_entity_slot = entity.get_node(^"Components/ModSlotComp")
	_entity_slot.updated.connect(slots_updated.emit)
	slots_updated.emit(_entity_slot.get_mods().size(), _entity_slot.get_capacity())


func unaccess_entity() -> void:
	_entity_slot.updated.disconnect(slots_updated.emit)
	_entity = null
	_entity_slot = null


func is_entity_turret() -> bool:
	return _entity is Turret


func disassemble_turret() -> bool:
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


func use_scraps(amount: int) -> void:
	assert(amount >= 0, "Amount used should not be a negative number.")
	_scraps -= amount


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
	if _scraps < _entity_slot.get_upgrade_cost():
		return false

	_scraps -= _entity_slot.get_upgrade_cost()
	_entity_slot.increment_capacity()
	return true

#endregion


func equip_mod(mod: ModBase):
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")

	assert(not _entity_slot.is_full(),
			"No empty slots left in entity.")

	_mods[mod] -= 1
	_entity_slot.add_mod(mod)


func unequip_mod(mod: ModBase):
	assert(mod != null, "Mod not found in entity mod slot.")

	_add_mod(mod)
	_entity_slot.remove_mod(mod)


func recycle_mod(mod: ModBase):
	_remove_mod(mod)
	_scraps += mod.get_recycle_value()


func _add_mod(mod: ModBase) -> void:
	_mods[mod] =_mods.get_or_add(mod, 0) + 1

func _remove_mod(mod: ModBase) -> void:
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")
	_mods[mod] -= 1
