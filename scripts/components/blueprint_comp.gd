class_name BlueprintComp
extends Node

@export var unlocked_mods: Array[ModBase] = [null]

func get_blueprints() -> Array[ModBase]:
	return unlocked_mods
