class_name UpgradeBase
extends Resource

@export var _factor: float


func set_factor(value: float) -> void:
	_factor = value


func apply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value += _factor


func unapply_upgrade(property: PropertyBase) -> void:
	if _can_upgrade(property):
		property.value -= _factor


## To be overrided when implementing specific upgrades; decides if the specified upgrade
## affects a property.
func _can_upgrade(_property: PropertyBase) -> bool:
	return false