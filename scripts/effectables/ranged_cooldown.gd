class_name RangedCooldown
extends Effectable

@export var ranged_cooldown: float ## Rate of firing in seconds.

var _timer: Timer = Timer.new()


func _ready() -> void:
	value = ranged_cooldown
	_timer.one_shot = true
	add_child(_timer)


func try_ranged() -> bool:
	if _timer.is_stopped():
		_timer.start(value)
		return true
	else:
		return false


func can_ranged() -> bool:
	return _timer.is_stopped()


func do_ranged() -> void:
	_timer.start(value)
