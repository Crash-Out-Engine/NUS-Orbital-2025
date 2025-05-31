extends Node2D

@export var active := true

var _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@onready var player := $"../EntityContainer/Player" as Player


func _on_spawn_timer_timeout() -> void:
	if active:
		var enemy = _ENEMY_SCENE.instantiate()
		
		enemy.global_position = player.global_position
		enemy.global_position += get_viewport_rect().size.length() * 0.6 * Vector2.from_angle(randf_range(0, 2 * PI))
		
		get_parent().add_entity(enemy)
		enemy.vfx_emitted.connect(get_parent().add_misc)
