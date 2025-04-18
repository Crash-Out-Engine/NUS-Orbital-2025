class_name Health extends Effectable

@export var health_capacity: float = 20.0;
@export var recovery_rate: float = 0.0;

var health_emptied: bool

func _ready() -> void:
	value = health_capacity
	prev_value = value
	health_emptied = false
	
func _should_be_effected(effect: Effect) -> bool:
	return effect is HealthEffect

var prev_value: float
func _physics_process(delta: float) -> void:
	if value <= 0 and !health_emptied:
		health_just_emptied.emit()
		health_emptied = true
		
	if value != prev_value and !health_emptied:
		health_just_dropped.emit()
		
	prev_value = value

signal health_just_emptied

signal health_just_dropped
