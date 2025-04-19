extends Area2D

const SPEED = 10

var direction: float

var group: String

var effects: Array[Effect] = []

func _physics_process(_delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.get_node_or_null(^"./Hitbox") != null and not body.is_in_group(group):
		print(effects)
		for effect in effects:
			body.get_node_or_null(^"./Hitbox").trigger(effect)
		queue_free()
