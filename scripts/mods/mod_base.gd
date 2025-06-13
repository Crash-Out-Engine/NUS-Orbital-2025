class_name ModBase
extends Resource

enum Type {
	APPLICATION,
	EFFECT,
	UPGRADE,
}

var type: Type

func _init() -> void:
	assert(false, "ModBase is an abstract class and cannot be instantiated.")

#region Save/load

func save() -> PackedByteArray:
	assert(false, "This method should be overridden.")
	return PackedByteArray()

static func from_saved(data: PackedByteArray) -> ModBase:
	var dict = bytes_to_var(data)
	match dict.type:
		Type.APPLICATION:
			return null # TODO: Implement save for application mods.
		Type.EFFECT:
			return EffectMod.from_saved(data)
		Type.UPGRADE:
			return UpgradeMod.from_saved(data)
		_:
			assert(false, "Unhandled ModBase type.")
			return null

#endregion