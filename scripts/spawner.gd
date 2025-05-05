extends Node2D

@onready var player := $"../EntityContainer/Player" as Player

@export var active := true

var enemy_scene = preload("res://scenes/enemy.tscn")

func _on_spawn_timer_timeout() -> void:
	if active:
		var enemy = enemy_scene.instantiate()
		
		enemy.global_position = player.global_position
		enemy.global_position += get_viewport_rect().size.length() * 0.6 * Vector2.from_angle(randf_range(0, 2 * PI))
		
		enemy.look_at(player.global_position)
		get_parent().add_entity(enemy)
		enemy.vfx_emitted.connect(get_parent().add_misc)
