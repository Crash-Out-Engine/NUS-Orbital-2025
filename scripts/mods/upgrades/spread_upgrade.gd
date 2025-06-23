class_name SpreadUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is SpreadProp
