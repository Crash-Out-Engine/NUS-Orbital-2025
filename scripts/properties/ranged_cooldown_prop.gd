class_name RangedCooldownProp
extends PropertyBase

@export var ranged_cooldown: float ## Rate of firing in seconds.

var _timer: Timer = Timer.new()


func _ready() -> void:
	value = ranged_cooldown
	min_value = 0.02
	_timer.one_shot = true
	add_child(_timer)


func try_ranged() -> bool:
	if _timer.is_stopped():
		_timer.start(value)
		return true

	return false


func can_ranged() -> bool:
	return _timer.is_stopped()


func do_ranged() -> void:
	_timer.start(max(value, 0.01))
