class_name MeleeCooldownProp
extends PropertyBase

@export var melee_cooldown: float = 0.5

var _timer: Timer = Timer.new()


func _ready() -> void:
	value = melee_cooldown
	_timer.one_shot = true
	_timer.stop()
	add_child(_timer)


func try_melee() -> bool:
	if _timer.is_stopped():
		_timer.start(value)
		return true

	return false


func can_melee() -> bool:
	return _timer.is_stopped()

func do_melee() -> void:
	_timer.start(value)
