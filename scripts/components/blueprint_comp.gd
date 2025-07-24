class_name BlueprintComp
extends Node

@export var unlocked_mods: Array[Mod] = [null]

func add_blueprint(mod: Mod) -> bool:
	if unlocked_mods.has(mod):
		return false
	unlocked_mods.append(mod)
	return true

func get_blueprints() -> Array[Mod]:
	return unlocked_mods
