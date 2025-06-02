class_name UpgradeMod
extends ModBase

@export var upgrades: Array[UpgradeBase] = []


func _init() -> void:
	type = Type.UPGRADE


func get_upgrades():
	return upgrades


static func compile_upgrades(upgrade_mods: Array[UpgradeMod]) -> Array[UpgradeBase]:
	var return_value: Array[UpgradeBase]
	return_value.assign(upgrade_mods
			.map(func(upgrade_mod: UpgradeMod): return upgrade_mod.get_upgrades())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[]))
	return return_value
