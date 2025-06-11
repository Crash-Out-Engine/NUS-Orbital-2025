class_name MovementUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
	return property is MovementProp
