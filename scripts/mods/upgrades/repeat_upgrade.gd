class_name RepeatUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is RepeatProp
