class_name InventoryComp
extends Node
## Inventory component within a player.
##
## This component requires that each distinct [class ModBase] exists as a single
## shared [class Resource] instance across the game, as it matches with the
## object reference of the [class ModBase].

signal scraps_changed(from: int, to: int)

@export var initial_mods: Array[ModBase]
@export var initial_scraps: int

var inventory_ui: Control
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
func access_entity(entity: Node2D) -> void:
	assert(entity != null
		and entity.get_node_or_null(^"Components/ModSlotComp") != null,
		"Entity accessed should have ModSlotComp.")

	_entity_slot = entity.get_node(^"Components/ModSlotComp")
	await _entity_slot.ready


func unaccess_entity() -> void:
	_entity_slot = null


func get_mods() -> Dictionary[ModBase, int]:
	var duped_mods = _mods.duplicate()
	duped_mods.make_read_only()
	return duped_mods


func get_scraps() -> int:
	return _scraps


func use_scraps(amount: int) -> void:
	assert(amount >= 0, "Amount used should not be a negative number.")
	_scraps -= amount


func get_entity_mods() -> Array[ModBase]:
	return _entity_slot.get_mods()


func _handle_mod_equipped(mod: ModBase):
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")

	var empty_slot_index := _entity_slot.get_mods().find(null)
	assert(empty_slot_index != -1, "No empty slots left in entity.")

	_mods[mod] -= 1
	_entity_slot.set_slot(empty_slot_index, mod)


func _handle_mod_unequipped(slot_index: int):
	var mod = _entity_slot.get_mods()[slot_index]
	assert(mod != null, "Mod not found in entity mod slot.")

	_add_mod(mod)
	_entity_slot.set_slot(slot_index, null)


func _add_mod(mod: ModBase) -> void:
	_mods[mod] =_mods.get_or_add(mod, 0) + 1

func _remove_mod(mod: ModBase) -> void:
	assert(mod in _mods and _mods[mod] > 0,
		"Mod not found in inventory.")
	_mods[mod] -= 1
