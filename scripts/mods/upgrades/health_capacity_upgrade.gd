class_name HealthCapacityUpgrade
extends UpgradeBase


func _can_upgrade(property: PropertyBase) -> bool:
    return property is HealthCapacityProp
