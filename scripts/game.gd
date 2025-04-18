extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

@onready var player = $Player

func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.global_position = player.global_position
	enemy.global_position += get_viewport_rect().size.length() * 0.6 * Vector2.from_angle(randf_range(0, 2 * PI))
	
	enemy.look_at(player.global_position)
	add_child(enemy)
