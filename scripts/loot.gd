class_name Loot extends Area2D

const SPEED = 800

@onready var player: Player = $/root/Game/EntityContainer/Player

func _physics_process(delta: float) -> void:
	var direction = global_position.angle_to_point(player.global_position)
	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.get_node_or_null(^"Hitbox") != null:
		queue_free()
