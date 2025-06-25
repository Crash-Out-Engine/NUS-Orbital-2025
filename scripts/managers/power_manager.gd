class_name PowerManager
extends Node

signal power_depleted()

@export var active: bool = true
@export var _initial_power: float = 100.0
@export var _power_delta: float = 1.0

## Server synced variable.
var _power: float:
	set(value):
		_power = value
		if is_multiplayer_authority():
			_sync.rpc(save())
			if _power <= 0:
				power_depleted.emit()


func _ready() -> void:
	_power = _initial_power


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if active:
		_power -= delta * _power_delta


func register_fault(fault: Fault) -> void:
	fault.fixed.connect(_handle_fault_rebooted)


func get_power() -> float:
	return _power


func _handle_fault_rebooted() -> void:
	if not is_multiplayer_authority():
		return

	_power += 20.0

#region Sync

@rpc("any_peer", "call_remote", "reliable")
func _sync(data: PackedByteArray) -> void:
	if is_multiplayer_authority(): # Synced to non-authorities only
		return
	
	load_saved(data)

#endregion

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["_power"] = _power
	return var_to_bytes(dict)

func load_saved(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	_power = dict["_power"]

#endregion
