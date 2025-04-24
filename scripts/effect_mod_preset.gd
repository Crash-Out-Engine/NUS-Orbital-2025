class_name EffectModPreset extends EffectMod

@export var mod_name: String

func _ready() -> void:
	var config = ConfigFile.new()
	var path = "res://configs/effect_mods/" + mod_name + ".cfg"
	var err = config.load(path)
	
	if err != OK:
		assert(false, "Could not find " + path + " , check that the mod \"" + mod_name + "\" exists.")
		return
		
	for effect in config.get_sections():
		var interval = config.get_value(effect, "interval")
		var repeat = config.get_value(effect, "repeat")
		var factor = config.get_value(effect, "factor")
		
		effects.append(_create_effect(effect, interval, repeat, factor))

func _create_effect(name: String, interval: float, repeat: int, factor: float) -> Effect:
	if name == "HealthEffect":
		return HealthEffect.new(interval, repeat, factor)
		
	assert(false, "Effect name " + name + " is nonexistent.")
	return null
