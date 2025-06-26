extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var active := true

# TODO: Decouple player in multiplayer implementation.
@onready var player := $"../EntityContainer/Player" as Player


func _on_spawn_timer_timeout() -> void:
	if active:
		var enemy = _ENEMY_SCENE.instantiate()

		var center = player.global_position
		var radius = get_viewport_rect().size.length() * 0.6
		var angle_vector = Vector2.from_angle(randf_range(0, 2 * PI))
		enemy.global_position = center + radius * angle_vector

		get_parent().add_entity(enemy)
		enemy.entity_spawned.connect(get_parent().add_misc)
