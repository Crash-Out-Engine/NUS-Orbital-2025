class_name EffectMod
extends Resource

@export var effects: Array[EffectBase] = []


func get_effects():
	return effects


static func compile_effects(effect_mods: Array[EffectMod]) -> Array[EffectBase]:
	return (effect_mods
			.map(func(effect_mod: EffectMod): return effect_mod.get_effects())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[]))