class_name TimeoutUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is TimeoutProp
