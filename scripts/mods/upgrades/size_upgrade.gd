class_name SizeUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is SizeProp
