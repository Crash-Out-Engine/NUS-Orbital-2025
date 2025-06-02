class_name EffectMod
extends ModBase

@export var effects: Array[EffectBase] = []

func _init() -> void:
	type = Type.EFFECT


func get_effects():
	return effects


static func compile_effects(effect_mods: Array[EffectMod]) -> Array[EffectBase]:
	var return_value: Array[EffectBase]
	return_value.assign(effect_mods
			.map(func(effect_mod: EffectMod): return effect_mod.get_effects())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[]))
	return return_value
