extends CharacterBody2D

var explosion_scene = preload("res://scenes/explosion.tscn")

@onready var player = $/root/Game/Player

var direction: Callable = func(_delta: float) -> Vector2:
	return global_position.direction_to(player.global_position)

const SPEED = 100

func _ready() -> void:
	$Health.just_emptied.connect(die)
	$Health.just_reduced.connect(bleed)

func _physics_process(_delta: float) -> void:
	look_at(player.global_position)

func die():
	queue_free()
	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.emitting = true
	explosion.lifetime = randf_range(0.5, 0.7)
	$/root/Game.add_child(explosion)
		
func bleed(amount: float):
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.emitting = true
	explosion.lifetime = 0.1 + randf_range(0.2, 0.5) * (amount / $Health.health_capacity)
	$/root/Game.add_child(explosion)
