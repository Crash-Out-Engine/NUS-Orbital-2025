class_name Effect # TODO: Implement special effects
extends ModEntry
## An effect that can be applied to [PropertyBase] properties.
## [br]
## Types of effects:[br]
## - Repeated if [member Effect._repeat] > 0 and [member Effect._interval] > 0[br]
##   - Acts as a one-off with delayed expiry if [member Effect._repeat] == 1
## - Lingering if [member Effect._repeat] <= 0 and [member Effect._interval] > 0[br]
##   - Will expire and be undo-ed after [member Effect._interval] seconds[br]
## - One-off if [member Effect._repeat] <= 0 and [member Effect._interval] <= 0[br]
## [br]
## [b]Note:[/b] An effect is invalid if [member Effect._repeat] > 0 and
## [member Effect._interval] <= 0.

@export_custom(PROPERTY_HINT_TYPE_STRING, "PropertyBase") var _property_type: String
## Interval between repetitions or lingering duration in seconds.
## [br]
## [b]Note:[/b] Taken to be equivalent to 0 if a non-positive value is supplied.
@export var _interval: float
## Repeats the effect some number of times.
## [br]
## [b]Note:[/b] Taken to be equivalent to 0 if a non-positive value is supplied.
@export var _repeat: int
@export var _factor: float


func _init() -> void:
	assert(not (_repeat > 0 and _interval <= 0),
			"Effect is invalid; a repeated effect should have a positive interval.")

	type = ModEntry.Type.EFFECT


## Helps apply the effect to the property without changing the effect's own
## state.
## [br]
## Returns a [member LingeringTimer] that emits when a lingering effect expires, or null
## otherwise.
func apply_effect(property: PropertyBase) -> LingeringTimer:
	if not _can_effect(property):
		return

	if _interval <= 0: # One-off effect
		property.value += _factor
		return


	if _repeat > 0: # Repeat effect
		_countdown(property, _repeat)
		return

	# LingeringTimer effect
	return LingeringTimer.attach_to(property, _interval, _factor)


func get_factor() -> float:
	return _factor


func get_property_type() -> String:
	return _property_type


func _can_effect(property: PropertyBase) -> bool:
	return property.get_script().get_global_name() == _property_type


func _countdown(property: PropertyBase, counter: int) -> Callable:
	return func():
		if counter > 0 and property != null:
			property.value += _factor
			var timer = property.get_tree().create_timer(_interval)
			timer.timeout.connect(_countdown(property, counter - 1))


#region Save/load

func save(dict: Dictionary = {}) -> PackedByteArray:
	dict["_property_type"] = _property_type
	dict["_interval"] = _interval
	dict["_repeat"] = _repeat
	dict["_factor"] = _factor
	return super.save(dict)

static func from_saved(data: PackedByteArray) -> Effect:
	var dict = bytes_to_var(data)
	var effect = new()
	effect._property_type = dict._property_type
	effect._interval = dict._interval
	effect._repeat = dict._repeat
	effect._factor = dict._factor

	return effect


static func save_effect_array(array: Array[Effect]) -> PackedByteArray:
	return var_to_bytes(array.map(func(effect): return effect.save()))

static func from_saved_effect_array(data: PackedByteArray) -> Array[Effect]:
	var array: Array[Effect]
	array.assign(bytes_to_var(data).map(func(effect_data): return Effect.from_saved(effect_data)))
	return array

#endregion

## Helper class for lingering effects.
class LingeringTimer:
	extends Timer
	var _factor: float

	@onready var _property := get_parent() as PropertyBase


	static func attach_to(property: PropertyBase, interval: float, factor: float) -> LingeringTimer:
		var lingering_timer = LingeringTimer.new(interval, factor)
		property.add_child(lingering_timer)
		return lingering_timer


	func _init(interval: float, factor: float) -> void:
		_factor = factor
		wait_time = interval
		one_shot = true


	func _ready() -> void:
		_property.value += _factor
		timeout.connect(disable)


	## Disables and undoes lingering.
	## [br]
	## Returns [code]true[/code] if lingering was previously active, otherwise
	## [code]false[/code].
	func disable() -> void:
		_property.value -= _factor
		queue_free()
