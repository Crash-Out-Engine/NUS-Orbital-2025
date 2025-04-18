class_name Movement extends Effectable

@export var initial_speed: float = 200.0
@export var lerp_weight: float = 1.0

func _ready() -> void:
	assert(get_parent() is CharacterBody2D, "Movement's parent should be a CharacterBody2D.")
	assert(get_parent().direction is Callable, "Movement's parent should have a direction.")
	
	value = initial_speed

func _physics_process(delta: float) -> void:
	var parent = get_parent()
	
	parent.velocity = parent.direction.call(delta).normalized() * value
	parent.velocity = lerp(parent.get_real_velocity(), parent.velocity, lerp_weight)
	
	parent.move_and_slide()

func _should_be_effected(effect: Effect) -> bool:
	return effect is MovementEffect
