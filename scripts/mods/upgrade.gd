class_name Upgrade
extends ModEntry

enum Target {
	ENTITY,
	BULLET,
	EXPLOSION
}


@export var special: bool = false # TODO: Implement special upgrades
@export_custom(PROPERTY_HINT_TYPE_STRING, "PropertyBase") var _property_type: String
@export var _factor: float
@export var _target: Target


func _init() -> void:
	type = ModEntry.Type.UPGRADE


func apply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value += _factor


func unapply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value -= _factor


func get_target() -> Target:
	return _target


func _can_upgrade(property: PropertyBase) -> bool:
	return property.get_script().get_global_name() == _property_type

#region Save/load

func save(dict: Dictionary = {}) -> PackedByteArray:
	dict["_property_type"] = _property_type
	dict["_factor"] = _factor
	return super.save(dict)

static func from_saved(data: PackedByteArray) -> Upgrade:
	var dict = bytes_to_var(data)
	var upgrade = new()
	upgrade._property_type = dict._property_type
	upgrade._factor = dict._factor

	return upgrade


static func save_upgrade_array(array: Array[Upgrade]) -> PackedByteArray:
	return var_to_bytes(array.map(func(upgrade): return upgrade.save()))

static func from_saved_upgrade_array(data: PackedByteArray) -> Array[Upgrade]:
	var array: Array[Upgrade]
	array.assign(bytes_to_var(data).map(func(upgrade_data): return Upgrade.from_saved(upgrade_data)))
	return array

#endregion
