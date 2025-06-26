class_name Upgrade
extends Resource

enum Target {
	ENTITY,
	BULLET,
	EXPLOSION
}

@export_custom(PROPERTY_HINT_TYPE_STRING, "PropertyBase") var _property_type: String
@export var _factor: float
@export var _target: Target

func set_factor(value: float) -> void:
	_factor = value

func set_target(value: Target) -> void:
	_target = value

func apply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value += _factor


func unapply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value -= _factor


func _can_upgrade(property: PropertyBase) -> bool:
	return property.get_script().get_global_name() == _property_type

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["_property_type"] = _property_type
	dict["_factor"] = _factor
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> Upgrade:
	var dict = bytes_to_var(data)
	var upgrade = new()
	upgrade._property_type = dict._property_type
	upgrade._factor = dict._factor

	return upgrade


static func save_array(array: Array[Upgrade]) -> PackedByteArray:
	return var_to_bytes(array.map(func(upgrade): return upgrade.save()))

static func from_saved_array(data: PackedByteArray) -> Array[Upgrade]:
	var array: Array[Upgrade]
	array.assign(bytes_to_var(data).map(func(upgrade_data): return Upgrade.from_saved(upgrade_data)))
	return array

#endregion
