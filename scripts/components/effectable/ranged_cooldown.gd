class_name RangedCooldown extends Effectable

## Rate of firing in seconds.
@export var ranged_cooldown: float

var timer: Timer = Timer.new()

func _ready() -> void:
	value = ranged_cooldown
	timer.one_shot = true
	add_child(timer)
	
func try_ranged() -> bool:
	if timer.is_stopped():
		timer.start(value)
		return true
	else:
		return false
