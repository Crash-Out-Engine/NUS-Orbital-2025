class_name Effect
extends Resource

@export_custom(PROPERTY_HINT_TYPE_STRING, "PropertyBase") var _property_type: String
## Interval between repetitions (if any) in seconds.
## Taken to be equivalent to null if a non-positive value is supplied.
@export var _interval: float
@export var _repeat: int
@export var _factor: float

var _counter: int


func set_factor(value: float) -> void:
	_factor = value


func apply_effect(property: PropertyBase) -> void:
	if _can_effect(property):
		var timer: Timer
		if _interval != null and _interval > 0:
			timer = Timer.new()
			timer.wait_time = _interval
			property.add_child(timer)

		var actual_factor = - property.value if property.value + _factor < 0 else _factor
		if _repeat == 0:
			property.value += actual_factor
			if timer != null:
				timer.stop()
				timer.one_shot = true
				timer.timeout.connect(func():
						if property != null:
							property.value -= actual_factor
				)
				timer.start()

		elif timer == null:
			return

		else: # effect.repeat != 0 and effect.timer != null
			_counter = _repeat
			timer.stop()
			timer.one_shot = false
			timer.timeout.connect(_countdown(timer, property, actual_factor))
			timer.start()


func _can_effect(property: PropertyBase) -> bool:
	return property.get_script().get_global_name() == _property_type


func _countdown(timer: Timer, property: PropertyBase, factor: float) -> Callable:
	return func():
			if _counter == 0 or property == null:
				timer.one_shot = true
				timer.stop()
			else:
				property.value += factor
				property.value = max(property.value, 0)
				_counter -= 1

#region Save/load

func save() -> PackedByteArray:
	var dict = {}
	dict["_property_type"] = _property_type
	dict["_interval"] = _interval
	dict["_repeat"] = _repeat
	dict["_factor"] = _factor
	return var_to_bytes(dict)

static func from_saved(data: PackedByteArray) -> Effect:
	var dict = bytes_to_var(data)
	var effect = new()
	effect._property_type = dict._property_type
	effect._interval = dict._interval
	effect._repeat = dict._repeat
	effect._factor = dict._factor

	return effect


static func save_array(array: Array[Effect]) -> PackedByteArray:
	return var_to_bytes(array.map(func(effect): return effect.save()))

static func from_saved_array(data: PackedByteArray) -> Array[Effect]:
	var array: Array[Effect]
	array.assign(bytes_to_var(data).map(func(effect_data): return Effect.from_saved(effect_data)))
	return array

#endregion