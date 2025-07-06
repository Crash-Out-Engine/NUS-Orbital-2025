class_name ModEntry
extends Resource


enum Type {
	EFFECT,
	UPGRADE,
}

var type: Type


func _init() -> void:
	assert(false, "Method should be implemented.")


#region Save/load

func save(dict: Dictionary = {}) -> PackedByteArray:
	dict["type"] = type
	return var_to_bytes(dict)


static func from_saved(data: PackedByteArray) -> ModEntry:
	var dict := bytes_to_var(data) as Dictionary
	match dict.type:
		Type.EFFECT:
			return Effect.from_saved(data)
		Type.UPGRADE:
			return Upgrade.from_saved(data)

	assert(false, "ModEntry is neither effect nor upgrade.")
	return null


static func save_array(array: Array[ModEntry]) -> PackedByteArray:
	return var_to_bytes(array.map(func(entry): return entry.save()))


static func from_saved_array(data: PackedByteArray) -> Array[ModEntry]:
	var array: Array[ModEntry]
	array.assign(bytes_to_var(data).map(func(entry_data): return from_saved(entry_data)))
	return array

#endregion
