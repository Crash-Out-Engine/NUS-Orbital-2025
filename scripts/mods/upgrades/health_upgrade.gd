class_name HealthUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is HealthProp
