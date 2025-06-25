class_name UpgradeMod
extends ModBase

@export var upgrades: Array[Upgrade] = []


func _init() -> void:
	type = Type.UPGRADE


func get_upgrades():
	return upgrades


static func compile_upgrades(
	upgrade_mods: Array[UpgradeMod], target: Upgrade.Target) -> Array[Upgrade]:
	var return_value: Array[Upgrade]
	return_value.assign(upgrade_mods
			.map(func(upgrade_mod: UpgradeMod): return upgrade_mod.get_upgrades())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[])
			.filter(func(upgrade: Upgrade): return upgrade._target == target))
	return return_value
