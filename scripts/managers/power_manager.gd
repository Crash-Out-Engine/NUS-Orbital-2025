class_name PowerManager
extends Node

@export var initial_power: float = 100

## Server synced variable.
var _power: float


func _ready() -> void:
	_power = initial_power


func register_fault(fault: Fault) -> void:
	fault.reboot_finished.connect(_handle_fault_rebooted)


func get_power() -> float:
	return _power


func _handle_fault_rebooted() -> void:
	if is_multiplayer_authority():
		_power += 20.0
