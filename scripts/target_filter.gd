class_name TargetFilter
extends Resource

@export var targets: Array[Enums.Team]

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["targets"] = targets
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> TargetFilter:
	var dict = bytes_to_var(data)
	var target_filter = new()
	target_filter.targets = dict.targets
	return target_filter

#endregion
