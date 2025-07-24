class_name PropertyBase
extends Node
## An abstract base class which specifies properties that can be changed by [class Effect]s.

signal changed(from: float, to: float)

## The value that gets changed by any [Effect].
var value: float:
	set(_value):
		_value = clampf(_value, min_value, max_value)
		var prev_value = value
		if _value != prev_value:
			value = _value
			changed.emit(prev_value, value)
var min_value: float = - INF
var max_value: float = INF

var _syncing: bool = false

func _init() -> void:
	ready.connect(func(): call_deferred("_setup_sync")) # TODO: check if it is possible to not defer
	assert(get_class() != "PropertyBase",
			"PropertyBase is an abstract base class and cannot be instantiated.")

#region Sync

func _setup_sync() -> void:
	changed.connect(func(_from, _to):
			if is_inside_tree() and !_syncing:
				_sync.rpc(save())
	)

@rpc("any_peer", "call_remote", "reliable")
func _sync(data: PackedByteArray) -> void:
	load_saved(data)

#endregion

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["value"] = value
	dict["min_value"] = min_value
	dict["max_value"] = max_value
	return var_to_bytes(dict)

func load_saved(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	if not is_node_ready():
		await ready
	_syncing = true
	value = dict["value"]
	min_value = dict["min_value"]
	max_value = dict["max_value"]
	_syncing = false

#endregion
