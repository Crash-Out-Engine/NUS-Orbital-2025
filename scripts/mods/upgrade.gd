class_name Upgrade
extends Resource

enum Type {
	HEALTH_CAPACITY,
}

@export var type: Type
@export var _factor: float


func set_factor(value: float) -> void:
	_factor = value


func apply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value += _factor


func unapply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value -= _factor


func _can_upgrade(property: PropertyBase) -> bool:
	match type:
		Type.HEALTH_CAPACITY:
			return property is HealthCapacityProp

	return false

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["type"] = type
	dict["_factor"] = _factor
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> Upgrade:
	var dict = bytes_to_var(data)
	var upgrade = new()
	upgrade.type = dict.type
	upgrade._factor = dict._factor

	return upgrade


static func save_array(array: Array[Upgrade]) -> PackedByteArray:
	return var_to_bytes(array.map(func(upgrade): return upgrade.save()))

static func from_saved_array(data: PackedByteArray) -> Array[Upgrade]:
	return bytes_to_var(data).map(func(upgrade_data): return Upgrade.from_saved(upgrade_data))

#endregion
