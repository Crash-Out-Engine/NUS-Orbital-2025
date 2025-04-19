extends Area2D

const SPEED = 10

var direction: float

var effects: Array[Effect] = [
	MovementEffect.create_freeze(1.0),
	HealthEffect.create_lasting(6, 4, 1),
	HealthEffect.create_instant(3.0),
]

func _physics_process(_delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.get_node_or_null(^"./Hitbox") != null:
		for effect in effects:
			body.get_node_or_null(^"./Hitbox").trigger(effect)
		queue_free()
