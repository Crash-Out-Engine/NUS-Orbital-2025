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


## To be overrided when implementing specific upgrades; decides if the specified upgrade
## affects a property.
func _can_upgrade(property: PropertyBase) -> bool:
	return property.get_script().get_global_name() == _property_type
