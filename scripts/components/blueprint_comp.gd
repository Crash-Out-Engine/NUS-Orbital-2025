class_name BlueprintComp
extends Node

@export var unlocked_mods: Array[Mod] = [null]

func get_blueprints() -> Array[Mod]:
	return unlocked_mods
