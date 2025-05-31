class_name Bullet
extends Area2D

const _EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const SPEED = 800

@export var lives: LivesProp

var direction: float
var target_filter: TargetFilter
var effects: Array[EffectBase] = []


func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(direction) * SPEED * delta
	global_rotation = direction


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if (body.get_node_or_null(^"Components/HitboxComp") != null
			and body.get_node(^"Components/HitboxComp").is_targeted_by(target_filter)):
		var explosion = _EXPLOSION_SCENE.instantiate()
		explosion.global_position = global_position
		explosion.target_filter = target_filter
		explosion.effects = effects
		call_deferred("add_sibling", explosion)

		if lives.try_die():
			queue_free()
