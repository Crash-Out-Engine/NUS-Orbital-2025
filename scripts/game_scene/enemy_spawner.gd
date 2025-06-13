class_name EnemySpawner
extends Node2D

const _ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var active := true
@export var entity_manager: EntityManager

var _player: Player


func setup(game: Game) -> void:
	_player = game.get_local_player()


func _on_spawn_timer_timeout() -> void:
	if is_multiplayer_authority():
		if active:
			var enemy = _ENEMY_SCENE.instantiate()

			var center = _player.global_position
			var radius = get_viewport_rect().size.length() * 0.6
			var angle_vector = Vector2.from_angle(randf_range(0, 2 * PI))
			enemy.global_position = center + radius * angle_vector

			entity_manager.add_entity(enemy, self)
