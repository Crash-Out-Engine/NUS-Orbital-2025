class_name Bullet
extends Area2D

const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPEED = 700

var direction: float
var team: String
var effects: Array[Effect] = []


func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.get_node_or_null(^"./Hitbox") != null and not body.is_in_group(team): # TODO: Don't rely on godot groups
		var explosion = _EXPLOSION_SCENE.instantiate()
		print(has_overlapping_areas())
		explosion.global_position = global_position
		explosion.team = team
		explosion.effects = effects
		get_parent().add_child(explosion)
		explosion.explode()
		queue_free()
