class_name CopyUpgrade
extends UpgradeBase

func _can_upgrade(property: PropertyBase) -> bool:
	return property is CopyProp
