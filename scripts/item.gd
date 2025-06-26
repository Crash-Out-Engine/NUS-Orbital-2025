class_name Item
extends Resource

enum Type {
	SCRAP,
	MOD
}

var type: Type

#region Save/load

func save() -> PackedByteArray:
	assert(false, "This method should be overridden.")
	return PackedByteArray()

static func from_saved(data: PackedByteArray) -> Item:
	var dict = bytes_to_var(data)
	match dict.type:
		Type.SCRAP:
			return ScrapItem.from_saved(data)
		Type.MOD:
			return ModItem.from_saved(data)
		_:
			assert(false, "Unhandled item type.")
			return null

#endregion

class ScrapItem:
	extends Item

	var count: int

	func _init(_count: int) -> void:
		type = Type.SCRAP
		count = _count

	#region Save/load

	func save() -> PackedByteArray:
		var dict = {}
		dict["type"] = type
		dict["count"] = count
		return var_to_bytes(dict)

	static func from_saved(data: PackedByteArray) -> ScrapItem:
		var dict = bytes_to_var(data)
		assert(dict.type == Type.SCRAP, "Invalid save data.")
		return new(dict.count)

	#endregion


class ModItem:
	extends Item

	var mod: ModBase

	func _init(_mod: ModBase) -> void:
		type = Type.MOD
		mod = _mod

	#region Save/load

	func save() -> PackedByteArray:
		var dict = {}
		dict["type"] = type
		dict["mod"] = mod.save()
		return var_to_bytes(dict)

	static func from_saved(data: PackedByteArray) -> ModItem:
		var dict = bytes_to_var(data)
		assert(dict.type == Type.MOD, "Invalid save data.")
		return new(ModBase.from_saved(dict.mod))

	#endregionmod: ModBase) -> void:

