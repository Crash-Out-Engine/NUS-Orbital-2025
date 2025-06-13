class_name EffectMod
extends ModBase

@export var effects: Array[Effect] = []

func _init() -> void:
	type = Type.EFFECT


func get_effects():
	return effects


static func compile_effects(effect_mods: Array[EffectMod]) -> Array[Effect]:
	var return_value: Array[Effect]
	return_value.assign(effect_mods
			.map(func(effect_mod: EffectMod): return effect_mod.get_effects())
			.reduce(func(acc, e):
					acc.append_array(e)
					return acc,
					[]))
	return return_value

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["type"] = type
	dict["effects"] = Effect.save_array(effects)
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> EffectMod:
	var dict = bytes_to_var(data)
	assert(dict.type == Type.EFFECT, "Invalid ModBase type.")
	var effect_mod = new()
	effect_mod.effects = Effect.from_saved_array(dict.effects)
	return effect_mod

#endregion