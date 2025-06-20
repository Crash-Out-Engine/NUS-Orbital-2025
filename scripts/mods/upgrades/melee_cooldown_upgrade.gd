class_name MeleeCooldownUpgrade
extends UpgradeBase

func _can_upgrade(property: PropertyBase) -> bool:
	return property is MeleeCooldownProp
