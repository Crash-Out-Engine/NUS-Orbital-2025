class_name PowerManager
extends Node
## A server node for managing power in the game.

signal power_depleted()

@export var active: bool = true
@export var _initial_power: float = 100.0
@export var _power_delta: float = 1.0

## Server synced variable.
var _power: float:
	set(value):
		_power = value
		if _power <= 0:
			power_depleted.emit()


func _ready() -> void:
	_power = _initial_power
	if not multiplayer.is_server():
		process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	if active:
		_synced_set_power.rpc(_power - delta * _power_delta)


func register_fault(fault: Fault) -> void:
	Utils.assert_server(self)
	fault.fixed.connect(_handle_fault_rebooted)


func get_power() -> float:
	return _power


func _handle_fault_rebooted() -> void:
	if not is_multiplayer_authority():
		return

	_synced_set_power.rpc( _power + 20.0)

#region Sync

@rpc("authority", "call_remote", "reliable")
func _receive_sync(data: PackedByteArray) -> void:
	load_saved(data)

@rpc("authority", "call_local", "reliable")
func _synced_set_power(value: float) -> void:
	_power = value

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
