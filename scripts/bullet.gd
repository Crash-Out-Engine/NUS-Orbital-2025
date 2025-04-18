extends Area2D

const SPEED = 10

var direction: float

var effects: Array[Callable] = [
	func(body: Node): return MovementEffect.create_freeze(body, 1.0),
	func(body: Node): return HealthEffect.create_lasting(body, 6, 4, 1),
	func(body: Node): return HealthEffect.create_instant(3.0),
]

func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.get_node_or_null(^"./Hitbox") != null:
		for effect in effects:
			body.get_node_or_null(^"./Hitbox").trigger(effect.call(body))
		queue_free()
