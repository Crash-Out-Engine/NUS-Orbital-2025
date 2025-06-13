class_name UpgradeMod
extends ModBase

@export var upgrades: Array[Upgrade] = []


func _init() -> void:
	type = Type.UPGRADE


func get_upgrades():
	return upgrades


static func compile_upgrades(upgrade_mods: Array[UpgradeMod]) -> Array[Upgrade]:
	var return_value: Array[Upgrade]
	return_value.assign(upgrade_mods
			.map(func(upgrade_mod: UpgradeMod): return upgrade_mod.get_upgrades())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[]))
	return return_value

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["type"] = type
	dict["upgrades"] = Upgrade.save_array(upgrades)
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> EffectMod:
	var dict = bytes_to_var(data)
	assert(dict.type == Type.UPGRADE, "Invalid ModBase type.")
	var upgrade_mod = new()
	upgrade_mod.upgrades = Upgrade.from_saved_array(dict.upgrades)
	return upgrade_mod

#endregion