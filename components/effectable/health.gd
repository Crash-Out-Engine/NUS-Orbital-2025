class_name Health extends Effectable

@export var health_capacity: float = 20.0;

var health_emptied: bool

func _ready() -> void:
	value = health_capacity
	prev_value = value
	health_emptied = false

var prev_value: float
func _physics_process(_delta: float) -> void:
	if value <= 0 and !health_emptied:
		just_emptied.emit()
		health_emptied = true
		
	if value != prev_value and !health_emptied:
		just_reduced.emit(prev_value - value)
		just_changed.emit(prev_value, value)
		
	prev_value = value

signal just_emptied

signal just_reduced(by: float)

signal just_changed(old_value: float, new_value: float)
