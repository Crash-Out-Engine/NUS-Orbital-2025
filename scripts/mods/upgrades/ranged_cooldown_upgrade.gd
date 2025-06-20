class_name RangedCooldownUpgrade
extends UpgradeBase

func _can_upgrade(property: PropertyBase) -> bool:
	return property is RangedCooldownProp
