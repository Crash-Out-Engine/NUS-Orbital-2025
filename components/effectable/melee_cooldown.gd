class_name MeleeCooldown extends Effectable

@export var melee_cooldown: float = 0.5

var timer: Timer = Timer.new()

func _ready() -> void:
	value = melee_cooldown
	timer.one_shot = true
	timer.stop()
	add_child(timer)
	
func try_melee() -> bool:
	if timer.is_stopped():
		timer.start(value)
		return true
	else:
		return false
