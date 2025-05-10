class_name Loot extends Area2D

#const SPEED_CAPACITY = 100
const SPEED = 800

@onready var player: Player = $/root/Game/EntityContainer/Player

var _velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if(global_position.distance_to(player.global_position) <= player.PICKUP_RANGE):
		var direction = global_position.angle_to_point(player.global_position)
		#var acceleration := 10000000.0 / global_position.distance_squared_to(player.global_position)
		#_velocity = Vector2.from_angle(direction) * (acceleration * delta + _velocity.length())
		#global_position += _velocity * delta
		_velocity = Vector2.from_angle(direction) * SPEED
		global_position += _velocity * delta
		#global_rotation = direction

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.get_node_or_null(^"Hitbox") != null:
		queue_free()
